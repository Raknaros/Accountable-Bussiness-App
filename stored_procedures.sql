--Insertar periodo a varios registros
CREATE OR REPLACE FUNCTION acc.asignar_periodo(INTEGER[],INTEGER,INTEGER) RETURNS text VOLATILE AS
$$
DECLARE
qty integer:= array_length($1,1);
respuesta varchar := null;
BEGIN
	FOR i IN 1..qty LOOP
		EXECUTE'UPDATE _'||$3||' SET periodo_tributario = '||$2||' WHERE id = '||$1[i];
	END LOOP;
	respuesta := 'Periodo '||$2||' asignado a '||qty||' comprobantes del subdiario '||$3;
RETURN respuesta;
END;
$$ LANGUAGE plpgsql;

--Trigger/Insertar CUI en subdiarios 2, 5 y 8
CREATE OR REPLACE FUNCTION fill_cui() RETURNS TRIGGER AS
$$
BEGIN
IF new.subdiario = 5 THEN
	NEW.cui = CONCAT(NEW.subdiario,ltrim(to_char(NEW.entity_id,'000')),ltrim(to_char(NEW.tipo_comprobante,'00')),NEW.numero_serie,NEW.numero_correlativo);

ELSIF new.subdiario = 8 THEN
	NEW.CUI = CONCAT(NEW.subdiario,NEW.numero_documento,ltrim(to_char(NEW.tipo_comprobante,'00')),NEW.numero_serie,NEW.numero_correlativo);
ELSIF new.subdiario = 2 THEN
	NEW.cui = CONCAT(NEW.subdiario,ltrim(to_char(NEW.entity_id,'000')),ltrim(to_char(NEW.entidad_financiera,'00')),NEW.numero_operacion);

END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Trigger/Insertar cobro o pago según normativa de utilización de medios de pago (3500  antes del 01/04/2021, 2000 despues de esa fecha), descontando detraccion. 
CREATE OR REPLACE FUNCTION cash_payment() RETURNS TRIGGER AS $$
DECLARE
	movimiento INTEGER:= CASE WHEN NEW.subdiario = 5 THEN '1' ELSE '2' END;
	total DEC(10,2):= (CASE WHEN (NEW.subdiario = 5 AND NEW.destino <> 2) OR (NEW.subdiario = 8 AND NEW.destino <> 4) THEN 1.18*NEW.valor ELSE NEW.valor END) + NEW.isc + NEW.icbp + NEW.otros_cargos;
	total_mn DEC(10,2):= CASE WHEN NEW.tipo_moneda = 'USD' THEN (select usd_s from tc WHERE fecha_sunat = NEW.fecha_emision) * total ELSE total END ;
	importe DEC(10,2):= CASE WHEN NEW.tasa_detraccion IS NOT NULL THEN (total_mn - CEIL(total_mn * (SELECT tasa FROM spot WHERE codigo = NEW.tasa_detraccion))) ELSE total_mn END;
BEGIN
IF NEW.tipo_comprobante <> 7 THEN	
	IF total_mn<3000 AND NEW.medio_pago IS NULL AND NEW.fecha_emision < '2021-04-01'::date THEN
		INSERT INTO _1(entity_id,tipo_movimiento,cui_relacionado,fecha_operacion,importe, tipo_moneda) VALUES (NEW.entity_id, movimiento,NEW.cui, NEW.fecha_emision, importe, 'PEN');
	ELSIF total_mn<2000 AND NEW.medio_pago IS NULL AND NEW.fecha_emision >= '2021-04-01'::date THEN
		INSERT INTO _1(entity_id,tipo_movimiento,cui_relacionado,fecha_operacion,importe, tipo_moneda) VALUES (NEW.entity_id, movimiento, NEW.cui, NEW.fecha_emision, importe, 'PEN');
	END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Trigger/Llenar tabla related con RUCs relaccionados no registrados
CREATE OR REPLACE FUNCTION fill_related() RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.tipo_documento <> '0' AND NEW.numero_documento NOT IN (SELECT numero_documento FROM acc.related WHERE related.tipo_documento = NEW.tipo_documento) THEN INSERT INTO related(tipo_documento,numero_documento) VALUES(NEW.tipo_documento,NEW.numero_documento);
	END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger/Registrar cambios realizados
CREATE OR REPLACE FUNCTION changes() RETURNS TRIGGER AS $$
   BEGIN
      INSERT INTO changeslog(usuario,subdiario,id,instante) VALUES (current_user, new.subdiario,new.id,now());
      RETURN NEW;
   END;
$$ LANGUAGE plpgsql;

--Trigger/Tratamiento de no domiciliados sin documento
CREATE OR REPLACE FUNCTION foreing_document() RETURNS TRIGGER AS
$$
DECLARE
document_number VARCHAR:= ltrim(to_char((SELECT count(numero_documento) +1 FROM related WHERE tipo_documento = '0'),'00000000000'));
BEGIN
IF NEW.tipo_documento = '0' THEN
	IF NEW.numero_documento ~'^[A-Z]{2}.*$' AND (SELECT numero_documento FROM related WHERE nombre_razon = NEW.numero_documento) IS NULL THEN
	INSERT INTO related(tipo_documento,numero_documento,nombre_razon) VALUES(NEW.tipo_documento,document_number,NEW.numero_documento);
	NEW.numero_documento = document_number;
	ELSIF NEW.numero_documento ~'^[A-Z]{2}.*$' AND (SELECT numero_documento FROM related WHERE nombre_razon = NEW.numero_documento) IS NOT NULL THEN
	NEW.numero_documento = (SELECT numero_documento FROM related WHERE nombre_razon = NEW.numero_documento);
	END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger/Insertar registros de comercio exterior importacion/exportacion
CREATE OR REPLACE FUNCTION fill_itrade() RETURNS TRIGGER AS
$$
BEGIN
IF NEW.tipo_comprobante <> 7 AND (NEW.tipo_operacion = 17 OR NEW.tipo_operacion = 18) THEN
	INSERT INTO itrade(tipo_operacion,cui_relacionado,periodo_tributario) VALUES (NEW.tipo_operacion,NEW.cui,NEW.periodo_tributario);
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Trigger/Insertar pre registro de detraccion
CREATE OR REPLACE FUNCTION pre_spot() RETURNS TRIGGER AS
$$
DECLARE
periodo INTEGER:= to_char(NEW.fecha_emision,'YYYYMM')::integer;
movimiento INTEGER:= CASE NEW.subdiario WHEN 5 THEN 1 ELSE 2 END;
describe VARCHAR:= 'DETRACCION TASA '||NEW.tasa_detraccion;
BEGIN
IF NEW.tasa_detraccion IS NOT NULL THEN
	INSERT INTO acc._2(entity_id,periodo_tributario,tipo_movimiento,entidad_financiera,medio_pago,tipo_moneda,descripcion,cui_relacionado) VALUES(NEW.entity_id,periodo,movimiento,18,1,'PEN',describe,NEW.cui);
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Trigger/Borrar registros relacionados por anulacion de operacion.
CREATE OR REPLACE FUNCTION anulacion_operacion() RETURNS TRIGGER AS
$$
DECLARE
cui_5 VARCHAR:= CONCAT(NEW.subdiario,ltrim(to_char(NEW.entity_id,'000')),ltrim(to_char(NEW.tipo_comprobante_modificado,'00')),NEW.numero_serie_modificado,NEW.numero_correlativo_modificado);
cui_8 VARCHAR:= CONCAT(NEW.subdiario,NEW.numero_documento,ltrim(to_char(NEW.tipo_comprobante_modificado,'00')),NEW.numero_serie_modificado,NEW.numero_correlativo_modificado);
BEGIN
IF NEW.tipo_comprobante = 7 AND NEW.glosa LIKE '%ANULACI%' THEN
	IF NEW.subdiario = 5 THEN
	DELETE FROM acc._2 WHERE cui_relacionado = cui_5;
	DELETE FROM acc._1 WHERE cui_relacionado = cui_5;
	DELETE FROM acc.itrade WHERE cui_relacionado = cui_5;
	ELSE
	DELETE FROM acc._2 WHERE cui_relacionado = cui_8;
	DELETE FROM acc._1 WHERE cui_relacionado = cui_8;
	DELETE FROM acc.itrade WHERE cui_relacionado = cui_8;
	END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Trigger/Actualizar cui principal y relacionados.
CREATE OR REPLACE FUNCTION update_cui() RETURNS TRIGGER AS
$$
BEGIN
IF OLD.subdiario = 5 THEN
	IF OLD.entity_id <> NEW.entity_id OR OLD.tipo_comprobante <> NEW.tipo_comprobante OR OLD.numero_serie <> NEW.numero_serie OR OLD.numero_correlativo <> NEW.numero_correlativo THEN
	NEW.cui = CONCAT(NEW.subdiario,ltrim(to_char(NEW.entity_id,'000')),ltrim(to_char(NEW.tipo_comprobante,'00')),NEW.numero_serie,NEW.numero_correlativo);
	UPDATE acc._1 SET cui_relacionado = NEW.cui WHERE cui_relacionado = OLD.cui;
	UPDATE acc._2 SET cui_relacionado = NEW.cui WHERE cui_relacionado = OLD.cui;
ELSIF OLD.subdiario = 8 THEN
	ELSIF OLD.numero_documento <> NEW.numero_documento OR OLD.tipo_comprobante <> NEW.tipo_comprobante OR OLD.numero_serie <> NEW.numero_serie OR OLD.numero_correlativo <> NEW.numero_correlativo THEN
	NEW.CUI = CONCAT(NEW.subdiario,NEW.numero_documento,ltrim(to_char(NEW.tipo_comprobante,'00')),NEW.numero_serie,NEW.numero_correlativo);
	UPDATE acc._1 SET cui_relacionado = NEW.cui WHERE cui_relacionado = OLD.cui;
	UPDATE acc._2 SET cui_relacionado = NEW.cui WHERE cui_relacionado = OLD.cui;
ELSIF OLD.subdiario = 2 THEN
	ELSIF OLD.entity_id <> NEW.entity_id OR OLD.entidad_financiera <> NEW.entidad_financiera OR OLD.numero_operacion <> NEW.numero_operacion THEN
	NEW.cui = CONCAT(NEW.subdiario,ltrim(to_char(NEW.entity_id,'000')),ltrim(to_char(entidad_financiera,'00')),numero_operacion);
	END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Trigger/Preliquidacion general
CREATE OR REPLACE FUNCTION preliquidacion_general(INTEGER) RETURNS TABLE(ENTIDAD VARCHAR, _100 DEC, _102  DEC, _109 DEC, _106 DEC, _127 DEC, _107 DEC, _120 DEC, _114 DEC, _122 DEC)  LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	WITH anexado AS (SELECT entity_id,subdiario,tipo_operacion,tipo_comprobante,fecha_emision,destino,(valor * CASE tipo_moneda WHEN 'USD' THEN (SELECT usd_s FROM tc WHERE fecha_emision = fecha_sunat) ELSE 1 END) AS valor_mn,(otros_cargos * CASE tipo_moneda WHEN 'USD' THEN (SELECT usd_s FROM tc WHERE fecha_emision = fecha_sunat) ELSE 1 END) AS otros_cargos_mn,(CASE tipo_comprobante WHEN 7 THEN (SELECT fecha_emision FROM _5 WHERE cui = (CONCAT(x.subdiario,ltrim(to_char(x.entity_id,'000')),ltrim(to_char(x.tipo_comprobante_modificado,'00')),x.numero_serie_modificado,x.numero_correlativo_modificado))) END) AS fecha_emision_modificado, cui FROM _5 x WHERE periodo_tributario = $1 UNION SELECT entity_id,subdiario,tipo_operacion,tipo_comprobante,fecha_emision,destino,(valor * CASE tipo_moneda WHEN 'USD' THEN (SELECT usd_s FROM tc WHERE fecha_emision = fecha_sunat) ELSE 1 END) AS valor_mn,(otros_cargos * CASE tipo_moneda WHEN 'USD' THEN (SELECT usd_s FROM tc WHERE fecha_emision = fecha_sunat) ELSE 1 END) AS otros_cargos_mn,(CASE tipo_comprobante WHEN 7 THEN (SELECT fecha_emision FROM _8 WHERE cui = CONCAT(y.subdiario,y.numero_documento,ltrim(to_char(y.tipo_comprobante_modificado,'00')),y.numero_serie_modificado,y.numero_correlativo_modificado)) END) AS fecha_emision_modificado, cui FROM _8 y WHERE periodo_tributario = $1) SELECT (SELECT nombre_razon FROM acc.entities WHERE entities.entity_id = anexado.entity_id) AS A,ROUND(COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_comprobante <> 7 AND destino <> 2) THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_comprobante = 7 AND destino <> 2 AND (to_char(fecha_emision_modificado,'YYYYMM')::integer) = $1) THEN valor_mn END),0)) AS B,ROUND(COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_comprobante = 7 AND destino <> 2 AND (to_char(fecha_emision_modificado,'YYYYMM')::integer) < $1) THEN valor_mn END),0)) AS C,ROUND(COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_operacion <> 17 AND tipo_comprobante <> 7 AND destino = 2) THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino = 2) THEN valor_mn END),0) + COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_operacion <> 17 AND tipo_comprobante <> 7 AND destino = 3) THEN otros_cargos_mn END),0) - COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino = 3) THEN otros_cargos_mn END),0)) AS D,ROUND(COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_operacion = 17 AND tipo_comprobante <> 7) THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN (subdiario = 5 AND tipo_operacion = 17 AND tipo_comprobante = 7) THEN valor_mn END),0)) AS E,ROUND(COALESCE(SUM(CASE WHEN subdiario = 5 AND tipo_operacion = 17 AND tipo_comprobante <> 7 AND (to_char((SELECT fecha_embarque FROM itrade WHERE cui_relacionado = cui),'YYYYMM')::integer) = $1 THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 5 AND tipo_operacion = 17 AND tipo_comprobante = 7 AND (to_char((SELECT fecha_embarque FROM itrade WHERE cui_relacionado = cui),'YYYYMM')::integer) = $1 THEN valor_mn END),0)) AS F,ROUND(COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 2 AND tipo_comprobante <> 7 AND destino <> 4 THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 2 AND tipo_comprobante = 7 AND destino <> 4 THEN valor_mn END),0)) AS G,ROUND(COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 2 AND tipo_comprobante <> 7 AND destino = 4 THEN valor_mn END),0) + COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 2 AND tipo_comprobante <> 7 AND destino = 5 THEN otros_cargos_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 2 AND tipo_comprobante = 7 AND destino = 4 THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 2 AND tipo_comprobante = 7 AND destino = 5 THEN otros_cargos_mn END),0)) AS H,ROUND(COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 18 AND tipo_comprobante <> 7 AND destino <> 4 THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 18 AND tipo_comprobante = 7 AND destino <> 4 THEN valor_mn END),0)) AS I,ROUND(COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 18 AND tipo_comprobante <> 7 AND destino = 4 THEN valor_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 18 AND tipo_comprobante = 7 AND destino = 4 THEN valor_mn END),0) + COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 18 AND tipo_comprobante <> 7 AND destino = 5 THEN otros_cargos_mn END),0) - COALESCE(SUM(CASE WHEN subdiario = 8 AND tipo_operacion = 18 AND tipo_comprobante = 7 AND destino = 5 THEN otros_cargos_mn END),0)) AS J FROM anexado GROUP BY A ORDER BY A;
END
$$;

-- Trigger de funcion fill_cui
CREATE TRIGGER b_fill_cui5 BEFORE INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE fill_cui();
CREATE TRIGGER b_fill_cui8 BEFORE INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE fill_cui();
CREATE TRIGGER b_fill_cui8 BEFORE INSERT ON acc._2 FOR EACH ROW EXECUTE PROCEDURE fill_cui();
--Trigger de funcion cash_payment
CREATE TRIGGER pago_caja AFTER INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE cash_payment();
CREATE TRIGGER cobro_caja AFTER INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE cash_payment();
--Trigger de funcion fill_related
CREATE TRIGGER fill_related05 AFTER INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE fill_related();
CREATE TRIGGER fill_related08 AFTER INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE fill_related();
--Trigger de funcion foreing_document
CREATE TRIGGER no_documento  BEFORE INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE foreing_document();
CREATE TRIGGER no_documento  BEFORE INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE foreing_document();
--Trigger de funcion fill_itrade
CREATE TRIGGER rellenar_itrade AFTER INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE fill_itrade();
CREATE TRIGGER rellenar_itrade AFTER INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE fill_itrade();
--Trigger de funcion changes
CREATE TRIGGER registrar_cambios AFTER UPDATE ON acc._1 FOR EACH ROW EXECUTE PROCEDURE changes();
CREATE TRIGGER registrar_cambios AFTER UPDATE ON acc._2 FOR EACH ROW EXECUTE PROCEDURE changes();
CREATE TRIGGER registrar_cambios AFTER UPDATE ON acc._5 FOR EACH ROW EXECUTE PROCEDURE changes();
CREATE TRIGGER registrar_cambios AFTER UPDATE ON acc._8 FOR EACH ROW EXECUTE PROCEDURE changes();
CREATE TRIGGER registrar_cambios AFTER UPDATE ON acc._9 FOR EACH ROW EXECUTE PROCEDURE changes();
CREATE TRIGGER registrar_cambios AFTER UPDATE ON acc._10 FOR EACH ROW EXECUTE PROCEDURE changes();
--Trigger de funcion anulacion_operacion asociadas
CREATE TRIGGER anular_asociados AFTER INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE anulacion_operacion();
CREATE TRIGGER anular_asociados AFTER INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE anulacion_operacion();
--Trigger de funcion update_cui
CREATE TRIGGER updatecui BEFORE UPDATE ON acc._5 FOR EACH ROW EXECUTE PROCEDURE update_cui();
CREATE TRIGGER updatecui BEFORE UPDATE ON acc._8 FOR EACH ROW EXECUTE PROCEDURE update_cui();
CREATE TRIGGER updatecui BEFORE UPDATE ON acc._2 FOR EACH ROW EXECUTE PROCEDURE update_cui();
--Trigger de funcion pre_spot
CREATE TRIGGER prespot AFTER INSERT ON acc._5 FOR EACH ROW EXECUTE PROCEDURE pre_spot();
CREATE TRIGGER prespot AFTER INSERT ON acc._8 FOR EACH ROW EXECUTE PROCEDURE pre_spot();
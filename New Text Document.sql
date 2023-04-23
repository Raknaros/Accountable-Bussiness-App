CREATE TABLE _3 (
	id BIGSERIAL PRIMARY KEY,
	entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,
	subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 1, 
	periodo_tributario INTEGER,
    descripcion VARCHAR,
    glosa VARCHAR,
    tipo_movimiento INTEGER,
    importe DEC(10,2),
    numero_correlativo INTEGER,
    numero_correlativo_comprobante VARCHAR,
    tipo_moneda VARCHAR,
    fecha_emision DATE,
    tipo_comprobante INTEGER,
    cui_relacionado VARCHAR,
    codigo_cuenta VARCHAR,
    centro_costos VARCHAR,
    fecha_vencimiento DATE,
    fecha_contable DATE,
);
----Asientos de diario
CREATE OR REPLACE FUNCTION generar_diario(INTEGER, INTEGER) RETURNS VOID
CREATE FUNCTION 
$$
DECLARE
z RECORD;

BEGIN
CREATE TEMP TABLE diario_temporal ( 
	descripcion VARCHAR,
  	glosa VARCHAR,
    tipo_movimiento INTEGER,
    importe DEC(10,2),
    numero_correlativo INTEGER,
   	numero_correlativo_comprobante VARCHAR,
    tipo_moneda VARCHAR,
    fecha_emision DATE,
    tipo_comprobante INTEGER,
    cui_relacionado VARCHAR,
    codigo_cuenta VARCHAR,
    centro_costos VARCHAR,
    fecha_vencimiento DATE,
    fecha_contable DATE);

FOR z IN (SELECT * FROM _1 WHERE entity_id = $1 AND periodo_tributario = $2) LOOP
	    INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.descripcion, 1, z.valor, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'121211', z.fecha_vencimiento);
    	INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.descripcion, 2, z.valor, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,z.codigo_cuenta, z.fecha_vencimiento);

FOR z IN (SELECT * FROM _2 WHERE entity_id = $1 AND periodo_tributario = $2) LOOP
	    INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.descripcion, 1, z.valor, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'121211', z.fecha_vencimiento);
    	INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa, 2, z.valor, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,z.codigo_cuenta, z.fecha_vencimiento);

FOR z IN (SELECT * FROM _5 WHERE entity_id = $1 AND periodo_tributario = $2) LOOP
   		INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 2 ELSE 1 END),(CASE z.destino WHEN 2 THEN (z.valor + z.otros_cargos + z.isc + z.icbp) ELSE (ROUND(z.valor * 1.18) + z.otros_cargos + z.isc + z.icbp) END), z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'121211', z.fecha_vencimiento);
    	INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 1 ELSE 2 END), z.valor + z.otros_cargos, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui, z.codigo_cuenta, z.fecha_vencimiento);
	IF z.destino != 2 THEN
		INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 1 ELSE 2 END), ROUND((z.valor + z.isc) * 0.18,2), z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'401111', z.fecha_vencimiento);
	END IF;
	IF z.isc != 0 THEN
		INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 1 ELSE 2 END), z.isc, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'401211', z.fecha_vencimiento);
	END IF;
	IF z.icbp != 0 THEN
	INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 1 ELSE 2 END), z.icbp, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'401891', z.fecha_vencimiento);
	END IF;
END LOOP;
FOR z IN (SELECT * FROM _8 WHERE entity_id = $1 AND periodo_tributario = $2) LOOP
		INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 1 ELSE 2 END),(CASE z.destino WHEN 4 THEN (z.valor + z.otros_cargos + z.isc + z.icbp)
		ELSE (ROUND((z.valor + z.isc) * 1.18) + z.otros_cargos + z.icbp)), z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'421211', z.fecha_vencimiento);
    	INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 2 ELSE 1 END), z.valor, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui, z.codigo_cuenta, z.fecha_vencimiento);
	IF z.destino != 4 THEN
		INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 2 ELSE 1 END), ROUND((z.valor + z.isc) * 0.18,2), z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'401111', z.fecha_vencimiento);
	END IF;
	IF z.isc != 0 THEN
		INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 2 ELSE 1 END), z.isc, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'609191', z.fecha_vencimiento);
	END IF;
	IF z.icbp != 0 THEN
	INSERT INTO diario_temporal (descripcion, tipo_movimiento, importe, numero_correlativo_comprobante, tipo_moneda, fecha_emision,cui_relacionado,codigo_cuenta, fecha_vencimiento) VALUES (z.glosa,(CASE z.tipo_comprobante WHEN 7 THEN 2 ELSE 1 END), z.icbp, z.numero_correlativo, z.tipo_moneda, z.fecha_emision,z.cui,'641911', z.fecha_vencimiento);
	END IF;
END LOOP;

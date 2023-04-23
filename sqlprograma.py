from sqlalchemy import create_engine, text, insert
import pandas as pd
import openpyxl
from datetime import datetime
#from guiprograma import dialogin as dia

#def moTor(a,b):
#    motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
#    return motor

#motorSec = moTor(dialogin.usuario,dialogin.contrasena)
motorPrincipal=create_engine('postgresql://admindb:72656770@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')

with motorPrincipal.connect() as conn:

    L5=pd.read_sql_query(text("SELECT tabla, nombre_razon, array_agg(periodo_tributario) AS periodos FROM (SELECT 'Caja' AS tabla, (SELECT nombre_razon FROM entities WHERE entity_id = acc._1.entity_id), periodo_tributario FROM acc._1 WHERE periodo_tributario is not null UNION SELECT 'Bancos' AS tabla, (SELECT nombre_razon FROM entities WHERE entity_id = acc._2.entity_id), periodo_tributario FROM acc._2 WHERE periodo_tributario is not null UNION SELECT 'Ventas' AS tabla, (SELECT nombre_razon FROM entities WHERE entity_id = acc._5.entity_id), periodo_tributario FROM acc._5 WHERE periodo_tributario is not null UNION SELECT 'Compras' AS tabla, (SELECT nombre_razon FROM entities WHERE entity_id = acc._8.entity_id) ,periodo_tributario FROM acc._8 WHERE periodo_tributario is not null GROUP BY periodo_tributario, tabla, nombre_razon) AS prueba WHERE nombre_razon is not null GROUP BY nombre_razon, tabla ORDER BY tabla ASC"), conn)
    L5['periodos']=L5['periodos'].apply(lambda lst: list(map(str, lst)))
    L = (L5.groupby('tabla', sort=False)[['nombre_razon','periodos']].agg(list).reset_index().T.to_numpy().tolist())
    tablaEntidades=pd.read_sql_query(text('SELECT entity_id, nombre_razon, numero_documento, usuario_sol, clave_sol FROM acc.entities ORDER BY entity_id ASC'), conn, 'entity_id')
    comboPLE1 = pd.read_sql_query(text('SELECT prueba.nombre_razon, array_agg(prueba.periodo_tributario) AS periodos FROM (SELECT (SELECT nombre_razon FROM entities WHERE entity_id = acc._5.entity_id), periodo_tributario FROM acc._5 UNION SELECT (SELECT nombre_razon FROM entities WHERE entity_id = acc._8.entity_id), periodo_tributario FROM acc._8 WHERE periodo_tributario is not null GROUP BY periodo_tributario, nombre_razon ORDER BY nombre_razon, periodo_tributario) AS prueba GROUP BY prueba.nombre_razon'),conn)
    comboPLE1['periodos']=comboPLE1['periodos'].apply(lambda lst: list(map(str, lst)))
    comboPLE=comboPLE1.values.tolist()
    listaT=[]
    for i in range(len(comboPLE)):
        listaT=listaT+comboPLE[i][1]
    P=[*set(listaT)]

def app_login(a:str,b:str):
    try:
        motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
        with motor.connect() as con:
            result = con.execute(text("SELECT current_schema()"))
            for row in result:
                return row[0]
    except: return None
def newEntity(ruc:str,usu:str,cla:str,a:str,b:str):
    try:
        motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
        with motor.connect() as conn:
            consulta=conn.execute(text("SELECT count(entity_id) FROM entities"))
            idsig=(consulta.fetchone())[0]+1
        insertar=pd.DataFrame([[idsig,ruc,usu,cla]],columns=["entity_id","numero_documento","usuario_sol","clave_sol"])
        insertar.to_sql('entities', schema = 'acc', con=motor, if_exists='append', index=False)
    except: pass   

def generar_PLE(ent:str,per:str,a:str,b:str):
    motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
    with motor.connect() as conn:
        consulta=conn.execute(text("SELECT numero_documento,entity_id FROM acc.entities WHERE nombre_razon = '"+ent+"'"))
        datos=(consulta.fetchone())
        ruc=datos[0]
        id=str(datos[1])
    try:   
        ple0801=pd.read_sql_query(text("SELECT RPAD(periodo_tributario::text,8,'0') AS Clm_1,cui AS Clm_2,CONCAT('M',(ROW_NUMBER() OVER(ORDER BY fecha_emision))+(SELECT COUNT(l.cuo) FROM acc.ple l WHERE periodo_tributario::text LIKE '"+per[:4]+"____' AND l.codigo_le = '0801' AND entity_id = "+id+")), to_char(fecha_emision, 'DD/MM/YYYY') AS Clm_4,to_char(fecha_vencimiento, 'DD/MM/YYYY') AS Clm_5,to_char(tipo_comprobante, 'fm00') AS Clm_6,lpad(numero_serie, 4,'0') AS Clm_7,(CASE WHEN (tipo_comprobante = 50 OR tipo_comprobante = 52) THEN importe_final ELSE null END) AS Clm_8,numero_correlativo AS Clm_9,importe_final AS Clm_10,tipo_documento AS Clm_11,numero_documento AS Clm_12,(SELECT nombre_razon FROM related WHERE numero_documento = c.numero_documento) AS Clm_13,(CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 1 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 1 THEN (valor * -1) ELSE null END) AS Clm_14,ROUND((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 1 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 1 THEN (valor * -1) ELSE null END) * 0.18,2) AS Clm_15,(CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 2 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 2 THEN (valor * -1) ELSE null END) AS Clm_16,ROUND((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 2 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 2 THEN (valor * -1) ELSE null END) * 0.18,2) AS Clm_17,(CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 3 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 3 THEN (valor * -1) ELSE null END) AS Clm_18,ROUND((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 3 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 3 THEN (valor * -1) ELSE null END) * 0.18,2) AS Clm_19,(CASE WHEN tipo_operacion <> 18 AND destino = 4 THEN valor WHEN tipo_operacion <> 18 AND destino = 5 THEN otros_cargos ELSE null END) AS Clm_20,isc AS Clm_21,icbp AS Clm_22,(CASE WHEN destino <> 5 THEN otros_cargos ELSE null END) AS Clm_23,COALESCE((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 1 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 1 THEN (valor * -1) ELSE null END),0)+COALESCE(ROUND((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 1 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 1 THEN (valor * -1) ELSE null END) * 0.18,2),0)+COALESCE((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 2 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 2 THEN (valor * -1) ELSE null END),0)+COALESCE(ROUND((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 2 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 2 THEN (valor * -1) ELSE null END) * 0.18,2),0)+COALESCE((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 3 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 3 THEN (valor * -1) ELSE null END),0)+COALESCE(ROUND((CASE WHEN tipo_operacion <> 18 AND tipo_comprobante <> 7 AND destino = 3 THEN valor WHEN tipo_operacion <> 18 AND tipo_comprobante = 7 AND destino = 3 THEN (valor * -1) ELSE null END) * 0.18,2),0)+COALESCE((CASE WHEN tipo_operacion <> 18 AND destino = 4 THEN valor WHEN tipo_operacion <> 18 AND destino = 5 THEN otros_cargos ELSE null END),0)+COALESCE(isc,0)+icbp+COALESCE((CASE WHEN destino <> 5 THEN otros_cargos ELSE null END),0) AS Clm_24,tipo_moneda AS Clm_25,ltrim(CASE WHEN tipo_moneda = 'USD' THEN to_char((SELECT usd_s FROM tc WHERE fecha_sunat = fecha_emision), 'l9D999') ELSE to_char(1, 'l9D999') END) AS Clm_26,(SELECT to_char(fecha_emision, 'DD/MM/YYYY') FROM _8 WHERE cui = (CONCAT(c.subdiario,ltrim(to_char(c.entity_id,'000')),ltrim(to_char(c.tipo_comprobante_modificado,'00')),c.numero_serie_modificado,c.numero_correlativo_modificado))) AS Clm_27,to_char(tipo_comprobante_modificado, 'fm00') AS Clm_28,numero_serie_modificado AS Clm_29,(CASE WHEN observaciones LIKE '%dependencia%' AND tipo_operacion = 18 THEN observaciones ELSE null END) AS Clm_30,numero_correlativo_modificado::text AS Clm_31,(CASE WHEN tasa_detraccion IS NOT null THEN (SELECT fecha_operacion FROM acc._2 WHERE cui_relacionado = c.cui AND entidad_financiera = 18) ELSE null END) AS Clm_32,(CASE WHEN tasa_detraccion IS NOT null THEN (SELECT numero_operacion FROM _2 WHERE cui_relacionado = c.cui AND entidad_financiera = 18) ELSE null END) AS Clm_33,(CASE WHEN observaciones LIKE 'retencion' THEN 1 ELSE null END) AS Clm_34,clasificacion_bienes_servicios AS Clm_35,(SELECT observaciones FROM _8 WHERE observaciones LIKE '%contrato%') AS Clm_36,null AS Clm_37,null AS Clm_38,null AS Clm_39,null AS Clm_40,(CASE WHEN (medio_pago <> 9 AND medio_pago <> 8) THEN 1 ELSE null END) AS Clm_41,(CASE WHEN tipo_comprobante = 3 THEN 1 WHEN (tipo_operacion <> 3 AND (to_char(fecha_emision,'YYYYMM')::integer) = "+per+") THEN 1 WHEN (tipo_operacion <> 3 AND (to_char(fecha_emision,'YYYYMM')::integer) < "+per+") THEN 6 WHEN (tipo_operacion <> 3 AND (to_char(fecha_emision + interval '1 year','YYYYMM')::integer) < "+per+") THEN 7 END) AS Clm_42,null AS Clm_43 FROM acc._8 c WHERE entity_id = "+id+" AND periodo_tributario = "+per+" ORDER BY fecha_emision"),motor.connect())
        ple0802=pd.DataFrame()
        ple1401=pd.read_sql_query(text("SELECT RPAD(periodo_tributario::text,8,'0') AS Clm_1,cui AS Clm_2,CONCAT('M',(ROW_NUMBER() OVER(ORDER BY fecha_emision))+(SELECT COUNT(l.cuo) FROM acc.ple l WHERE periodo_tributario::text LIKE '"+per[:4]+"____' AND l.codigo_le = '1401' AND entity_id = "+id+")) AS Clm_3,to_char(fecha_emision, 'DD/MM/YYYY') AS Clm_4,to_char(fecha_vencimiento, 'DD/MM/YYYY') AS Clm_5,to_char(tipo_comprobante, 'fm00') AS Clm_6,lpad(numero_serie, 4, '0') AS Clm_7,numero_correlativo AS Clm_8,numero_final AS Clm_9,tipo_documento AS Clm_10,numero_documento AS Clm_11,(SELECT nombre_razon FROM acc.related WHERE numero_documento = v.numero_documento) AS Clm_12,(CASE WHEN tipo_operacion = 17 AND tipo_comprobante <> 7 THEN valor WHEN tipo_operacion = 17 AND tipo_comprobante = 7 THEN (valor * -1) ELSE null END) AS Clm_13,(CASE WHEN tipo_operacion <> 17 AND tipo_comprobante <> 7 AND destino <> 2 THEN valor WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) = "+per+" THEN (valor * -1) ELSE null END) AS Clm_14,(CASE WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) <> "+per+" THEN (valor * -1) ELSE null END) AS Clm_15,ROUND((CASE WHEN tipo_operacion <> 17 AND tipo_comprobante <> 7 AND destino <> 2 THEN valor WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) = "+per+" THEN (valor * -1) ELSE null END) * 0.18,2) AS Clm_16,ROUND((CASE WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) <> "+per+" THEN (valor * -1) ELSE null END) * 0.18,2) AS Clm_17,(CASE WHEN tipo_operacion <> 17 AND destino = 2 THEN valor WHEN tipo_operacion <> 17 AND destino = 3 THEN otros_cargos ELSE null END) AS Clm_18,(CASE WHEN (tipo_operacion <> 17 AND destino = 2 AND observaciones LIKE '%inafecto%') THEN valor ELSE null END) AS Clm_19,isc AS Clm_20,(CASE WHEN tipo_comprobante = 6 THEN valor ELSE null END) AS Clm_21,ROUND((CASE WHEN tipo_comprobante = 6 THEN valor ELSE null END) * 0.18,2) AS Clm_22,icbp AS Clm_23,(CASE WHEN tipo_operacion <> 17 AND destino <> 3 THEN otros_cargos ELSE null END) AS Clm_24,COALESCE((CASE WHEN tipo_operacion = 17 AND tipo_comprobante <> 7 THEN valor WHEN tipo_operacion = 17 AND tipo_comprobante = 7 THEN (valor * -1) ELSE null END),0)+COALESCE((CASE WHEN tipo_operacion <> 17 AND tipo_comprobante <> 7 AND destino <> 2 THEN valor WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) = "+per+" THEN (valor * -1) ELSE null END),0)+COALESCE((CASE WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) <> "+per+" THEN (valor * -1) ELSE null END),0)+COALESCE(ROUND((CASE WHEN tipo_operacion <> 17 AND tipo_comprobante <> 7 AND destino <> 2 THEN valor WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) = "+per+" THEN (valor * -1) ELSE null END) * 0.18,2),0)+COALESCE(ROUND((CASE WHEN tipo_operacion <> 17 AND tipo_comprobante = 7 AND destino <> 2 AND (SELECT (to_char(fecha_emision,'YYYYMM')::integer) FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) <> "+per+" THEN (valor * -1) ELSE null END) * 0.18,2),0)+COALESCE((CASE WHEN tipo_operacion <> 17 AND destino = 2 THEN valor WHEN tipo_operacion <> 17 AND destino = 3 THEN otros_cargos ELSE null END),0)+COALESCE((CASE WHEN (tipo_operacion <> 17 AND destino = 2 AND observaciones LIKE '%inafecto%') THEN valor ELSE null END),0)+COALESCE(isc,0)+COALESCE((CASE WHEN tipo_comprobante = 6 THEN valor ELSE null END),0)+COALESCE(ROUND((CASE WHEN tipo_comprobante = 6 THEN valor ELSE null END) * 0.18,2),0)+icbp+COALESCE((CASE WHEN tipo_operacion <> 17 AND destino <> 3 THEN otros_cargos ELSE null END),0) AS Clm_25,tipo_moneda AS Clm_26,ltrim(CASE WHEN tipo_moneda = 'USD' THEN to_char((SELECT usd_s FROM tc WHERE fecha_sunat = fecha_emision), 'l9D999') ELSE to_char(1, 'l9D999') END) AS Clm_27,(SELECT to_char(fecha_emision, 'DD/MM/YYYY') FROM _5 WHERE cui = (CONCAT(v.subdiario,ltrim(to_char(v.entity_id,'000')),ltrim(to_char(v.tipo_comprobante_modificado,'00')),v.numero_serie_modificado,v.numero_correlativo_modificado))) AS Clm_28,to_char(tipo_comprobante_modificado, 'fm00') AS Clm_29,numero_serie_modificado::text AS Clm_30, numero_correlativo_modificado AS Clm_31,(SELECT observaciones FROM acc._5 WHERE observaciones LIKE '%contrato%') AS Clm_32,null AS Clm_33,(CASE WHEN (medio_pago <> 9 AND medio_pago <> 8) THEN 1 ELSE null END) AS Clm_33,(CASE WHEN (tipo_operacion = 0 AND (to_char(fecha_emision,'YYYYMM')::integer) = "+per+") THEN '0' WHEN (tipo_operacion <> 0 AND (to_char(fecha_emision,'YYYYMM')::integer) = "+per+") THEN '1' WHEN fecha_emision IS null THEN '2' END) AS Clm_34, null AS Clm_35 FROM acc._5 v WHERE entity_id = "+id+" AND periodo_tributario = "+per),motor.connect())
        ple0801.to_csv('D:\\LE'+ruc+per+'00080100001111.txt', header=None, index=None, sep='|', mode='a')
        ple0802.to_csv('D:\\LE'+ruc+per+'00080200001011.txt', header=None, index=None, sep='|', mode='a')
        ple1401.to_csv('D:\\LE'+ruc+per+'00140100001111.txt', header=None, index=None, sep='|', mode='a')
    except: pass

def generar_PDB(ent:str,per:str,a:str,b:str):
    pass

def export_data(tabla:str,ent:str,per:str,a:str,b:str):
    motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
    try: 
        export_dict = {'Caja':'_1','Bancos':'_2','Diario':'_3','Planilla':'_4','Ventas':'_5','Inventario':'_6','Compras':'_8'}
        export_df = pd.read_sql_query(text("SELECT * FROM acc."+export_dict[tabla]+" WHERE entity_id = (SELECT entity_id FROM entities x WHERE x.nombre_razon = '"+ent+"') AND periodo_tributario = "+per), motor.connect(), 'cui')
        export_df.to_excel("D:\\"+tabla+"."+datetime.now().strftime("%H_%M_%S")+".xlsx",freeze_panes=[1,0])
    #return len(export_df.index)
    except: pass

def import_data(tabla:str,a:str,b:str):
    motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
    try:
        import_dict = {'Caja':['_1',[4,],'1'],'Bancos':['_2',[7,],'2'],'Diario':['_3',[2,],'3'],'Planilla':['_4',[2,],'4'],'Ventas':['_5',[2,],'5'],'Inventario':['_6',[2,],'6'],'Compras':['_8',[2,],'8']}
        import_df = pd.read_excel('D:\\upload.xlsx', header=0, sheet_name=import_dict[tabla][2], parse_dates=import_dict[tabla][1])
        import_df.replace("", float("NaN"), inplace=True)
        import_df.dropna(how='all', axis=1, inplace=True)
        import_df.to_sql(import_dict[tabla][0], schema = 'acc', con=motor, if_exists='append', index=False)
    except: pass

def preliquidacion(per:str,a:str,b:str):
    motor=create_engine('postgresql://'+str(a)+':'+str(b)+'@impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com/impulsadb')
    try:
        export_df = pd.read_sql_query(text("SELECT * FROM preliquidacion_general(202109)"), motor.connect())
        export_df.to_excel("D:\\preliquidacion."+datetime.now().strftime("%H_%M_%S")+".xlsx",freeze_panes=[1,0], index=False)
    except: pass



#Opciones de display filas y columnas
#pd.options.display.max_rows = 9999
#pd.options.display.max_columns = 9999

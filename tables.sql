CREATE TABLE acc.tablas (codigo VARCHAR UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts01 (medio_pago INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts02 (tipo_documento VARCHAR UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts03 (entidad_financiera INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts04 (tipo_moneda VARCHAR UNIQUE,descripcion VARCHAR,zona_referencia VARCHAR);
CREATE TABLE acc.ts05 (tipo_existencia INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts06 (unidad_medida VARCHAR UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts07 (tipo_intangible INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts10 (tipo_comprobante INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts11 (codigo_aduana INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts12 (tipo_operacion INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts14 (metodo_valuacion INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts15 (tipo_titulo INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts16 (tipo_acciones INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts17 (tipo_plan_cuentas INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts18 (tipo_activo_fijo INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts19 (estado_activo_fijo INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts20 (metodo_depreciacion INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts21 (agrupamiento_costo_produccion_anual INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts22 (catalogo_estados_financieros INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts25 (convenio_doble_tributacion INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts27 (vinculacion_economica INTEGER UNIQUE,descripcion VARCHAR,articulo_ley VARCHAR);
CREATE TABLE acc.ts30 (clasificacion_bienes_servicios INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts31 (tipo_renta INTEGER UNIQUE,descripcion VARCHAR,articulo_ley VARCHAR,codigo_ocde VARCHAR);
CREATE TABLE acc.ts32 (servicio_nodomiciliado INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts33 (exoneraciones_nodomiciliado INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts34 (rubro_estados_financieros VARCHAR UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ts35 (paises INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.ta10 (codigo_tributo INTEGER UNIQUE,descripcion VARCHAR);
CREATE TABLE acc.spot (codigo INTEGER UNIQUE,descripcion VARCHAR,tasa DEC(3,2));
CREATE TABLE acc.entities (entity_id INTEGER PRIMARY KEY UNIQUE,nombre_razon VARCHAR UNIQUE,numero_documento VARCHAR UNIQUE,telefono INTEGER,email VARCHAR,domicilio_fiscal VARCHAR,distrito TEXT,ciudad TEXT,departamento TEXT,codigo_postal INTEGER,usuario_sol VARCHAR,clave_sol VARCHAR);
CREATE TABLE acc.related (tipo_documento VARCHAR,numero_documento VARCHAR UNIQUE,nombre_razon VARCHAR UNIQUE,cuenta_detracciones BIGINT UNIQUE);
CREATE TABLE acc.subdiary (codigo INTEGER UNIQUE,subdiario TEXT UNIQUE);
CREATE TABLE acc.tc (fecha_sbs DATE NOT NULL,fecha_sunat DATE NOT NULL,usd_b DEC(5,3),usd_s DEC(5,3),eur_b DEC(5,3),eur_s DEC(5,3));
CREATE TABLE acc.changeslog (usuario VARCHAR,subdiario INT,id BIGINT,instante TIMESTAMP);
CREATE TABLE acc.itrade (tipo_operacion INTEGER REFERENCES TS12(tipo_operacion) ON DELETE SET NULL,cui_relacionado VARCHAR NOT NULL,codigo_aduana INTEGER REFERENCES ts11(codigo_aduana) ON DELETE SET NULL,periodo_tributario INTEGER,numero_correlativo INTEGER,fecha_numeracion DATE,fecha_embarque DATE,fecha_regularizacion DATE,valor_fob DEC(12,2),peso_neto DEC(12,2));
CREATE TABLE acc._1 (
	id BIGSERIAL PRIMARY KEY,
	entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,
	subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 1, 
	periodo_tributario INTEGER,
	tipo_movimiento INTEGER,
	codigo_cuenta INTEGER,
	fecha_operacion DATE,
	importe DEC(10,2),
	tipo_moneda VARCHAR REFERENCES TS04(tipo_moneda) ON DELETE SET NULL,
	descripcion VARCHAR,
	glosa VARCHAR,
	observaciones VARCHAR,
	cui_relacionado VARCHAR);
CREATE TABLE acc._2 (
	id BIGSERIAL PRIMARY KEY,
	entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,
	subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 2,
	periodo_tributario INTEGER,
	tipo_movimiento INTEGER,
	entidad_financiera INTEGER REFERENCES TS03(entidad_financiera) ON DELETE SET NULL,
	codigo_cuenta INTEGER,
	numero_cuenta_relacionada BIGINT,
	medio_pago INTEGER REFERENCES TS01(medio_pago) ON DELETE SET NULL,
	fecha_operacion DATE,
	numero_operacion BIGINT,
	importe DEC(10,2),
	tipo_moneda VARCHAR REFERENCES TS04(tipo_moneda) ON DELETE SET NULL,
	descripcion VARCHAR,
	glosa VARCHAR,
	cui VARCHAR UNIQUE,
	cui_relacionado VARCHAR,
	observaciones VARCHAR);
CREATE TABLE acc._3 (
);
CREATE TABLE acc._4 (
);
CREATE TABLE acc._5 (
	id BIGSERIAL PRIMARY KEY,
	entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,
	subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 5,
	periodo_tributario INTEGER,
	tipo_operacion INTEGER REFERENCES TS12(tipo_operacion) ON DELETE SET NULL,
	tipo_comprobante INTEGER REFERENCES TS10(tipo_comprobante) ON DELETE SET NULL,
	fecha_emision DATE,
	fecha_vencimiento DATE,
	numero_serie VARCHAR,
	numero_correlativo VARCHAR,
	numero_final INTEGER,
	tipo_documento VARCHAR REFERENCES TS02(tipo_documento) ON DELETE SET NULL,
	numero_documento VARCHAR,
	destino INTEGER,
	valor DEC(10,2),
	icbp DEC(3,2) DEFAULT 0,
	isc DEC(6,2) DEFAULT 0,
	otros_cargos DEC(8,2) DEFAULT 0,
	tipo_moneda VARCHAR REFERENCES TS04(tipo_moneda) ON DELETE SET NULL,
	tasa_detraccion INTEGER REFERENCES acc.spot(codigo) ON DELETE SET NULL,
	tasa_percepcion INTEGER,
	medio_pago INTEGER REFERENCES TS01(medio_pago) ON DELETE SET NULL,
	tipo_comprobante_modificado INTEGER,
	numero_serie_modificado VARCHAR,
	numero_correlativo_modificado INTEGER,
	glosa VARCHAR,
	cui VARCHAR UNIQUE,
	observaciones VARCHAR,
	codigo_cuenta INTEGER,
	fecha_cuota1 DATE,importe_cuota1 DEC(10,2),fecha_cuota2 DATE,importe_cuota2 DEC(10,2),fecha_cuota3 DATE,importe_cuota3 DEC(10,2),fecha_cuota4 DATE,importe_cuota4 DEC(10,2),fecha_cuota5 DATE,importe_cuota5 DEC(10,2),fecha_cuota6 DATE,importe_cuota6 DEC(10,2),fecha_cuota7 DATE,importe_cuota7 DEC(10,2),fecha_cuota8 DATE,importe_cuota8 DEC(10,2),fecha_cuota9 DATE,importe_cuota9 DEC(10,2),fecha_cuota10 DATE,importe_cuota10 DEC(10,2),fecha_cuota11 DATE,importe_cuota11 DEC(10,2),fecha_cuota12 DATE,importe_cuota12 DEC(10,2),fecha_cuota13 DATE,importe_cuota13 DEC(10,2),fecha_cuota14 DATE,importe_cuota14 DEC(10,2),fecha_cuota15 DATE,importe_cuota15 DEC(10,2),fecha_cuota16 DATE,importe_cuota16 DEC(10,2),fecha_cuota17 DATE,importe_cuota17 DEC(10,2),fecha_cuota18 DATE,importe_cuota18 DEC(10,2),fecha_cuota19 DATE,importe_cuota19 DEC(10,2),fecha_cuota20 DATE,importe_cuota20 DEC(10,2),fecha_cuota21 DATE,importe_cuota21 DEC(10,2),fecha_cuota22 DATE,importe_cuota22 DEC(10,2),fecha_cuota23 DATE,importe_cuota23 DEC(10,2),fecha_cuota24 DATE,importe_cuota24 DEC(10,2),fecha_cuota25 DATE,importe_cuota25 DEC(10,2),fecha_cuota26 DATE,importe_cuota26 DEC(10,2),fecha_cuota27 DATE,importe_cuota27 DEC(10,2),fecha_cuota28 DATE,importe_cuota28 DEC(10,2),fecha_cuota29 DATE,importe_cuota29 DEC(10,2),fecha_cuota30 DATE,importe_cuota30 DEC(10,2),fecha_cuota31 DATE,importe_cuota31 DEC(10,2),fecha_cuota32 DATE,importe_cuota32 DEC(10,2),fecha_cuota33 DATE,importe_cuota33 DEC(10,2),fecha_cuota34 DATE,importe_cuota34 DEC(10,2),fecha_cuota35 DATE,importe_cuota35 DEC(10,2),fecha_cuota36 DATE,importe_cuota36 DEC(10,2),fecha_cuota37 DATE,importe_cuota37 DEC(10,2),fecha_cuota38 DATE,importe_cuota38 DEC(10,2),fecha_cuota39 DATE,importe_cuota39 DEC(10,2),fecha_cuota40 DATE,importe_cuota40 DEC(10,2),fecha_cuota41 DATE,importe_cuota41 DEC(10,2),fecha_cuota42 DATE,importe_cuota42 DEC(10,2),fecha_cuota43 DATE,importe_cuota43 DEC(10,2),fecha_cuota44 DATE,importe_cuota44 DEC(10,2),fecha_cuota45 DATE,importe_cuota45 DEC(10,2),fecha_cuota46 DATE,importe_cuota46 DEC(10,2),fecha_cuota47 DATE,importe_cuota47 DEC(10,2),fecha_cuota48 DATE,importe_cuota48 DEC(10,2),fecha_cuota49 DATE,importe_cuota49 DEC(10,2),fecha_cuota50 DATE,importe_cuota50 DEC(10,2),fecha_cuota51 DATE,importe_cuota51 DEC(10,2),fecha_cuota52 DATE,importe_cuota52 DEC(10,2),fecha_cuota53 DATE,importe_cuota53 DEC(10,2),fecha_cuota54 DATE,importe_cuota54 DEC(10,2),fecha_cuota55 DATE,importe_cuota55 DEC(10,2),fecha_cuota56 DATE,importe_cuota56 DEC(10,2),fecha_cuota57 DATE,importe_cuota57 DEC(10,2),fecha_cuota58 DATE,importe_cuota58 DEC(10,2),fecha_cuota59 DATE,importe_cuota59 DEC(10,2),fecha_cuota60 DATE,importe_cuota60 DEC(10,2));
CREATE TABLE acc._6 (
	id BIGSERIAL PRIMARY KEY,
	entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,
	subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 8, 
	periodo_tributario INTEGER,
	tipo_operacion INTEGER,
	fecha_ingreso DATE,
	clasificacion_bienes_servicios INTEGER REFERENCES TS30(clasificacion_bienes_servicios) ON DELETE SET NULL,
	codigo_item VARCHAR,
	descripcion VARCHAR,
	unidad_medida VARCHAR,
	cantidad INTEGER,
	precio_unitario	valor DEC(10,2),
	tipo_documento_referencia INTEGER REFERENCES TS10(tipo_comprobante) ON DELETE SET NULL,
	numero_documento_referencia VARCHAR,
	observaciones VARCHAR,
	codigo_cuenta INTEGER,
	cui_relacionado VARCHAR
);
CREATE TABLE acc._7 (
);
CREATE TABLE acc._8 (
	id BIGSERIAL PRIMARY KEY,
	entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,
	subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 8, 
	periodo_tributario INTEGER,
	tipo_operacion INTEGER REFERENCES TS12(tipo_operacion) ON DELETE SET NULL,
	tipo_comprobante INTEGER REFERENCES TS10(tipo_comprobante) ON DELETE SET NULL,
	fecha_emision DATE,
	fecha_vencimiento DATE,
	numero_serie VARCHAR,
	numero_correlativo VARCHAR,
	importe_final INTEGER,
	tipo_documento VARCHAR REFERENCES TS02(tipo_documento) ON DELETE SET NULL,
	numero_documento VARCHAR,
	clasificacion_bienes_servicios INTEGER REFERENCES TS30(clasificacion_bienes_servicios) ON DELETE SET NULL,
	destino INTEGER,
	valor DEC(10,2),
	icbp DEC(3,2) DEFAULT 0,
	isc DEC(8,2) DEFAULT 0,
	otros_cargos DEC(8,2) DEFAULT 0,
	tipo_moneda VARCHAR REFERENCES TS04(tipo_moneda) ON DELETE SET NULL,
	tasa_detraccion INTEGER REFERENCES spot(codigo) ON DELETE SET NULL,
	tasa_percepcion INTEGER,
	medio_pago INTEGER REFERENCES TS01(medio_pago) ON DELETE SET NULL,
	tipo_comprobante_modificado INTEGER,
	numero_serie_modificado VARCHAR,
	numero_correlativo_modificado INTEGER,
	glosa VARCHAR,
	cui VARCHAR UNIQUE,
	observaciones VARCHAR,
	codigo_cuenta INTEGER,
	fecha_cuota1 DATE,importe_cuota1 DEC(10,2),fecha_cuota2 DATE,importe_cuota2 DEC(10,2),fecha_cuota3 DATE,importe_cuota3 DEC(10,2),fecha_cuota4 DATE,importe_cuota4 DEC(10,2),fecha_cuota5 DATE,importe_cuota5 DEC(10,2),fecha_cuota6 DATE,importe_cuota6 DEC(10,2),fecha_cuota7 DATE,importe_cuota7 DEC(10,2),fecha_cuota8 DATE,importe_cuota8 DEC(10,2),fecha_cuota9 DATE,importe_cuota9 DEC(10,2),fecha_cuota10 DATE,importe_cuota10 DEC(10,2),fecha_cuota11 DATE,importe_cuota11 DEC(10,2),fecha_cuota12 DATE,importe_cuota12 DEC(10,2),fecha_cuota13 DATE,importe_cuota13 DEC(10,2),fecha_cuota14 DATE,importe_cuota14 DEC(10,2),fecha_cuota15 DATE,importe_cuota15 DEC(10,2),fecha_cuota16 DATE,importe_cuota16 DEC(10,2),fecha_cuota17 DATE,importe_cuota17 DEC(10,2),fecha_cuota18 DATE,importe_cuota18 DEC(10,2),fecha_cuota19 DATE,importe_cuota19 DEC(10,2),fecha_cuota20 DATE,importe_cuota20 DEC(10,2),fecha_cuota21 DATE,importe_cuota21 DEC(10,2),fecha_cuota22 DATE,importe_cuota22 DEC(10,2),fecha_cuota23 DATE,importe_cuota23 DEC(10,2),fecha_cuota24 DATE,importe_cuota24 DEC(10,2),fecha_cuota25 DATE,importe_cuota25 DEC(10,2),fecha_cuota26 DATE,importe_cuota26 DEC(10,2),fecha_cuota27 DATE,importe_cuota27 DEC(10,2),fecha_cuota28 DATE,importe_cuota28 DEC(10,2),fecha_cuota29 DATE,importe_cuota29 DEC(10,2),fecha_cuota30 DATE,importe_cuota30 DEC(10,2),fecha_cuota31 DATE,importe_cuota31 DEC(10,2),fecha_cuota32 DATE,importe_cuota32 DEC(10,2),fecha_cuota33 DATE,importe_cuota33 DEC(10,2),fecha_cuota34 DATE,importe_cuota34 DEC(10,2),fecha_cuota35 DATE,importe_cuota35 DEC(10,2),fecha_cuota36 DATE,importe_cuota36 DEC(10,2),fecha_cuota37 DATE,importe_cuota37 DEC(10,2),fecha_cuota38 DATE,importe_cuota38 DEC(10,2),fecha_cuota39 DATE,importe_cuota39 DEC(10,2),fecha_cuota40 DATE,importe_cuota40 DEC(10,2),fecha_cuota41 DATE,importe_cuota41 DEC(10,2),fecha_cuota42 DATE,importe_cuota42 DEC(10,2),fecha_cuota43 DATE,importe_cuota43 DEC(10,2),fecha_cuota44 DATE,importe_cuota44 DEC(10,2),fecha_cuota45 DATE,importe_cuota45 DEC(10,2),fecha_cuota46 DATE,importe_cuota46 DEC(10,2),fecha_cuota47 DATE,importe_cuota47 DEC(10,2),fecha_cuota48 DATE,importe_cuota48 DEC(10,2),fecha_cuota49 DATE,importe_cuota49 DEC(10,2),fecha_cuota50 DATE,importe_cuota50 DEC(10,2),fecha_cuota51 DATE,importe_cuota51 DEC(10,2),fecha_cuota52 DATE,importe_cuota52 DEC(10,2),fecha_cuota53 DATE,importe_cuota53 DEC(10,2),fecha_cuota54 DATE,importe_cuota54 DEC(10,2),fecha_cuota55 DATE,importe_cuota55 DEC(10,2),fecha_cuota56 DATE,importe_cuota56 DEC(10,2),fecha_cuota57 DATE,importe_cuota57 DEC(10,2),fecha_cuota58 DATE,importe_cuota58 DEC(10,2),fecha_cuota59 DATE,importe_cuota59 DEC(10,2),fecha_cuota60 DATE,importe_cuota60 DEC(10,2));
CREATE TABLE acc._9 (id BIGSERIAL PRIMARY KEY,entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 9,periodo_tributario INTEGER,numero_orden BIGINT UNIQUE,fecha_presentacion DATE,_100 INTEGER,_101 INTEGER,_102 INTEGER,_103 INTEGER,_160 INTEGER,_161 INTEGER,_162 INTEGER,_163 INTEGER,_106 INTEGER,_127 INTEGER,_105 INTEGER,_109 INTEGER,_112 INTEGER,_107 INTEGER,_108 INTEGER,_110 INTEGER,_111 INTEGER,_113 INTEGER,_114 INTEGER,_115 INTEGER,_116 INTEGER,_117 INTEGER,_119 INTEGER,_120 INTEGER,_122 INTEGER,_172 INTEGER,_169 INTEGER,_173 FLOAT,_340 INTEGER,_341 INTEGER,_182 INTEGER,_301 INTEGER,_312 INTEGER,_380 FLOAT,_315 FLOAT,_140 INTEGER,_145 INTEGER,_184 INTEGER,_171 INTEGER,_168 INTEGER,_164 INTEGER,_179 INTEGER,_176 INTEGER,_165 INTEGER,_681 INTEGER,_185 INTEGER,_187 INTEGER,_188 INTEGER,_353 INTEGER,_351 INTEGER,_352 INTEGER,_347 INTEGER,_683 INTEGER,_342 INTEGER,_343 INTEGER,_344 INTEGER,_302 INTEGER,_303 INTEGER,_304 INTEGER,_326 INTEGER,_327 INTEGER,_305 INTEGER,_328 INTEGER,_682 INTEGER,_317 INTEGER,_319 INTEGER,_324 INTEGER);
CREATE TABLE acc._10 (id BIGSERIAL PRIMARY KEY,entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 10,periodo_tributario INTEGER,numero_formulario VARCHAR,numero_orden BIGINT UNIQUE,descripcion VARCHAR,entidad_financiera INTEGER REFERENCES TS03(entidad_financiera) ON DELETE SET NULL,fecha_presentacion DATE,codigo_tributo INTEGER,detalle VARCHAR,importe DEC(10,2));
CREATE TABLE acc.ple(entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,periodo_tributario INTEGER,cuo VARCHAR,correlativo_asiento_contable VARCHAR, cui_relacionado VARCHAR, codigo_le VARCHAR);
CREATE TABLE acc._11 (id BIGSERIAL PRIMARY KEY, entity_id INTEGER REFERENCES entities(entity_id) ON DELETE SET NULL,subdiario INTEGER REFERENCES subdiary(codigo) ON DELETE SET NULL DEFAULT 9,periodo_tributario INTEGER,numero_orden BIGINT UNIQUE,fecha_presentacion DATE,_359 INTEGER,_360 INTEGER,_361 INTEGER,_362 INTEGER,_363 INTEGER,_364 INTEGER,_365 INTEGER,_366 INTEGER,_367 INTEGER,_368 INTEGER,_369 INTEGER,_370 INTEGER,_371 INTEGER,_372 INTEGER,_373 INTEGER,_374 INTEGER,_375 INTEGER,_376 INTEGER,_377 INTEGER,_378 INTEGER,_379 INTEGER,_380 INTEGER,_381 INTEGER,_382 INTEGER,_383 INTEGER,_384 INTEGER,_385 INTEGER,_386 INTEGER,_387 INTEGER,_388 INTEGER,_389 INTEGER,_390 INTEGER,_401 INTEGER,_402 INTEGER,_403 INTEGER,_404 INTEGER,_405 INTEGER,_406 INTEGER,_407 INTEGER,_408 INTEGER,_409 INTEGER,_410 INTEGER,_411 INTEGER,_412 INTEGER,_413 INTEGER,_414 INTEGER,_415 INTEGER,_416 INTEGER,_417 INTEGER,_418 INTEGER,_419 INTEGER,_420 INTEGER,_421 INTEGER,_422 INTEGER,_423 INTEGER,_424 INTEGER,_425 INTEGER,_426 INTEGER,_461 INTEGER,_462 INTEGER,_463 INTEGER,_464 INTEGER,_466 INTEGER,_467 INTEGER,_468 INTEGER,_469 INTEGER,_470 INTEGER,_471 INTEGER,_472 INTEGER,_473 INTEGER,_475 INTEGER,_476 INTEGER,_477 INTEGER,_478 INTEGER,_480 INTEGER,_484 INTEGER,_485 INTEGER,_486 INTEGER,_487 INTEGER,_489 INTEGER,_490 INTEGER,_492 INTEGER,_493 INTEGER,_100 INTEGER,_101 INTEGER,_103 INTEGER,_105 INTEGER,_106 INTEGER,_107 INTEGER,_120 INTEGER,_108 INTEGER,_110 INTEGER,_113 INTEGER,_111 INTEGER,_610 DEC(4,3),_686 DEC(8,6),_123 INTEGER,_136 INTEGER,_134 INTEGER,_126 INTEGER,_125 INTEGER,_504 INTEGER,_127 INTEGER,_128 INTEGER,_130 INTEGER,_129 INTEGER,_506 INTEGER,_131 INTEGER,_279 INTEGER,_137 INTEGER,_138 INTEGER,_139 INTEGER,_505 INTEGER,_141 INTEGER,_144 INTEGER,_145 INTEGER,_146 INT,_180 INT);
CREATE TABLE acc.0710(casilla smallint PRIMARY KEY, concepto VARCHAR);

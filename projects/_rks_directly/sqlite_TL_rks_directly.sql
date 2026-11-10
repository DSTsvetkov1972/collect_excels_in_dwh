--======================================================================
-- Запускается в той базе, в которой нужно создать таблицу rks_directly
--======================================================================

--DETACH raw;
ATTACH 'E:\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\RAW.db' AS raw;

DROP TABLE IF EXISTS _rks_directly;


-- SELECT * FROM _rks_directly
CREATE TABLE _rks_directly AS
SELECT
	Исходник,"Строка в исходнике",document_id,row_id,row_total,document_number,
	client_number_id,
	contract_id,contract_number,contract_organization,
	service_details_acted_date,
	/*CAST(
		concat(
			substring(service_details_acted_date, 7, 4), '-',
			substring(service_details_acted_date, 4, 2), '-',
			substring(service_details_acted_date, 1, 2)
		) AS TEXT
	) AS service_details_acted_date,*/
	service_details_provision_date,
	/*
		concat(
			substring(service_details_provision_date, 7, 4), '-',
			substring(service_details_provision_date, 4, 2), '-',
			substring(service_details_provision_date, 1, 2)
		) AS service_details_provision_date,
	*/
	service_details_order_id,
	------------------------------------------------------------------------
	service_details_points_from_catalog_id,
	service_details_points_from_station_id,
	------------------------------------------------------------------------	
	service_details_points_to_catalog_id,	
	service_details_points_to_station_id,	
	service_details_container_number,
	service_details_container_type,service_details_container_owner,
	service_details_wagon_number,
	service_details_wagon_owner,
	items_etsng_id,
	items_gng_id,
	items_weight,
	--date_end,
	CAST(
		concat(
			substring(date_end, 7, 4), '-',
			substring(date_end, 4, 2), '-',
			substring(date_end, 1, 2)
		) AS TEXT
	) AS date_end,	
	epu_id,
	esu_id,
	class_id,provider_contract_id,order_manager,wagon_container,
	--amount_in_contract_currency_with_vat
	CAST(REPLACE(amount_in_contract_currency_with_vat, ',', '.') AS REAL) AS amount_in_contract_currency_with_vat,
	-amount_in_contract_currency_vat,
	CAST(REPLACE(amount_in_contract_currency_vat, ',', '.') AS REAL) AS amount_in_contract_currency_vat,	
	--amount_in_contract_currency_without_vat,
	CAST(REPLACE(amount_in_contract_currency_without_vat, ',', '.') AS REAL) AS amount_in_contract_currency_without_vat,
	--amount_in_contract_currency_buy,
	CAST(REPLACE(amount_in_contract_currency_buy, ',', '.') AS REAL) AS amount_in_contract_currency_buy,	
	--amount_in_rub_with_vat,
	CAST(REPLACE(amount_in_rub_with_vat, ',', '.') AS REAL) AS amount_in_rub_with_vat,
	--amount_in_rub_vat,
	CAST(REPLACE(amount_in_rub_vat, ',', '.') AS REAL) AS amount_in_rub_vat,	
	--amount_in_rub_without_vat,
	CAST(REPLACE(amount_in_rub_without_vat, ',', '.') AS REAL) AS amount_in_rub_without_vat,	
	--amount_in_rub_buy,
	CAST(REPLACE(amount_in_rub_buy, ',', '.') AS REAL) AS amount_in_rub_buy,	
	--amount_in_rub_adjusted_revenue,
	CAST(REPLACE(amount_in_rub_adjusted_revenue, ',', '.') AS REAL) AS amount_in_rub_adjusted_revenue,	
	additional_route_mode_id,
	departure_date,
	/*CAST(
		concat(
			substring(departure_date, 7, 4), '-',
			substring(departure_date, 4, 2), '-',
			substring(departure_date, 1, 2)
		) AS TEXT
	) AS departure_date,*/
	shipment_date,
	/*CAST(
		concat(
			substring(shipment_date, 7, 4), '-',
			substring(shipment_date, 4, 2), '-',
			substring(shipment_date, 1, 2)
		) AS TEXT
	) AS shipment_date,*/
	document_reasons_name,
	document_reasons_number,
	departure_kind,route_legs_type,service_provision_place_filial_name,service_provision_place_filial_id,service_provision_place_division_name,service_provision_place_division_id,service_provision_place_location_name,service_provision_place_location_external_id,account_item,account_item_code,sub_code,tariff_epu,esu_payer_name,esu_payer_id,epu_payer_name,epu_payer_id,is_coexecutor_wagon,is_agency_wagon,wagon_owner_name,wagon_owner_id,container_owner_name,container_owner_id,transport_solution_country_from_id,transport_solution_country_to_id,transport_solution_location_in_name,transport_solution_location_in_id,transport_solution_location_out_name,transport_solution_location_out_id,transport_solution_total_distance,"_ЗаписьУдалена"
FROM
	raw_rks_directly;


DROP INDEX IF EXISTS `ndx__rks_directly__service_details_order_id`;
CREATE INDEX `ndx__rks_directly__service_details_order_id` ON _rks_directly (`service_details_order_id`);


DROP INDEX IF EXISTS `ndx__rks_directly__service_details_wagon_number`;
CREATE INDEX `ndx__rks_directly__service_details_wagon_number` ON _rks_directly (`service_details_wagon_number`);


DROP INDEX IF EXISTS `ndx__rks_directly__service_details_container_number`;
CREATE INDEX `ndx__rks_directly__service_details_container_number` ON _rks_directly (`service_details_container_number`);


DROP INDEX IF EXISTS `ndx__rks_directly__date_end`;
CREATE INDEX `ndx__rks_directly__date_end` ON _rks_directly (`date_end`);


ATTACH 'E:\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\CATALOG.db' AS ctlg;


DROP TABLE IF EXISTS _ctlg_service;
CREATE TABLE _ctlg_service AS SELECT * FROM ctlg.psql_db_catalog__catalog_service_jsn_csv;

DROP INDEX IF EXISTS ndx__ctlg_service__catalog_id;
CREATE INDEX ndx__ctlg_service__catalog_id ON _ctlg_service(catalog_id);


DROP TABLE IF EXISTS _ctlg_location;
CREATE TABLE _ctlg_location AS SELECT * FROM ctlg.psql_db_catalog__catalog_location_csv;

DROP INDEX IF EXISTS ndx__ctlg_location__id;
CREATE INDEX ndx__ctlg_location__id ON _ctlg_location(id);


DROP TABLE IF EXISTS _ctlg_etsng;
CREATE TABLE _ctlg_etsng AS SELECT * FROM ctlg.psql_db_catalog__catalog_etsng_jsn_csv;

DROP INDEX IF EXISTS ndx__ctlg_etsng__id;
CREATE INDEX ndx__ctlg_etsng__id ON _ctlg_etsng(catalog_id);


DROP TABLE IF EXISTS _ctlg_gng;
CREATE TABLE _ctlg_gng AS SELECT * FROM ctlg.psql_db_catalog__catalog_gng_jsn_csv;

DROP INDEX IF EXISTS ndx__ctlg_gng__id;
CREATE INDEX ndx__ctlg_gng__id ON _ctlg_gng(catalog_id);


DROP TABLE IF EXISTS _ctlg_conterparty;
CREATE TABLE _ctlg_conterparty AS SELECT * FROM ctlg.psql_db_catalog__catalog_conterparty_csv;

DROP INDEX IF EXISTS ndx__ctlg_conterparty__id;
CREATE INDEX ndx__ctlg_conterparty__id ON _ctlg_conterparty(id);


DROP TABLE IF EXISTS _ctlg_contract;
CREATE TABLE _ctlg_contract AS SELECT * FROM ctlg.psql_db_catalog__catalog_contract_csv;

DROP INDEX IF EXISTS ndx__ctlg_contract__id;
CREATE INDEX ndx__ctlg_contract__id ON _ctlg_contract(id);








DROP VIEW IF EXISTS view__rks_directly;

CREATE VIEW view__rks_directly AS
SELECT
	Исходник,"Строка в исходнике",document_id,row_id,row_total,document_number,
	client_number_id,
	CTLG_CNTRPT.name AS client_name,
	contract_id,contract_number,contract_organization,
	service_details_acted_date,
	service_details_provision_date,
	service_details_order_id,
	------------------------------------------------------------------------
	service_details_points_from_catalog_id,
	CTLG_LOCATION_FROM.name AS service_details_points_from_catalog_name,
	service_details_points_from_station_id,
	------------------------------------------------------------------------	
	service_details_points_to_catalog_id,
	CTLG_LOCATION_TO.name AS service_details_points_to_catalog_name,	
	service_details_points_to_station_id,
	------------------------------------------------------------------------	
	service_details_container_number,
	service_details_container_type,service_details_container_owner,
	service_details_wagon_number,
	service_details_wagon_owner,
	items_etsng_id,
	json_extract(CTLG_ETSNG.changes, '$.name') AS items_etsng_name,
	items_gng_id,
	json_extract(CTLG_GNG.changes, '$.name') AS items_gng_name,
	items_weight,
	date_end,	
	epu_id,
	esu_id,
	json_extract(CTLG_SERVICE.changes, '$.name') AS esu_name,
	class_id,
	--provider_contract_id,
	--CTLG_PROVIDER.name AS provider_contract_name,
	--CTLG_PROVIDER.owner AS provider_contract_owner,
	CTLG_PROVIDER_CNTRPT.name AS provider_name,
	order_manager,wagon_container,
	amount_in_contract_currency_with_vat,
	amount_in_contract_currency_vat,	
	amount_in_contract_currency_without_vat,	
	amount_in_contract_currency_buy,	
	amount_in_rub_with_vat,	
	amount_in_rub_vat,	
	amount_in_rub_without_vat,	
	amount_in_rub_buy,	
	amount_in_rub_adjusted_revenue,	
	additional_route_mode_id,
	departure_date,
	shipment_date,
	document_reasons_name,
	document_reasons_number,
	departure_kind,route_legs_type,service_provision_place_filial_name,service_provision_place_filial_id,service_provision_place_division_name,service_provision_place_division_id,service_provision_place_location_name,service_provision_place_location_external_id,account_item,account_item_code,sub_code,tariff_epu,esu_payer_name,esu_payer_id,epu_payer_name,epu_payer_id,is_coexecutor_wagon,is_agency_wagon,wagon_owner_name,wagon_owner_id,container_owner_name,container_owner_id,transport_solution_country_from_id,transport_solution_country_to_id,transport_solution_location_in_name,transport_solution_location_in_id,transport_solution_location_out_name,transport_solution_location_out_id,transport_solution_total_distance,"_ЗаписьУдалена"
FROM
	_rks_directly AS RRD
	LEFT JOIN _ctlg_service     AS CTLG_SERVICE         ON RRD.esu_id                                 = CTLG_SERVICE.catalog_id
	LEFT JOIN _ctlg_location    AS CTLG_LOCATION_FROM   ON RRD.service_details_points_from_catalog_id = CTLG_LOCATION_FROM.id
	LEFT JOIN _ctlg_location    AS CTLG_LOCATION_TO     ON RRD.service_details_points_to_catalog_id   = CTLG_LOCATION_TO.id
	LEFT JOIN _ctlg_etsng       AS CTLG_ETSNG           ON RRD.items_etsng_id                         = CTLG_ETSNG.catalog_id
	LEFT JOIN _ctlg_gng         AS CTLG_GNG             ON RRD.items_gng_id                           = CTLG_GNG.catalog_id
	LEFT JOIN _ctlg_conterparty AS CTLG_CNTRPT          ON RRD.client_number_id                       = CTLG_CNTRPT.id
	LEFT JOIN _ctlg_contract    AS CTLG_PROVIDER        ON RRD.provider_contract_id                   = CTLG_PROVIDER.id
	LEFT JOIN _ctlg_conterparty AS CTLG_PROVIDER_CNTRPT ON CTLG_PROVIDER.owner                        = CTLG_PROVIDER_CNTRPT.id;


--SELECT * FROM view__rks_directly where service_details_container_number = 'TKRU3147900' ORDER BY date_end DESC
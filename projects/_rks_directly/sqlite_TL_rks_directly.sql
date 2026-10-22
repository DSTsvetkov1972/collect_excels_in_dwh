--======================================================================
-- Запускается в той базе, в которой нужно создать таблицу rks_directly
--======================================================================

PRAGMA cache_size = -64000;
PRAGMA temp_store = MEMORY;	

ATTACH 'E:\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\RAW.db' AS raw;

BEGIN;
DROP TABLE IF EXISTS _rks_directly;
CREATE TABLE _rks_directly AS
SELECT
	Исходник,"Строка в исходнике",document_id,row_id,row_total,document_number,client_number_id,contract_id,contract_number,contract_organization,
	concat(
		substring(service_details_acted_date, 7, 4), '-',
		substring(service_details_acted_date, 4, 2), '-',
		substring(service_details_acted_date, 1, 2)	
	) AS service_details_acted_date,
	service_details_provision_date,
	service_details_order_id,
	service_details_points_from_catalog_id,service_details_points_from_station_id,
	service_details_points_to_catalog_id,service_details_points_to_station_id,
	service_details_container_number,
	service_details_container_type,service_details_container_owner,
	service_details_wagon_number,
	service_details_wagon_owner,items_etsng_id,items_gng_id,items_weight,
	--date_end,
	concat(
		substring(date_end, 7, 4), '-',
		substring(date_end, 4, 2), '-',
		substring(date_end, 1, 2)	
	) AS date_end,	
	epu_id,esu_id,class_id,provider_contract_id,order_manager,wagon_container,
	--amount_in_contract_currency_with_vat
	CAST(REPLACE(amount_in_contract_currency_with_vat, ',', '.') AS REAL) AS amount_in_contract_currency_with_vat,
	--amount_in_contract_currency_vat,
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
	amount_in_rub_adjusted_revenue,
	CAST(REPLACE(amount_in_rub_adjusted_revenue, ',', '.') AS REAL) AS amount_in_rub_adjusted_revenue,	
	additional_route_mode_id,
	departure_date,
	shipment_date,
	document_reasons_name,
	document_reasons_number,
	departure_kind,route_legs_type,service_provision_place_filial_name,service_provision_place_filial_id,service_provision_place_division_name,service_provision_place_division_id,service_provision_place_location_name,service_provision_place_location_external_id,account_item,account_item_code,sub_code,tariff_epu,esu_payer_name,esu_payer_id,epu_payer_name,epu_payer_id,is_coexecutor_wagon,is_agency_wagon,wagon_owner_name,wagon_owner_id,container_owner_name,container_owner_id,transport_solution_country_from_id,transport_solution_country_to_id,transport_solution_location_in_name,transport_solution_location_in_id,transport_solution_location_out_name,transport_solution_location_out_id,transport_solution_total_distance,"_ЗаписьУдалена"
FROM
	raw.raw_rks_directly;
COMMIT;

BEGIN;
DROP INDEX IF EXISTS `ndx__rks_directly__service_details_order_id`;
CREATE INDEX `ndx__rks_directly__service_details_order_id` ON _rks_directly (`service_details_order_id`);
COMMIT;

BEGIN;
DROP INDEX IF EXISTS `ndx__rks_directly__service_details_wagon_number`;
CREATE INDEX `ndx__rks_directly__service_details_wagon_number` ON _rks_directly (`service_details_wagon_number`);
COMMIT;

BEGIN;
DROP INDEX IF EXISTS `ndx_rks_directly__service_details_container_number`;
CREATE INDEX `ndx_rks_directly__service_details_container_number` ON _rks_directly (`service_details_container_number`);
COMMIT;

BEGIN;
DROP INDEX IF EXISTS `ndx_rks__directly_date_end`;
CREATE INDEX `ndx_rks__directly_date_end` ON _rks_directly (`date_end`);
COMMIT;
--SET http_proxy = 'http://proxy.trcont.com:2270';
--INSTALL chsql FROM community;
--LOAD chsql;

ANALYZE;

DROP VIEW IF EXISTS view__rks_directly;
--
CREATE VIEW view__rks_directly AS
SELECT
	Исходник,"Строка в исходнике",document_id,row_id,row_total,document_number,
	client_number_id,
	CTLG_CNTRPT.name AS client_name,
	contract_id,contract_number,contract_organization,
	try_strptime(service_details_acted_date, '%d.%m.%Y %H:%M:%S') AS service_details_acted_date,
	try_strptime(service_details_provision_date, '%d.%m.%Y %H:%M:%S') AS service_details_provision_date,
	service_details_order_id,
	------------------------------------------------------------------------
	service_details_points_from_catalog_id,
	CTLG_LOCATION_FROM.`name` AS service_details_points_from_catalog_name,
	service_details_points_from_station_id,
	REPLACE(json_extract(CTLG_RAILSTATION_FROM.changes, '$.name'), '"', '') AS service_details_points_from_station_name,
	REPLACE(json_extract(CTLG_RAILSTATION_FROM.changes, '$.railroad'), '"', '') AS service_details_points_from_station_railroad,
	------------------------------------------------------------------------	
	service_details_points_to_catalog_id,
	CTLG_LOCATION_TO.`name` AS service_details_points_to_catalog_name,	
	service_details_points_to_station_id,
	REPLACE(json_extract(CTLG_RAILSTATION_TO.changes, '$.name'), '"', '') AS service_details_points_to_station_name,
	REPLACE(json_extract(CTLG_RAILSTATION_TO.changes, '$.railroad'), '"', '') AS service_details_points_to_station_railroad,	
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
	try_strptime(date_end, '%d.%m.%Y %H:%M:%S') AS date_end,
	epu_id,
	esu_id,
	json_extract(CTLG_SERVICE.changes, '$.name') AS esu_name,
	class_id,
	--provider_contract_id,
	--CTLG_PROVIDER.name AS provider_contract_name,
	--CTLG_PROVIDER.owner AS provider_contract_owner,
	CTLG_PROVIDER_CNTRPT.name AS provider_name,
	order_manager,wagon_container,
	--amount_in_contract_currency_with_vat,
	COALESCE(TRY_CAST(REPLACE(amount_in_contract_currency_with_vat   , ',', '.') AS DOUBLE), 0.0) AS amount_in_contract_currency_with_vat,
	COALESCE(TRY_CAST(REPLACE(amount_in_contract_currency_vat        , ',', '.') AS DOUBLE), 0.0) AS amount_in_contract_currency_vat,	
	COALESCE(TRY_CAST(REPLACE(amount_in_contract_currency_without_vat, ',', '.') AS DOUBLE), 0.0) AS amount_in_contract_currency_without_vat,	
	COALESCE(TRY_CAST(REPLACE(amount_in_contract_currency_buy        , ',', '.') AS DOUBLE), 0.0) AS amount_in_contract_currency_buy,	
	COALESCE(TRY_CAST(REPLACE(amount_in_rub_with_vat                 , ',', '.') AS DOUBLE), 0.0) AS amount_in_rub_with_vat,	
	COALESCE(TRY_CAST(REPLACE(amount_in_rub_vat                      , ',', '.') AS DOUBLE), 0.0) AS amount_in_rub_vat,	
	COALESCE(TRY_CAST(REPLACE(amount_in_rub_without_vat              , ',', '.') AS DOUBLE), 0.0) AS amount_in_rub_without_vat,	
	COALESCE(TRY_CAST(REPLACE(amount_in_rub_buy                      , ',', '.') AS DOUBLE), 0.0) AS amount_in_rub_buy,	
	COALESCE(TRY_CAST(REPLACE(amount_in_rub_adjusted_revenue         , ',', '.') AS DOUBLE), 0.0) AS amount_in_rub_adjusted_revenue,
	additional_route_mode_id,
	try_strptime(departure_date, '%d.%m.%Y %H:%M:%S') AS departure_date,
	try_strptime(shipment_date, '%d.%m.%Y %H:%M:%S') AS shipment_date,
	document_reasons_name,
	document_reasons_number,
	departure_kind,route_legs_type,service_provision_place_filial_name,service_provision_place_filial_id,service_provision_place_division_name,service_provision_place_division_id,service_provision_place_location_name,service_provision_place_location_external_id,account_item,account_item_code,sub_code,
	COALESCE(TRY_CAST(REPLACE(tariff_epu, ',', '.') AS DOUBLE), 0.0)  AS tariff_epu,
	esu_payer_name,esu_payer_id,epu_payer_name,epu_payer_id,is_coexecutor_wagon,is_agency_wagon,wagon_owner_name,wagon_owner_id,container_owner_name,container_owner_id,transport_solution_country_from_id,transport_solution_country_to_id,transport_solution_location_in_name,transport_solution_location_in_id,transport_solution_location_out_name,transport_solution_location_out_id,transport_solution_total_distance,"_ЗаписьУдалена"
FROM
	raw_rks_directly AS RRD
	LEFT JOIN ctlg_service     AS CTLG_SERVICE          ON RRD.esu_id                                 = CTLG_SERVICE.catalog_id
	LEFT JOIN ctlg_location    AS CTLG_LOCATION_FROM    ON RRD.service_details_points_from_catalog_id = CTLG_LOCATION_FROM.id
	LEFT JOIN ctlg_railstation AS CTLG_RAILSTATION_FROM ON RRD.service_details_points_from_station_id = CTLG_RAILSTATION_FROM.catalog_id
	LEFT JOIN ctlg_location    AS CTLG_LOCATION_TO      ON RRD.service_details_points_to_catalog_id   = CTLG_LOCATION_TO.id
	LEFT JOIN ctlg_railstation AS CTLG_RAILSTATION_TO   ON RRD.service_details_points_to_station_id   = CTLG_RAILSTATION_TO.catalog_id
	LEFT JOIN ctlg_etsng       AS CTLG_ETSNG            ON RRD.items_etsng_id                         = CTLG_ETSNG.catalog_id
	LEFT JOIN ctlg_gng         AS CTLG_GNG              ON RRD.items_gng_id                           = CTLG_GNG.catalog_id
	LEFT JOIN ctlg_conterparty AS CTLG_CNTRPT           ON RRD.client_number_id                       = CTLG_CNTRPT.id
	LEFT JOIN ctlg_contract    AS CTLG_PROVIDER         ON RRD.provider_contract_id                   = CTLG_PROVIDER.id
	LEFT JOIN ctlg_conterparty AS CTLG_PROVIDER_CNTRPT  ON CTLG_PROVIDER.owner                        = CTLG_PROVIDER_CNTRPT.id

SELECT * FROM _mtrlzd__rks_directly WHERE 	
	
	
CREATE OR REPLACE TABLE _mtrlzd__rks_directly AS
SELECT
	--Исходник,"Строка в исходнике",document_id,row_id,row_total,document_number,client_number_id,
	client_name,
	--contract_id,
	contract_number,
	--contract_organization,
	--service_details_provision_date,
	service_details_order_id,
	service_details_points_from_catalog_id,
	--service_details_points_from_catalog_name,
	service_details_points_from_station_railroad,
	service_details_points_from_station_name,
	--service_details_points_from_station_id,
	service_details_points_to_catalog_id,
	--service_details_points_to_catalog_name,
	--service_details_points_to_station_id, 
	service_details_points_to_station_name,
	service_details_container_number,
	service_details_container_type,
	--service_details_container_owner,
	service_details_wagon_number,
	--service_details_wagon_owner,
	--items_etsng_id,
	items_etsng_name,
	--items_gng_id,
	--items_gng_name,
	--items_weight,
	--epu_id,
	esu_id,
	esu_name,
	service_provision_place_filial_name,
	service_details_acted_date::DATE AS service_details_acted_date,
	date_end::DATE AS date_end,
	--class_id,
	--provider_contract_id,
	--provider_name,
	--order_manager,
	--wagon_container,
	--amount_in_contract_currency_with_vat,
	--amount_in_contract_currency_vat,
	--amount_in_contract_currency_without_vat,
	--amount_in_contract_currency_buy,
	--amount_in_rub_with_vat,
	--amount_in_rub_vat,
	sum(amount_in_rub_without_vat) AS sum_amount_in_rub_without_vat, 
	sum(amount_in_contract_currency_without_vat) AS sum_amount_in_contract_currency_without_vat--,
	--amount_in_rub_buy,
	--amount_in_rub_adjusted_revenue,
	--additional_route_mode_id,
	--departure_date,shipment_date,document_reasons_name,document_reasons_number,departure_kind,route_legs_type,service_provision_place_filial_name,
	--service_provision_place_filial_id,
	--service_provision_place_division_name,service_provision_place_division_id,service_provision_place_location_name,service_provision_place_location_external_id,account_item,account_item_code,sub_code,tariff_epu,esu_payer_name,esu_payer_id,epu_payer_name,epu_payer_id,is_coexecutor_wagon,is_agency_wagon,wagon_owner_name,wagon_owner_id,container_owner_name,container_owner_id,transport_solution_country_from_id,transport_solution_country_to_id,transport_solution_location_in_name,transport_solution_location_in_id,transport_solution_location_out_name,transport_solution_location_out_id,transport_solution_total_distance,"_ЗаписьУдалена"
FROM
	view__rks_directly
WHERE
	client_name NOT IN ('ООО "ДЕЛО ЛОДЖИСТИКС"')
	--esu_id in ('0.01.01.01', '0.01.01.02') and service_details_points_from_station_railroad in '96'
	--and service_details_container_number like '%HALU2430573%' or wagon_container like '%TKRU4370292%' --AND 
	--service_details_order_id ='32605735'
GROUP BY
		client_name,
	--contract_id,
	contract_number,
	--contract_organization,
	service_details_acted_date,
	--service_details_provision_date,
	service_details_order_id,
	service_details_points_from_catalog_id,
	service_details_points_from_station_railroad,
	service_details_points_from_catalog_name,
	service_details_points_from_station_name,
	--service_details_points_from_station_id,
	service_details_points_to_catalog_id,
	--service_details_points_to_catalog_name,
	--service_details_points_to_station_id, 
	service_details_points_to_station_name,
	service_details_container_number,service_details_container_type,
	--service_details_container_owner,
	service_details_wagon_number,
	--service_details_wagon_owner,
	--items_etsng_id,
	items_etsng_name,
	--items_gng_id,
	--items_gng_name,
	--items_weight,
	date_end,
	--epu_id,
	esu_id,
	esu_name,
	service_provision_place_filial_name
HAVING	
	sum_amount_in_rub_without_vat<>0 AND 
	sum_amount_in_contract_currency_without_vat<>0	
ORDER BY
	date_end DESC

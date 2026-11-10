DROP VIEW IF EXISTS view__orders_services_items;
--

SELECT * FROM _mtrlzd__orders_services_items

--CREATE TABLE _mtrlzd__orders_services_items AS 
CREATE VIEW view__orders_services_items AS 
WITH
BASE AS (
SELECT * FROM raw_orders WHERE json_valid(order_data) --AND order_data->>'$.order.datetime_created'>'2026-07-01'
--) SELECT * FROM BASE
),
ORDERS AS (
SELECT
	--Исходник,"Строка в исходнике","Unnamed: 0",
	order_id,--source_system,source_id,trans_subcode,
	state,--comment_for_processing,equipment_from_region,equipment_from_warehouse,equipment_to_region,equipment_to_warehouse,tsol_id,tsol_itinerary_id,tsol_sort_priority,tsol_items_total_weight,tsol_items_declared_cost,tsol_items_declared_currency,tsol_period_total_days,tsol_period_start_date,tsol_period_planning,tsol_period_end_date,tsol_location_total_distance,tsol_location_from_country_id,tsol_location_from_station_id,
	tsol_location_from_catalog_id,
	LOCATION_FROM.name AS tsol_location_from_catalog_name,	
	--tsol_location_from_kladr_id,tsol_location_from_fias_id,tsol_location_from_city,tsol_location_via_country_id,tsol_location_via_station_id,tsol_location_via_catalog_id,tsol_location_via_kladr_id,tsol_location_via_fias_id,tsol_location_via_city,tsol_location_to_country_id,tsol_location_to_station_id,
	tsol_location_to_catalog_id,
	LOCATION_TO.name AS tsol_location_to_catalog_name,	
	--tsol_location_to_kladr_id,tsol_location_to_fias_id,tsol_location_to_city,tsol_user_type_id,tsol_client_type,tsol_sort_routes_by,tsol_container_owner,tsol_car_owner,tsol_sales_channel_id,tsol_rail_tariff_only,tsol_empty_equipment,tsol_complex_service,tsol_shipment_type_id,tsol_complete_car_shipment,tsol_shipment_detail_id,tsol_route_mode_id,tsol_household_exceeds,tsol_container_train,tsol_currency,tsol_linked_cargo,tsol_oversize_index,tsol_cars_linked,tsol_cars_group,tsol_cars_in_route,tsol_cars_count_in_group,tsol_military_form2_rail,tsol_military_form2_terminal,tsol_military_form2_water,tsol_equipment_types_together,"comment",agree_for_new_equipment,package_name,related_order_id,counter_offer_apply,need_resources_book,client_id,client_name,client_user_name,manager_id,manager_name,contract_id,contract_number,contract_date,contract_branch_id,contract_branch_name,contract_branch_sub_code,contract_language,guard_contract_id,guard_contract_number,guard_contract_client_owns,shipment_doc_type_id,shipment_doc_number,shipment_doc_date,shipment_doc_responsible_name,shipment_doc_responsible_post,special_contract_number,special_contract_date,order_data,message_id,fact_period_start_date,fact_period_end_date,fact_period_total_days,created,rks_act_date,tsol_location_from_1520_station_id,tsol_location_to_1520_station_id,is_sea,is_rw,is_auto,receipt_doctype_id,need_custom,epd_orexp_paper,single_forwarding_order,client_edo_id
FROM
	BASE
	LEFT JOIN ctlg_location AS LOCATION_FROM ON BASE.tsol_location_from_catalog_id=LOCATION_FROM.id
	LEFT JOIN ctlg_location AS LOCATION_TO   ON BASE.tsol_location_to_catalog_id=LOCATION_TO.id
--) SELECT * FROM ORDERS	
),
SERVICES_0 AS (
SELECT
	order_id,
	order_data->>'$.order.transport_solution.legs' AS `order.transport_solution.legs`,
	unnest(`order.transport_solution.legs`::JSON[]) AS `order.transport_solution.leg`,
	`order.transport_solution.leg`->>'$.services' AS `order.transport_solution.leg.services`
FROM
	BASE
--) SELECT * FROM SERVICES_0	
),
SERVICES_1 AS (
SELECT
	order_id,
	unnest(`order.transport_solution.leg.services`::JSON[]) AS `order.transport_solution.leg.service`,
	`order.transport_solution.leg.service`->>'$.details' AS `order.transport_solution.leg.service.details`	
FROM
	SERVICES_0
--) SELECT * FROM SERVICES_1
),
SERVICES_2 AS (
SELECT
	order_id,
	"order.transport_solution.leg.service.details",
	unnest("order.transport_solution.leg.service.details"::JSON[]) AS "order.transport_solution.leg.service.detail",
	"order.transport_solution.leg.service.detail"->>'$.esu_id' AS `order.transport_solution.leg.service.esu_id`,
	"order.transport_solution.leg.service.detail"->>'$.currency' AS `order.transport_solution.leg.service.currency`,
	"order.transport_solution.leg.service.detail"->>'$.rate_sell_url' AS `order.transport_solution.leg.service.detail.rate_sell_url`,
	reverse(string_split(reverse(`order.transport_solution.leg.service.detail.rate_sell_url`), '/')[1]) AS "logist_price_id",	
	CAST("order.transport_solution.leg.service.detail"->>'$.cost_per_unit_in_contract_currency' AS DECIMAL(18, 4)) AS `order.transport_solution.leg.service.cost_per_unit_in_contract_currency`--,
  	--"cost_per_unit_in_contract_currency_buy"->>'$.cost_per_unit_in_contract_currency_buy' AS `order.transport_solution.leg.service.cost_per_unit_in_contract_currency_buy`
FROM
	SERVICES_1
--) SELECT * FROM SERVICES_2
),
SERVICES_3 AS (
SELECT
	order_id,
	"logist_price_id",
	LR."Коммерческие условия",
	"order.transport_solution.leg.service.esu_id",
	SE.changes->>'name' AS "order.transport_solution.leg.service.esu_name",
	"order.transport_solution.leg.service.currency",
	"order.transport_solution.leg.service.cost_per_unit_in_contract_currency"
FROM
	SERVICES_2
	LEFT JOIN raw_logist_rates AS LR ON SERVICES_2."logist_price_id"=LR."Идентификатор цены"
	LEFT JOIN ctlg_service AS SE ON SE.catalog_id=SERVICES_2."order.transport_solution.leg.service.esu_id"
--) SELECT * FROM SERVICES_3 
),
SERVICES AS ( 
SELECT
	order_id,--logist_price_id,
	"Коммерческие условия",
	"order.transport_solution.leg.service.esu_id","order.transport_solution.leg.service.esu_name","order.transport_solution.leg.service.currency","order.transport_solution.leg.service.cost_per_unit_in_contract_currency"
FROM
	SERVICES_3
--) SELECT * FROM SERVICES_3
),
ITEMS_0 AS (
SELECT
	order_id,
	order_data->>'$.order.transport_solution.items' AS `order.transport_solution.items`,
	unnest(`order.transport_solution.items`::JSON[]) AS `order.transport_solution.ltem`,
	`order.transport_solution.ltem`->>'gng_id' AS `order.transport_solution.ltem.gng_id`,
	`order.transport_solution.ltem`->>'etsng_id' AS `order.transport_solution.ltem.etsng_id`	
FROM
	BASE
--) SELECT * FROM ITEMS_0
),
ITEMS_1 AS (
SELECT
	order_id,--"order.transport_solution.items","order.transport_solution.ltem",
	"order.transport_solution.ltem.gng_id" || ' ' ||
	(GNG.changes->>'name') AS "order.transport_solution.ltem.gng_id_name",	
	"order.transport_solution.ltem.etsng_id" || ' ' ||
	(ETSNG.changes->>'name') AS "order.transport_solution.ltem.etsng_id_name"
FROM
	ITEMS_0
	LEFT JOIN ctlg_gng   AS GNG     ON GNG.catalog_id = ITEMS_0."order.transport_solution.ltem.gng_id"
	LEFT JOIN ctlg_etsng AS ETSNG ON ETSNG.catalog_id = ITEMS_0.`order.transport_solution.ltem.etsng_id`	
--) SELECT * FROM ITEMS_1
),
ITEMS AS (
SELECT
	order_id,
	array_to_string(list(DISTINCT "order.transport_solution.ltem.gng_id_name"), '; ') AS "order.transport_solution.ltem.gng_id_names",
	array_to_string(list(DISTINCT "order.transport_solution.ltem.etsng_id_name"), '; ') AS "order.transport_solution.ltem.etsng_id_names"
FROM
	ITEMS_1
GROUP BY
	order_id
--) SELECT * FROM ORDER_ITEMS
),
ANSWER AS (
SELECT
	ORDERS.*,
	'<--ORDERS SERVICES-->',
	SERVICES.*,
	'<--SERVICES ITEMS-->',
	ITEMS.*
FROM
	ORDERS
	LEFT JOIN SERVICES USING (order_id)
	LEFT JOIN ITEMS    USING (order_id)
)
SELECT
	order_id,state,tsol_location_from_catalog_id,tsol_location_from_catalog_name,tsol_location_to_catalog_id,tsol_location_to_catalog_name,
	"'<--ORDERS SERVICES-->'",
	--order_id,
	"Коммерческие условия","order.transport_solution.leg.service.esu_id","order.transport_solution.leg.service.esu_name","order.transport_solution.leg.service.currency","order.transport_solution.leg.service.cost_per_unit_in_contract_currency",
	"'<--SERVICES ITEMS-->'",
	--order_id,
	"order.transport_solution.ltem.gng_id_names","order.transport_solution.ltem.etsng_id_names"
FROM
	ANSWER
--SELECT count() FROM audit._gate_out_as_uchet_i_itrans
 
CREATE OR REPLACE TABLE audit._gate_out_as_uchet_i_itrans
ENGINE = MergeTree()
ORDER BY `№ релиза_очищенный`
AS (

WITH
ITRANS AS (
SELECT * FROM audit._gate_in_gate_out_i_trans
--) SELECT * FROM ITRANS WHERE `Тип релиза`='POS'
),
ITRANS AS (
	SELECT
		`Исходник` AS `source`,
		--`Строка в исходнике`,`Отменено`,`Дата отмены`,
		`Тип релиза`,
		`№ релиза`,
		splitByChar(' ', `№ релиза`)[1] AS `№ релиза_очищенный`,		
		`№ заказа`,
		`Тип перемещения`,
		`Номер контейнера`,
		`Тип контейнера`,--`Требует ремонта`,`Состояние контейнера`,`Страна`,
		`Регион`,
		`Депо`,--`Порожний`,`Страна назначения`,
		`Пункт назначения`,--`Погран. переход`,
		toDateOrNull(
			concat(
				substringUTF8(`Фактическая дата отправки по релизу`, 7, 4), '-',
				substringUTF8(`Фактическая дата отправки по релизу`, 4, 2), '-', 
				substringUTF8(`Фактическая дата отправки по релизу`, 1, 2)
			)
		) AS `Фактическая дата отправки по релизу`,
		`Клиент`,--`Менеджер заказа`,
		`Период действия релиза`,
		toDate(concat(
			substringUTF8(`Период действия релиза`, 7, 4),'-', 
			substringUTF8(`Период действия релиза`, 4, 2),'-',
			substringUTF8(`Период действия релиза`, 1, 2)
		)) AS `Начало действия релиза`--,`Дата ввода данных`,`Источник`,`Тип заказа операции`,`Автор события`,`Автор отмены`,`Дата последнего завоза`,`Время простоя`
	FROM
		ITRANS
	WHERE 
		`Тип релиза`='ORD' AND `Тип перемещения`='Out-Gate' AND `Отменено` <> '1'
--) SELECT * FROM ITRANS 	--WHERE `Период действия релиза` IS NULL
),
AS_UCHET AS (
	SELECT
		--`cntr_#_(nomer_kontejnera)`,`cntr_size_(tip_kontejnera)`,`condition_(sostoyanie)`,`place_of_release_(mesto_vydachi)`,`gate_in_(data_sdachi_v_depo)`,`gate_out_(data_vydachi_iz_depo)`,`under_the_order_(vydan_pod_reliz)`,`under_the_order_(vydan_pod_reliz)_cleared`,`consignee_of_cntr_(poluchatel_kontejnera)`,`destination_point_(punkt/stantsiya_naznacheniya)`,data_source,`RELIZES.№_zaprosa`,`RELIZES.№_zaprosa_cleared`,klient,tip_kontejnera,kolichestvo,punkt_otpravleniya,
		--primechanie_initsiatora_vydachi,order_id
		'АС-Учёт' AS `source`,	
		data_source AS `Тип релиза`,
		`RELIZES.№_zaprosa` AS `№ релиза`,
		`RELIZES.№_zaprosa_cleared` AS `№ релиза_очищенный`,
		order_id AS `№ заказа`,
		'' AS `Тип перемещения`,
		`cntr_#_(nomer_kontejnera)` AS `Номер контейнера`,
		`cntr_size_(tip_kontejnera)` AS `Тип контейнера`,
		`place_of_release_(mesto_vydachi)` AS `Регион`,
		`place_of_release_(mesto_vydachi)` AS `Депо`,
		dictGet('dict_location', 'name_en', `stantsiya/punk_naznacheniya`) AS `Пункт назначения`,
		/*`gate_out_(data_vydachi_iz_depo)`,
		toDateOrNull(concat(
			substringUTF8(`gate_out_(data_vydachi_iz_depo)`, 7, 4), '-',
			substringUTF8(`gate_out_(data_vydachi_iz_depo)`, 4, 2), '-',
			substringUTF8(`gate_out_(data_vydachi_iz_depo)`, 1, 2)
		)) AS `Фактическая дата отправки по релизу`,*/
		`gate_out_(data_vydachi_iz_depo)` AS `Фактическая дата отправки по релизу`,
		klient AS `Клиент`,
		planiruemyj_period_vyvoza AS `Период действия релиза`,
		toDateOrNull(concat(
			substringUTF8(planiruemyj_period_vyvoza, 7, 4),'-', 
			substringUTF8(planiruemyj_period_vyvoza, 4, 2),'-',
			substringUTF8(planiruemyj_period_vyvoza, 1, 2)
		)) AS `Начало действия релиза`
		/*planiruemyj_period_vyvoza AS `Начало действия релиза`*/
	FROM
		audit._gate_in_gate_out_as_uchet -- SELECT * FROM  audit._gate_in_gate_out_as_uchet
	WHERE `Тип релиза` IN ('SOGLASOVANNYE', 'OTOZVANNYE')
--) SELECT * FROM AS_UCHET WHERE `Фактическая дата отправки по релизу` IS NOT NULL
),
VYDACHI AS (
	SELECT * FROM ITRANS
	UNION ALL
	SELECT * FROM AS_UCHET
--) SELECT * FROM VYDACHI WHERE `№ релиза_очищенный`='0156-288539'
),
VYDACHI AS (
	SELECT
		concat(
			toString(toYear(`Фактическая дата отправки по релизу`)), '-',
			toString(toMonth(`Фактическая дата отправки по релизу`))
		) AS year_month,
		*
	FROM
		VYDACHI
	WHERE
		`№ релиза_очищенный`<>''
		AND `№ заказа`<>'' 
--) SELECT * FROM VYDACHI WHERE `№ релиза_очищенный`='0156-288539C'
)
SELECT DISTINCT
	--year_month,`source`,`№ релиза`,
	arrayStringConcat(arrayDistinct(groupArray(`Тип релиза`)), '; ') AS `Тип релиза`,
	`№ релиза_очищенный`,
	`№ заказа`,
	`Номер контейнера`,`Тип контейнера`,--`Регион`,
	`Депо`,depo_checked,
	arrayStringConcat(arrayDistinct(groupArray(`Пункт назначения`)), '; ') AS `Пункт назначения`,
	max(`Фактическая дата отправки по релизу`) AS `Фактическая дата отправки по релизу`,
	`Начало действия релиза`--,`Клиент`
FROM
	VYDACHI
	LEFT JOIN audit._mapping_depo ON depo=replace(replace(replace(replace(replace(replace(`Депо`, ' Xinmaohai', ''), ' TCFF', ''), ' ARNA', ''), ' Astro', ''), ' SWIFT', ''), ' Petrel', '')
--WHERE
	--`Номер контейнера`='TKRU3561993'
GROUP BY
	`№ релиза_очищенный`,`№ заказа`,`Номер контейнера`,`Тип контейнера`,`Депо`,depo_checked,`Начало действия релиза`
HAVING 
	`Фактическая дата отправки по релизу` IS NOT NULL
	
)


--SELECT * FROM audit.stavki_vydachi_v_depo_na_datu
CREATE OR REPLACE TABLE audit.stavki_vydachi_v_depo_na_datu
ENGINE = MergeTree()
ORDER BY tuple()
AS (
WITH	
STAVKI AS (	
SELECT
	link_text,--start_date,
	start_date_checked,--finish_date,
	finish_date_checked,--depo,
	depo_checked,container_size,currency,stavka
FROM
	audit._stavki_vydachi_i_sdachi_conteinerov_v_depo_drugih_stran_2022_2025_ploskaya
--) SELECT * FROM STAVKI
),
RELEASES AS (
SELECT DISTINCT
	--`Тип релиза`,`№ релиза_очищенный`,`№ заказа`,
	--`Номер контейнера`,
	`Тип контейнера`,
	`Депо`,
	depo_checked,--`Фактическая дата отправки по релизу`,
	multiIf(
		--`Тип контейнера`='20',
		`Тип контейнера`='20(24)',	       '20\'(24T)',	
		`Тип контейнера`='20(30)',         '20\'(30T)',
		`Тип контейнера`='20(30) NEW VAN', '20\'(30T)',
		`Тип контейнера`='40DV',           '40\'',
		`Тип контейнера`='40HC',           '40\'',
		`Тип контейнера`='40PW',           '40\'PW',
		`Тип контейнера`='40HC NEW VAN',   '40\'',
		Null) AS `Тип контейнера cleaned`,
		`Начало действия релиза`
FROM
	audit._vydachi_iz_as_uchet_i_itrans
--) SELECT * FROM RELEASES WHERE `Номер контейнера`='TKRU3522148'
)
SELECT
	`Тип контейнера`,`Тип контейнера cleaned`,`Начало действия релиза`,`Депо`,depo_checked,
	link_text,start_date_checked,finish_date_checked,currency,stavka
FROM
	RELEASES
	INNER JOIN STAVKI ON STAVKI.container_size=RELEASES.`Тип контейнера cleaned` AND STAVKI.depo_checked=RELEASES.depo_checked
--GROUP BY 
--	`Номер контейнера`,`Тип контейнера cleaned`,`Начало действия релиза`
WHERE
	`Начало действия релиза` BETWEEN start_date_checked AND finish_date_checked --AND `Номер контейнера`='TKRU3303474'
)	
	
	
 -- SELECT * FROM audit.bpm 
CREATE OR REPLACE TABLE audit.bpm
ENGINE = MergeTree()
ORDER BY order__id
AS (

WITH
BPM AS (
SELECT 
	order__id,
	`client__name`,
	dictGet('dict_gng', 'name', JSONExtractString((JSONExtractArrayRaw(`order__transport_solution__items`) AS order__transport_solution__items_array)[1], 'gng_id')) AS `gng_name`,
	dictGet('dict_etsng', 'name', JSONExtractString(order__transport_solution__items_array[1], 'etsng_id')) AS etsng_name,
	--
	order__transport_solution__location__from__catalog_id,
	dictGet('dict_location', 'name', order__transport_solution__location__from__catalog_id) AS order__transport_solution__location__from__catalog_name,
	--
	order__transport_solution__location__to__catalog_id,
	dictGet('dict_location', 'name', order__transport_solution__location__to__catalog_id) AS order__transport_solution__location__to__catalog_name,
	--
	order__transport_solution__legs,
	arrayJoin(JSONExtractArrayRaw(order__transport_solution__legs)) AS legs_array,
	JSONExtractInt(legs_array,'id') AS leg_id,
	-- FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM FROM
	JSONExtractString(JSONExtractRaw(JSONExtractRaw(legs_array,'points'),'from'),'catalog_id') AS leg_points_from_catalog_id,
	dictGet('dict_location', 'name', leg_points_from_catalog_id) AS leg_points_from_catalog_name,
	--
	JSONExtractString(JSONExtractRaw(JSONExtractRaw(legs_array,'points'),'from'),'station_id') AS leg_points_from_station_id,
	dictGet('dict_stations', 'station_name',  leg_points_from_station_id) AS leg_points_from_station_name,	
	-- TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO TO
	JSONExtractString(JSONExtractRaw(JSONExtractRaw(legs_array,'points'),'to'),'catalog_id') AS leg_points_to_catalog_id,
	dictGet('dict_location', 'name', leg_points_to_catalog_id) AS leg_points_to_catalog_name,
	--
	JSONExtractString(JSONExtractRaw(JSONExtractRaw(legs_array,'points'),'to'),'station_id') AS leg_points_to_station_id,
	dictGet('dict_stations', 'station_name',  leg_points_to_station_id) AS leg_points_to_station_name,	
	--
	arrayJoin(JSONExtractArrayRaw(JSONExtractRaw(legs_array,'services'))) AS services_array,
	JSONExtractInt(services_array,'id') AS service_id,
	JSONExtractString(services_array,'epu_id') AS service_epu_id,			
	arrayJoin(JSONExtractArrayRaw(services_array,'details')) AS service_details_array,
	JSONExtractInt(service_details_array,'id') AS service_details_id,
	JSONExtractString(service_details_array,'esu_id') AS service_details_esu_id,
	JSONExtractString(service_details_array,'currency') AS service_details_currency,	
	JSONExtractFloat(service_details_array,'cost_per_unit') AS service_details_cost_per_unit,
	JSONExtractFloat(service_details_array,'cost_per_unit_in_contract_currency') AS service_details_cost_per_unit_in_contract_currency
FROM 
	bpm__order AS BPM	
--) SELECT * FROM BPM WHERE `order__id` BETWEEN 31000000 AND 33000000
),
BPM AS (
SELECT DISTINCT
	order__id,
	client__name,
	gng_name,
	etsng_name,
	order__transport_solution__location__from__catalog_id,order__transport_solution__location__from__catalog_name,
	order__transport_solution__location__to__catalog_id,order__transport_solution__location__to__catalog_name,
	--order__transport_solution__legs,legs_array,leg_id,
	leg_points_from_catalog_id,leg_points_from_catalog_name,
	leg_points_from_station_id,leg_points_from_station_name,
	leg_points_to_catalog_id,leg_points_to_catalog_name,
	leg_points_to_station_id,leg_points_to_station_name,
	--services_array,service_id,service_epu_id,service_details_array,service_details_id,
	service_details_esu_id,
	service_details_currency,
	service_details_cost_per_unit,service_details_cost_per_unit_in_contract_currency
FROM
	BPM
WHERE
	service_details_esu_id IN ('0.01.03.01', '0.02.03.12', '0.02.03.01', '0.01.01.01') -- SELECT * FROM dict_service WHERE id IN ('0.01.03.01', '0.02.03.12', '0.02.03.01', '0.01.01.01')
)
SELECT
	order__id,
	client__name,
	gng_name,
	etsng_name,	
	--order__transport_solution__location__from__catalog_id,
	order__transport_solution__location__from__catalog_name,
	--order__transport_solution__location__to__catalog_id,
	order__transport_solution__location__to__catalog_name,
	--leg_points_from_catalog_id,
	--leg_points_from_catalog_name,leg_points_from_station_id,leg_points_from_station_name,leg_points_to_catalog_id,leg_points_to_catalog_name,leg_points_to_station_id,leg_points_to_station_name,--service_details_esu_id,
	anyIf(service_details_currency,                           service_details_esu_id='0.01.03.01') AS `0.01.03.01_service_details_currency`,
	sumIf(service_details_cost_per_unit,                      service_details_esu_id='0.01.03.01') AS `0.01.03.01_sum_service_details_cost_per_unit`,
	sumIf(service_details_cost_per_unit_in_contract_currency, service_details_esu_id='0.01.03.01') AS `0.01.03.01_sum_service_details_cost_per_unit_in_contract_currency`,
	anyIf(service_details_currency,                           service_details_esu_id='0.02.03.12') AS `0.02.03.12_service_details_currency`,
	sumIf(service_details_cost_per_unit,                      service_details_esu_id='0.02.03.12') AS `0.02.03.12_sum_service_details_cost_per_unit`,
	sumIf(service_details_cost_per_unit_in_contract_currency, service_details_esu_id='0.02.03.12') AS `0.02.03.12_sum_service_details_cost_per_unit_in_contract_currency`,
	anyIf(service_details_currency,                           service_details_esu_id='0.02.03.01') AS `0.02.03.01_service_details_currency`,
	sumIf(service_details_cost_per_unit,                      service_details_esu_id='0.02.03.01') AS `0.02.03.01_sum_service_details_cost_per_unit`,
	sumIf(service_details_cost_per_unit_in_contract_currency, service_details_esu_id='0.02.03.01') AS `0.02.03.01_sum_service_details_cost_per_unit_in_contract_currency`,
	anyIf(service_details_currency,                           service_details_esu_id='0.01.01.01') AS `0.01.01.01_service_details_currency`,
	sumIf(service_details_cost_per_unit,                      service_details_esu_id='0.01.01.01') AS `0.01.01.01_sum_service_details_cost_per_unit`,
	sumIf(service_details_cost_per_unit_in_contract_currency, service_details_esu_id='0.01.01.01') AS `0.01.01.01_sum_service_details_cost_per_unit_in_contract_currency`	
FROM
	BPM
GROUP BY
	order__id,	client__name,	gng_name,	etsng_name,	order__transport_solution__location__from__catalog_name,order__transport_solution__location__to__catalog_name

)


-- SELECT * FROM audit.aaa
CREATE OR REPLACE TABLE audit.aaa
ENGINE = MergeTree()
ORDER BY tuple()
AS (

WITH 
RELEASES AS (
SELECT 
	--`Тип релиза`,
	`№ релиза_очищенный`,`№ заказа`,`Номер контейнера`,`Тип контейнера`,`Депо`,depo_checked,`Пункт назначения`,`Фактическая дата отправки по релизу`,`Начало действия релиза`
FROM
	audit._vydachi_iz_as_uchet_i_itrans
WHERE
	`Фактическая дата отправки по релизу` >= '2024-01-01'
--) SELECT * FROM RELEASES WHERE `Номер контейнера`='TKRU4626954'
),
OPER AS (
SELECT
	--OperId,KontId,nkonts,nkont,Owner_ev,trkont,KodOper,KodOperUt,
	argMinIf(Date_pop,                 Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_Date_pop`,
	--Date_sys,SoobId,SoobAsoupId,Asoup_pr,ArmId,EntitType,EntitId,
	concat(
		'(', argMinIf(EsrOper,                  Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_EsrOper`, ') ',
		dictGet('dict_stations', 'station_name', A_EsrOper)
	) AS A_EsrOper_name,
	--dislok_pr,podhod_pr,VagId,
	--argMinIf(Nom_Vag,                  Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_Nom_Vag`,
	argMinIf(mOprId,                   Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_mOprId`,
	--snomot1,nomot1,prNrp,gr_pr,tranzit_pr,sort_ev,brakVid_ev,razedin,pereadr_pr,dosilka_pr,Site,SiteSec,SiteRow,SitePlace,SiteCircle,LastOperId,Otm_pr,OtmOperId,KontPlombId,KontNrpId,KontNarjadId,
	argMinIf(KontOtprId,               Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_KontOtprId`,
	--KontVagId,KnPripId,VedPPVId,KontDopId,DelIn17Update,pr_inoVagon,TransId,pl_pr,sf_change_date,container_number,
	argMinIf(container_operation_code, Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_container_operation_code`,
	argMinIf(shipment_document_number, Date_pop, Date_pop>=RELEASES.`Фактическая дата отправки по релизу`) AS `A_shipment_document_number`,
	--,railway_date
	RELEASES.`Номер контейнера` AS `RELEASES.Номер контейнера`, RELEASES.`Фактическая дата отправки по релизу`
FROM 	
	(SELECT * FROM cittrans__container_oper_v3 WHERE Date_pop >= '2024-01-01' AND mOprId<>0 AND KontOtprId<>0) AS OPER
	INNER JOIN (SELECT DISTINCT `Номер контейнера`, `Фактическая дата отправки по релизу` FROM RELEASES  /*ORDER BY `Номер контейнера`, `Фактическая дата отправки по релизу` LIMIT 50000 OFFSET 0*/) AS RELEASES ON RELEASES.`Номер контейнера`=OPER.container_number
GROUP BY
	RELEASES.`Номер контейнера`, RELEASES.`Фактическая дата отправки по релизу`
--) SELECT * FROM OPER WHERE `RELEASES.Номер контейнера`='DLRU0036264'
),
OPER_OTPR AS (
SELECT DISTINCT
	KontOtprId,--KontId,kodsoob,kodot,nomviza,nomzaj,
	FirstOperId AS A_FirstOperId,--LastOperId,otpr_pr,EntitDocType,TvkOper_pr,
	mOprId,--snomot1,--nomot1,
	concat(
		'(', kodgr, ') ',
		dictGet('dict_etsng', 'name', kodgr)
	) AS A_gruz_etsng,
	concat(
		'(', kodgr, ') ',
		dictGet('dict_gng', 'name', kodgrgng)
	) AS A_gruz_gng,	
	--mgrbr,mgrnetto,prvag8_pr,gruz_pr,priem_dt,srokDost,
	concat(
		'(', esrotpr, ') ',
		dictGet('dict_stations', 'station_name', esrotpr)
	) AS `esrotpr_name`,--istar,kodotpr,notprn,kodokpoo,stanPerehIn,
	concat(
		'(', esrnaz, ') ',
		dictGet('dict_stations', 'station_name', esrnaz)
	) AS `esrnaz_name`,		
		--country,kodpol,npoln,kodokpop,stanPerehOut,punkt_n,esrprim,KodPlatel,mesras,formras,TransId,DelIn17Update,Date_sys,sf_change_date,shipment_document_number
	A_Date_pop,
	A_EsrOper_name,--A_mOprId,A_KontOtprId,
	A_container_operation_code,A_shipment_document_number,`RELEASES.Номер контейнера`,`RELEASES.Фактическая дата отправки по релизу`
FROM 
	(SELECT * FROM cittrans__container_otpr_v3 WHERE FirstOperId<>0)  AS OTPR
	INNER JOIN OPER ON OPER.A_mOprId=OTPR.mOprId AND OPER.A_KontOtprId=OTPR.KontOtprId
--) SELECT * FROM OPER_OTPR WHERE `RELEASES.Номер контейнера`='TKRU4626954'
),
STAVKI AS (
SELECT DISTINCT
	`Тип контейнера`,`Начало действия релиза`,--`Депо`,
	depo_checked,link_text,start_date_checked,finish_date_checked,currency,stavka
FROM
	audit.stavki_vydachi_v_depo_na_datu
--) SELECT * FROM STAVKI WHERE `Тип контейнера`='40HC' AND depo_checked='Циндао' AND `Начало действия релиза`='2025-08-11'
)
SELECT
	RELEASES.*,
	'<==RELEASES BPM==>',
	BPM.*,
	'<==BPM OPER_OTPR==>',
	OPER_OTPR.*,
	'<==OPER_OTPR STAVKI==>',
	STAVKI.link_text,start_date_checked,finish_date_checked,STAVKI.currency,STAVKI.stavka
FROM
	RELEASES
	LEFT JOIN audit.bpm AS BPM ON toString(BPM.order__id) = RELEASES.`№ заказа`
	LEFT JOIN OPER_OTPR ON OPER_OTPR.`RELEASES.Номер контейнера` = RELEASES.`Номер контейнера` AND OPER_OTPR.`RELEASES.Фактическая дата отправки по релизу` = RELEASES.`Фактическая дата отправки по релизу`
	LEFT JOIN STAVKI ON STAVKI.`Тип контейнера`=RELEASES.`Тип контейнера` AND STAVKI.`Начало действия релиза`=RELEASES.`Начало действия релиза` AND STAVKI.depo_checked=RELEASES.depo_checked
--WHERE 
--	`Номер контейнера`='DLRU0036264'
	
)

--<со станциями по ЖД>--
--download
--SELECT `RELEASES.Номер контейнера`,`RELEASES.Начало действия релиза`, count() AS q FROM audit.aaa GROUP BY `RELEASES.Номер контейнера`,`RELEASES.Начало действия релиза` ORDER BY q DESC
SELECT count(*) FROM audit.aaa-- ORDER BY `RELEASES.Начало действия релиза`, `RELEASES.depo_checked`, `RELEASES.Номер контейнера`
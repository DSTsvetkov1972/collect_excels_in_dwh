SELECT * FROM audit._gate_in_as_uchet_i_trans


CREATE OR REPLACE TABLE audit._gate_in_as_uchet_i_trans
ENGINE = MergeTree()
ORDER BY tuple()
AS (

WITH
ITRANS AS (
SELECT * FROM audit._gate_in_gate_out_i_trans
--) SELECT * FROM ITRANS WHERE `Тип релиза`='TKRU3208878'
),
ITRANS AS (
	SELECT
		`Исходник` AS `source`,`Строка в исходнике`,--`Отменено`,`Дата отмены`,--`Тип релиза`,`№ релиза`,
		`№ заказа`,--`Тип перемещения`,
		`Номер контейнера`,`Тип контейнера`,--`Требует ремонта`,
		`Состояние контейнера`,--`Страна`,
		IF(`Депо`<>'', `Депо`, `Регион`) AS `Депо`,
		--`Порожний`,--`Страна назначения`,`Пункт назначения`,`Погран. переход`,
		`Фактическая дата отправки по релизу`,
		toDateOrNull(concat(
			substringUTF8(`Фактическая дата отправки по релизу`, 7, 4), '-',
			substringUTF8(`Фактическая дата отправки по релизу`, 4, 2), '-', 
			substringUTF8(`Фактическая дата отправки по релизу`, 1, 2)
		)) AS `Фактическая дата отправки по релизу_`,		
		--`Клиент`,`Менеджер заказа`,`Период действия релиза`,`Дата ввода данных`,`Источник`,`Тип заказа операции`,`Автор события`,`Автор отмены`,
		`Дата завоза в депо`,
		toDateOrNull(concat(
			substringUTF8(`Дата завоза в депо`, 7, 4), '-',
			substringUTF8(`Дата завоза в депо`, 4, 2), '-', 
			substringUTF8(`Дата завоза в депо`, 1, 2), ' ',
			substring(`Дата завоза в депо`, 13, 5), ':00'
		)) AS `Дата завоза в депо_`,--`Время простоя`
		IF(`Дата завоза в депо_` IS NOT NULL, `Дата завоза в депо_`, `Фактическая дата отправки по релизу_`) AS gate_in_date
	FROM
		ITRANS
	WHERE
		`Тип перемещения`='In-Gate' AND `Дата отмены`=''
--) SELECT * FROM ITRANS 	WHERE `Номер контейнера`='TKRU3208878'
),
ITRANS AS (
	SELECT
		`Номер контейнера`,`Тип контейнера`,`Состояние контейнера`,`Депо`,gate_in_date,
		concat(
			'iTrans:', char(10),
			arrayStringConcat(
				groupArray(
					concat(
						`source`, '; ', toString(`Строка в исходнике`), '; ', 
						'№ заказа: ', `№ заказа`, '; ',
						'Фактическая дата отправки по релизу: ', `Фактическая дата отправки по релизу`, '; ',
						'Дата завоза в депо: ', `Дата завоза в депо`
					)
				),
				char(10)
			)
		) AS `source`
	FROM
		ITRANS
	GROUP BY
		`Номер контейнера`,`Состояние контейнера`,`Тип контейнера`,`Депо`,gate_in_date
--) SELECT * FROM ITRANS WHERE `Номер контейнера`='TKRU3208878'
),
AS_UCHET AS (
	SELECT DISTINCT
		`cntr_#_(nomer_kontejnera)` AS `Номер контейнера`,`cntr_size_(tip_kontejnera)` AS `Тип контейнера`, 
		`condition_(sostoyanie)` AS `Состояние контейнера`,
		`place_of_release_(mesto_vydachi)` AS `Депо`,
		--`gate_in_(data_sdachi_v_depo)`,
		`gate_in_(data_sdachi_v_depo)` AS gate_in_date,
		--)) AS `Дата завоза в депо`,--`gate_out_(data_vydachi_iz_depo)`,`under_the_order_(vydan_pod_reliz)`,`under_the_order_(vydan_pod_reliz)_cleared`,`consignee_of_cntr_(poluchatel_kontejnera)`,`destination_point_(punkt/stantsiya_naznacheniya)`,data_source,`RELIZES.№_zaprosa`,`RELIZES.№_zaprosa_cleared`,klient,planiruemyj_period_vyvoza,tip_kontejnera,kolichestvo,punkt_otpravleniya,`stantsiya/punk_naznacheniya`,primechanie_initsiatora_vydachi,order_id
		'АС-Учёт' As source
	FROM
		audit._gate_in_gate_out_as_uchet -- SELECT * FROM audit._gate_in_gate_out_as_uchet WHERE `cntr_#_(nomer_kontejnera)`='TKRU3382663'
	WHERE
		`gate_in_(data_sdachi_v_depo)` IS NOT NULL
--) SELECT * FROM AS_UCHET -- WHERE `Номер контейнера`='DLRU0007137'
),
SDACHI AS (
	SELECT * FROM ITRANS
	UNION DISTINCT
	SELECT * FROM AS_UCHET
--) SELECT * FROM SDACHI WHERE `Номер контейнера`='GQRU3309169'
),
ANSWER AS (
SELECT
	`Номер контейнера`,
	`Тип контейнера`,
	`Состояние контейнера`,
	multiIf(
		`Тип контейнера`='20',	           '20\'',	
		`Тип контейнера`='20(24)',	       '20\'',	
		`Тип контейнера`='20(30)',         '20\'',
		`Тип контейнера`='20(30) NEW VAN', '20\'',
		`Тип контейнера`='40DV',           '40\'',
		`Тип контейнера`='40HC',           '40\'',
		`Тип контейнера`='40PW',           '40\'',
		`Тип контейнера`='40HC NEW VAN',   '40\'',
		Null
	) AS `Тип контейнера cleaned`,
	`Состояние контейнера`,
	`Депо`,
	depo_checked,
	gate_in_date,
	arrayStringConcat(groupArray(`source`) AS a, char(10)) AS `Источники`
FROM
	SDACHI
	LEFT JOIN audit._mapping_depo ON depo=replace(replace(replace(replace(replace(replace(replace(`Депо`, ' Xinmaohai', ''),  ' (HMM) TCFF', ''), ' TCFF', ''), ' ARNA', ''), ' Astro', ''), ' SWIFT', ''), ' Petrel', '')
GROUP BY
	`Номер контейнера`,`Тип контейнера`,`Состояние контейнера`,`Тип контейнера cleaned`,`Депо`,depo_checked,gate_in_date
) SELECT * FROM ANSWER 

)

--download
SELECT * FROM audit._gate_in_as_uchet_itrans
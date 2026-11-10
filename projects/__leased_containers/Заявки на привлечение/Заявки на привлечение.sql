SELECT * FROM audit._zayavki_na_privlechenie

CREATE OR REPLACE TABLE audit._zayavki_na_privlechenie
ENGINE = MergeTree()
ORDER BY tuple()
AS (

WITH
SRC_TAB AS (
SELECT
	`Строка в исходнике`,`Изменено`,`Создано`,`Номер заявки`,`Дата заявки`,`Тип аренды`,`Филиал привлечения`,`Собственник`,`Номер договора`,`Типоразмер`,`Заказано (шт)`,`Выдано (шт)`,`Кол-во льготных суток`,`Ставка`,`Валюта привлечения`,`Стоимость СНП`,`Валюта стоимости СНП`,`Регион привлечения`,`Регион сдачи`,`Последние изменения внёс`,`Описание (строка)`,`Тип контейнера`,
	`file_(376925)` AS file,
	`sheet_(376925)` AS sheet,
	`source_row_(376925)` AS source_row
FROM
	audit.cvetkov_d_LOADED_result_zayavki_na_privlechenie_xlsx_sheet1
--) SELECT * FROM SRC_TAB
)
SELECT
	splitByChar('.', file)[2] AS `Тип заявки`,
	--`Строка в исходнике`,
	--toDateTime(
	--`Изменено`,
	toDateTimeOrNull(concat(
		substringUTF8(`Изменено`, 7, 4), '-',
		substringUTF8(`Изменено`, 4, 2), '-',
		substringUTF8(`Изменено`, 1, 2), ' ',
		substringUTF8(`Изменено`, 12, 8)
	)) AS `Изменено_`,
	--`Создано`,
	toDateTimeOrNull(concat(
		substringUTF8(`Создано`, 7, 4), '-',
		substringUTF8(`Создано`, 4, 2), '-',
		substringUTF8(`Создано`, 1, 2), ' ',
		substringUTF8(`Создано`, 12, 8)
	)) AS `Создано_`,	
	`Номер заявки`,
	--`Дата заявки`,
	toDateTimeOrNull(concat(
		substringUTF8(`Дата заявки`, 7, 4), '-',
		substringUTF8(`Дата заявки`, 4, 2), '-',
		substringUTF8(`Дата заявки`, 1, 2), ' ',
		substringUTF8(`Дата заявки`, 12, 8)
	)) AS `Дата заявки_`,		
	`Тип аренды`,`Филиал привлечения`,`Собственник`,`Номер договора`,`Типоразмер`,
	`Заказано (шт)`,
	`Выдано (шт)`,
	--`Кол-во льготных суток`,
	toInt8(`Кол-во льготных суток`) AS `Кол-во льготных суток_`,
	--`Ставка`,
	toFloat32OrNull(REPLACE(`Ставка`, ',', '.')) AS `Ставка_`,	
	`Валюта привлечения`,
	--`Стоимость СНП`,
	toFloat32OrNull(REPLACE(`Стоимость СНП`, ',', '.')) AS `Стоимость СНП_`,		
	`Валюта стоимости СНП`,`Регион привлечения`,`Регион сдачи`,`Последние изменения внёс`,`Описание (строка)`,`Тип контейнера`,
	`file`, `sheet`,`source_row`
FROM
	SRC_TAB
--WHERE `Ставка_` IS NULL

)
	

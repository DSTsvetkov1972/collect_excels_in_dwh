SELECT `Исходник`, count() FROM audit._cksap_fitingi GROUP BY `Исходник` ORDER BY `Исходник`;

SELECT `Исходник`, count() FROM audit._cksap_krytye GROUP BY `Исходник` ORDER BY `Исходник`;

SELECT `Исходник`, count() FROM audit._cksap_poluvagony_gruzhionye GROUP BY `Исходник` ORDER BY `Исходник`;

SELECT `Исходник`, count() FROM audit._cksap_poluvagony_porozhnie GROUP BY `Исходник` ORDER BY `Исходник`;
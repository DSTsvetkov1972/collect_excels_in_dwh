from pathlib import Path
import pandas as pd


dir = r"E:\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\projects\__leased_containers\_leased_containers_open_lease\sources"

file = "Открытая аренда с 2023-01-01 по 2023-12-31.xlsx"

file_path = Path().joinpath(dir, file)

df = pd.read_excel(file_path, nrows=1)

print(str(list(df.columns)).replace("'", '"'))

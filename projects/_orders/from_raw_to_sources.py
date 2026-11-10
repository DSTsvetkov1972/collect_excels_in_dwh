import os
import pandas as pd
from datetime import datetime

raw_folder = r'E:\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\projects\_orders\sources_raw'
folder = r'E:\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\projects\_orders\sources'

raw_files = list(os.walk(raw_folder))[0][2]

print(raw_files)

print(f'{datetime.now()} Читаем')
df = pd.read_csv(os.path.join(raw_folder, raw_files[0]), encoding='windows-1251', sep='\t', dtype=str)

print(f'{datetime.now()} Пишем')
df.to_csv(os.path.join(raw_folder, f'_{raw_files[0]}'), encoding='utf-8', sep=';')

print(df.columns.to_list())
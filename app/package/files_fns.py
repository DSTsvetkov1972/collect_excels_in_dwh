import pandas as pd
import os
from pathlib import Path
from datetime import datetime
from colorama import Fore
import numpy as np


def csv_to_xlsx_convertor(csv_file_path, columns):
    try:
        xlsx_file_path = os.path.join(csv_file_path.replace('csv', 'xlsx'))

        if os.path.exists(xlsx_file_path):
            os.remove(xlsx_file_path)

        print('Читаем csv')
        df = pd.read_csv(csv_file_path, sep=';', dtype=str, keep_default_na=False, na_filter=False)

        df.columns = columns

        print('Записываем xlsx')
        df.to_excel(os.path.join(xlsx_file_path), index=None)

        os.remove(csv_file_path)

        return (True,)
    except Exception as e:
        return (False, repr(e))


def get_files_to_download(sources_dir):

    walk_res = list(os.walk(sources_dir))

    if walk_res:
        if len(walk_res[0])==3:
            files = walk_res[0][2]
            files_to_download = [file for file in files if file[-4:] in ['.csv', '.xls', 'xlsx']]
            return files_to_download
        else:
            print(
                Fore.RED + 'Папка ' +
                Fore.RESET + f'{sources_dir} ' +
                Fore.RED + 'не содержит файлов'
                )           
    else:
        print(
            Fore.RED + 'Папки ' +
            Fore.RESET + f'{sources_dir} ' +
            Fore.RED + 'не существует'
            )


def read_file(file_path): 
    try:
        start = str(datetime.now())[:19]
        
        if Path(file_path).suffix == '.csv':
            print(Fore.MAGENTA + f"{ start } Загружаем в датафрейм из файла CSV..." + Fore.RESET)
            df = pd.read_csv(file_path, dtype='string', sep=';')
        else:
            print(Fore.MAGENTA + f"{ start } Загружаем в датафрейм из файла Эксель..." + Fore.RESET)
            df = pd.read_excel(file_path, dtype='string')


        df = df.fillna('')

        df.insert(loc=0, column='Строка в исходнике', value=np.arange(len(df)))
        df['Строка в исходнике'] = df['Строка в исходнике'].astype(int)
        df['Строка в исходнике'] = df['Строка в исходнике'] + 1
        
        df.insert(loc=0, column='Исходник', value=Path(file_path).stem)

        print(Fore.GREEN + 'Загружен в датафрейм файл: ' +
              Fore.RESET + Path(file_path).name)

        return (True, df)

    except Exception as e:
        print(Fore.RED + repr(e) + Fore.RESET)
        return (False, repr(e))

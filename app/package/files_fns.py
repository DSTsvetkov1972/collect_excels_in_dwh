import pandas as pd
import os
from pathlib import Path
from datetime import datetime
from colorama import Fore
import numpy as np



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


def read_file(file_path, project_info): 

    columns = project_info['columns']
    
    #try:
    if 1:    
        start = str(datetime.now())[:19]
        
        if Path(file_path).suffix == '.csv':
            print(Fore.MAGENTA + f"{ start } Загружаем в датафрейм из файла CSV..." + Fore.RESET)
            df = pd.read_csv(file_path, dtype=str, sep=project_info['if_csv_sep'], header=project_info['if_csv_source_header'])
            df.columns = columns

        else:
            print(Fore.MAGENTA + f"{ start } Загружаем в датафрейм из файла Эксель..." + Fore.RESET)
            df = pd.read_excel(file_path, dtype=str, header=project_info['if_excel_source_header'])

        df = df.fillna('')

        df.insert(loc=0, column='Строка в исходнике', value=np.arange(len(df)))
        df['Строка в исходнике'] = df['Строка в исходнике'].astype(int)
        df['Строка в исходнике'] = df['Строка в исходнике'] + 1
        
        df.insert(loc=0, column='Исходник', value=Path(file_path).stem)

        print(Fore.GREEN + 'Загружен в датафрейм файл: ' +
              Fore.RESET + Path(file_path).name)

        return (True, df)

    #except Exception as e:
    #    print(Fore.RED + f"read_file {repr(e)}" + Fore.RESET)
    #    return (False, repr(e))

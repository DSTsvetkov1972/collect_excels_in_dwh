import os, sys
sys.path.append('.')

from pathlib import Path
from colorama import Fore

from app.package.files_fns import get_files_to_download, read_file
from app.package.processors import need_to_read, nead_to_load, storage_fns, set_load_res, start_time, processed_check

from app.package.init_infrastructure import infrastructure_check, get_project_info

#==================================================================================================
project_names = [
#    "выдачи и сдачи",
#    "релизы",
#    "контейнеры_открытая_аренда",
#    "контейнеры_закрытая_аренда",
    "ЦКСАП",
    "ЦКСАП_крытые_вагоны",
    "ЦКСАП_полувагоны_гружёные",
#    "ЦКСАП_полувагоны_порожние",
#    "актирования_из_1-С_РКС"
     ]

storages = [
    # "clickhouse",
    # "postgres",
    "sqlite3"
    ]

#==================================================================================================
if __name__=='__main__':
    if infrastructure_check(project_names, storages):

        for project_name in project_names:
            print(Fore.MAGENTA + project_name + Fore.RESET)
            # получаем список файлов, которые нужно загрузить в хранилище
            project_info = get_project_info(project_name)
            sources_dir = project_info['sources_dir']
            project = project_info['project']
            convert_to_xlsx= project_info['convert_to_xlsx']

            files_to_download = get_files_to_download(sources_dir)

            # если есть файлы, которые нужно загрузить в хранилище, загружаем эти файлы
            if files_to_download:

                # загружаем файлы, результат загрузки фиксируем в соответствующей 
                # таблицы базы данных progress_all.db
                for file in files_to_download:
                    print(Fore.BLUE + file + Fore.RESET)
                    file_path = os.path.join(sources_dir, file)
                    source_name = Path(file).stem
                    source_type = Path(file).suffix

                    if need_to_read(source_name, project, storages):    
                        read_file_res = read_file(file_path)

                        if read_file_res[0]:
                            df = read_file_res[1]

                            # сохраняем csv в формате Эксель, чтобы меньше места занимал файл
                            if source_type=='.csv' and len(df)<1048576 and len(df.columns)<=16384 and convert_to_xlsx:
                                print(Fore.MAGENTA + f'{start_time()} Переписываем{file} в формате CSV' + Fore.RESET)
                                df.to_csv(os.path.join(sources_dir, f"{source_name}.xlsx"))
                                os.remove(file_path)

                            for storage in storages:
                                if nead_to_load(source_name, project, storage):
                                    print(
                                        Fore.MAGENTA +
                                        f'{start_time()} Удаляем из таблицы {project} '
                                        f'в DWH в хранилище {storage} данные из источника "{source_name}"' +
                                        Fore.RESET
                                        )                            
                                    
                                    del_res = storage_fns[storage]['del'](source_name, project, storage)

                                    if not del_res[0]:
                                        set_load_res(source_name, project, storage, del_res[1])
                                        print(Fore.RED + f"Очистка таблицы в DWH: {del_res[1]}" + Fore.RESET)

                                    else:                            
                                        print(Fore.GREEN + f"Очистка таблицы в DWH: {del_res[1]}" + Fore.RESET)

                                        print(Fore.MAGENTA + f'{start_time()} Вставляем в таблицу DWH {storage}{project} данные из источника {source_name}' + Fore.RESET)
                                        insert_res = storage_fns[storage]['insert'](project, df)
                                        if not insert_res[0]:
                                            print(Fore.RED + f"Вставка данных в таблицу DWH {insert_res[1]}" + Fore.RESET)
                                        else:
                                            print(Fore.GREEN + f"Вставка данных в таблицу DWH {insert_res[1]}" + Fore.RESET)
                                        
                                        set_load_res(source_name, project, storage, insert_res[1])

        processed_check(project_names, storages)                                                                           
            


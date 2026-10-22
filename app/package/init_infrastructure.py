import sqlite3
import os
from colorama import Fore
from clickhouse_driver import Client
from dotenv import load_dotenv
import pyperclip
from pathlib import Path

import json

with open(os.path.join(os.getcwd(), 'app', 'config.json'), 'r', encoding='utf-8') as file:
    projects_dict = json.load(file)



load_dotenv(r'E:\.Полезности\PYTHON\.env')

CLICK_HOST = os.getenv('CLICK_HOST')
CLICK_PORT = os.getenv('CLICK_PORT')
CLICK_DBNAME = os.getenv('CLICK_DBNAME')
CLICK_USER = os.getenv('CLICK_USER')
CLICK_PWD = os.getenv('CLICK_PWD')

STORAGE_SQLITE3_PATH = os.getenv('STORAGE_SQLITE3_PATH')


def get_project_info(project_name):
    project_path = projects_dict[project_name]['project_path']
    project = Path(project_path).stem
    sources_dir = os.path.join(project_path, 'sources')
    columns = projects_dict[project_name]['columns']
    convert_to_xlsx = projects_dict[project_name]['convert_to_xlsx']

    return {
        'project_path': project_path,
        'project': project,
        'sources_dir': sources_dir,
        'columns': columns,
        'convert_to_xlsx': convert_to_xlsx
        }


def ensure_project_dir(project_name):
    """
    Если в файле config.json есть проект, а папки для него нет,
    то эта функция создаст папку для проекта по адресу,
    указанному в config.json
    """
    sources_dir = get_project_info(project_name)['sources_dir']

    if os.path.exists(sources_dir):
        print(
            Fore.GREEN + f"Папка с исходниками найдена: " +
            Fore.RESET + sources_dir
            )
        
    else:
        os.makedirs(sources_dir)
        print(
            Fore.YELLOW + f'Внимание: создана папка: ' +
            Fore.RESET + sources_dir
            )


def ensure_storage(storage, project_name):
    # загружаем функцию создания таблицы соответствующую типу хранилища
    table_init_fn = storages[storage] 

    project_info = get_project_info(project_name)

    columns = project_info['columns']
    project = project_info['project']

    table_init_fn(project, columns)


def ensure_progress_db(storage, project_name):
    """
    Функция создаёт в базе данных progress_all таблицу для управления
    загрузкой данных в DWH для соответствующего хранилища и проекта
    """

    project = get_project_info(project_name)['project']
    
    with sqlite3.connect(os.path.join(os.getcwd(), 'progress_all.db')) as conn:
        cur = conn.cursor()

        sql = (f"SELECT name FROM sqlite_master "
               f"WHERE type = 'table' AND name = 'prgs_{storage}{project}';")

        cur = cur.execute(sql)
        cur_res = cur.fetchone()

        if cur_res:
            print(
                Fore.GREEN + f'Для проекта {storage} и хранилища {project} в progress_all_db существует таблица ' +
                Fore.RESET + f'prgs_{storage}{project}'
                )
            return

        sql = f"""CREATE TABLE IF NOT EXISTS prgs_{storage}{project} (
            source TEXT PRIMARY KEY,
            stage TEXT);
            """

        # print(sql)

        cur.execute(sql)
        print(
            Fore.YELLOW + f'Внимание! Для проекта {storage} и хранилища {project} в БД progress_all создана таблица: ' +
            Fore.RESET + f'prgs_{storage}{project}'
            )        


def infrastructure_check(project_names, storages):
    """
    Проверка наличия папок с исходниками, таблиц прогресса в progress_all.db
    Таблиц проектов
    """
    print(Fore.MAGENTA + 'Проверка инфраструктуры' + Fore.RESET)
    for project_name in project_names:
        ensure_project_dir(project_name)

        for storage in storages:
            ensure_storage(storage, project_name)
            ensure_progress_db(storage, project_name)


def get_table_fields(project):
    """
    Создаёт список кортежей с полями таблицы вида:
    table_fields_tuples = [('`Исходник`', 'String'),
                        ('`Строка в исходнике`', 'Int32'),
                        ('`Дата отправления`', 'String'), 
                        ('`Дата прибытия`', 'String')]

    Поля ('`Исходник`', 'String'), ('`Строка в исходнике`', 'Int32')
    обязательные.
    Остальные берутся из первой строки первого файла папки files
    """
    
    columns = projects_dict[project]['columns']

    fields =  [f"`{ column }`, String" for column in columns]

    table_fields = ',\n'.join(fields)

    return table_fields


def sqlite3_table_init(project, columns):
    """
    Функция создаёт в DWH таблицу для хранения данных
    """

    fields =  [f"`{column}` TEXT" for column in columns]
    fields = ["`Исходник` TEXT", "`Строка в исходнике` INTEGER"] + fields

    table_fields = ',\n'.join(fields)

    with sqlite3.connect(STORAGE_SQLITE3_PATH) as conn:
        cur = conn.cursor()

        sql = (f"SELECT name FROM sqlite_master "
            f"WHERE type = 'table' AND name = 'raw{project}';")

        if cur.execute(sql).fetchone():
            print(
                Fore.GREEN + f'В DWH sqlite3 есть таблица: ' +
                Fore.RESET + f'{project}'
                )
            return
 
        sql = (f'CREATE TABLE raw{project} \n'
            f'({table_fields})')
        
        pyperclip.copy(sql)

        cur.execute(sql)

        print(Fore.YELLOW + 'Внимание! В DWH sqlite3 создана таблица: ' + 
              Fore.RESET + project)


def click_table_init(project, columns):
    
    table_fields_list = [f'{t[0]} {t[1]}' for t in table_fields_tuples]
    
    table_fields = ',\n'.join(table_fields_list)

    sql = (f'CREATE OR REPLACE TABLE {table_name}\n'
           f'({table_fields})\n'
           f'ENGINE = MergeTree()\n'
           f'ORDER BY `Исходник`')
    
    pyperclip.copy(sql)
    
    connection = Client(
        host=CLICK_HOST,
        port = CLICK_PORT,
        database=CLICK_DBNAME,
        user=CLICK_USER,
        password=CLICK_PWD,
        secure=True,verify=False)

    
    with connection:
        connection.execute(sql)


    print(Fore.GREEN, f'click_table_init создал таблицу в {table_name}', Fore.RESET)


def postgres_table_init(project, columns):
    pass





storages = {
    "clickhouse": click_table_init,
    "postgres": postgres_table_init,
    "sqlite3": sqlite3_table_init
    }


if __name__ == '__main__':
    from pprint import pprint
    project_name = "актирования_из_1-С_РКС"
    pprint(get_project_info(project_name))
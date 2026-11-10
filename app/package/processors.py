import os, sys
sys.path.append(os.getcwd())

from contextlib import closing

from pprint import pprint

import sqlite3
import duckdb
from sqlalchemy import create_engine

from datetime import datetime
from clickhouse_driver import Client
from colorama import Fore
from app.package.init_infrastructure import get_project_info

CLICK_HOST = os.getenv('CLICK_HOST')
CLICK_PORT = os.getenv('CLICK_PORT')
CLICK_DBNAME = os.getenv('CLICK_DBNAME')
CLICK_USER = os.getenv('CLICK_USER')
CLICK_PWD = os.getenv('CLICK_PWD')

STORAGE_SQLITE3_PATH = os.getenv('STORAGE_SQLITE3_PATH')
STORAGE_DUCKDB_PATH = os.getenv('STORAGE_DUCKDB_PATH')


def start_time():
    return str(datetime.now())[:19]


def need_to_read(source_name, project, storages):
    """
    Если файл не загружен в хотя бы одно из хранилищ
    из списка хранилищ в которые должна осущствляться загрузка,
    функция возвращает True
    """
    empty_storages = []

    with sqlite3.connect(os.path.join(os.getcwd(), 'progress_all.db')) as conn:
        cur = conn.cursor()

        for storage in storages:
            #print(storage)        
            sql = f"SELECT `source` FROM prgs_{storage}{project} WHERE `source`='{source_name}'"
            # print(sql)
            cur.execute(sql)
            res = cur.fetchone()
            #print(Fore.RED, res, Fore.RESET)

            if not res:
                empty_storages.append(storage)


        if empty_storages:
            print(Fore.YELLOW + f'Требуется загрузка в: {', '.join(empty_storages)}' + Fore.RESET)
            return True

        print(Fore.GREEN + 'Загрузка файла не требуется!' + Fore.RESET)
        return False        


def nead_to_load(source_name, project, storage):
 
    with sqlite3.connect(os.path.join(os.getcwd(), 'progress_all.db')) as conn:
        cur = conn.cursor()
       
        sql = f"SELECT `source` FROM prgs_{storage}{project} WHERE `source`='{source_name}'"
        res = cur.execute(sql).fetchall()

        if not res:
            print(Fore.YELLOW + f'Требуется загрузка {project} в {storage}!' + Fore.RESET)
            return True

        print(
            Fore.GREEN + 'Уже загружен в хранилище ' + 
            Fore.RESET + storage + 
            Fore.GREEN + ' в проект ' +
            Fore.RESET + project
            )
        return False


def set_load_res(source_name, project, storage, load_res):
    '''
    '''
    
    load_res = str(load_res).replace("'", '"')

    with sqlite3.connect(os.path.join(os.getcwd(), 'progress_all.db')) as conn:
        cur = conn.cursor()
        
        #sql = f"INSERT INTO prgs_{storage}{project} (source, stage) VALUES('{source_name}', '{ str(load_res[1]).replace("'", "''")}')"
        #cur.execute(sql)
        
        sql = f"INSERT INTO prgs_{storage}{project} (source, stage) VALUES('{source_name}', '{load_res}')"
        #p rint(sql)

        cur.execute(sql)

        sql = f"DROP TABLE IF EXISTS tmp_{storage}{project} ;"
        # print(sql)        
        cur.execute(sql)

        sql = f"CREATE TABLE tmp_{storage}{project} AS SELECT * FROM prgs_{storage}{project} ORDER BY `source`;"
        # print(sql)        
        cur.execute(sql)

        sql = f"DROP TABLE prgs_{storage}{project};"
        # print(sql)        
        cur.execute(sql)

        sql = f"ALTER TABLE tmp_{storage}{project} RENAME TO prgs_{storage}{project};"
        # print(sql)
        cur.execute(sql)


def click_del(source_name, project):
    start = str(datetime.now())[:19]

    print(Fore.BLUE + f'{ start } Удаляем данные для файла из DWH...' + Fore.RESET)

    try:
        connection=Client(
            host=CLICK_HOST,
            port = CLICK_PORT,
            database=CLICK_DBNAME,
            user=CLICK_USER,
            password=CLICK_PWD,
            secure=True,verify=False)
        

        with connection:
            # connection.execute(f"ALTER TABLE audit.{project} DELETE WHERE `Исходник` = '{source_name}'")            
            connection.execute(f"DELETE FROM audit.{project} WHERE `Исходник` = '{source_name}'")            
        # print(Fore.GREEN + 'Ok' + Fore.WHITE)
        return(True, 'Удалили данные из DWH')

    except Exception as e:

        print(Fore.RED + f'click_del {repr(e)}' + Fore.WHITE)
        return(False, repr(e))        


def click_insert(project, df):
    start = str(datetime.now())[:19]

    print(Fore.BLUE + f'{ start } Записываем в DWH...' + Fore.RESET)

    try:
        connection=Client(
            host=CLICK_HOST,
            port = CLICK_PORT,
            database=CLICK_DBNAME,
            user=CLICK_USER,
            password=CLICK_PWD,
            secure=True,verify=False)
        

        with connection:
            connection.insert_dataframe(f'INSERT INTO audit.{project} VALUES', df, settings=dict(use_numpy=True))            
        # print(Fore.GREEN + 'Ok' + Fore.RESET)
        return(True, len(df))

    except Exception as e:

        print(Fore.RED + f'click_insert {repr(e)}' + Fore.RESET)
        return(False, repr(e))

    
def postgres_del(source_name, project):
    start = str(datetime.now())[:19]

    print(Fore.BLUE + f'{ start } Удаляем данные для файла из DWH...' + Fore.RESET)

    try:
        connection=Client(
            host=CLICK_HOST,
            port = CLICK_PORT,
            database=CLICK_DBNAME,
            user=CLICK_USER,
            password=CLICK_PWD,
            secure=True,verify=False)
        

        with connection:
            connection.execute(f"ALTER TABLE { table_name } DELETE WHERE `Исходник` = '{ file }'")            
        # print(Fore.GREEN + 'Ok' + Fore.WHITE)
        return(True, 'Удалили данные из DWH')

    except Exception as e:

        print(Fore.RED + 'Error' + Fore.WHITE)
        return(False, repr(e))        


def postgres_insert(storage, df):
    start = str(datetime.now())[:19]

    print(Fore.BLUE + f'{ start } Записываем в DWH...' + Fore.RESET)

    try:
        connection=Client(
            host=CLICK_HOST,
            port = CLICK_PORT,
            database=CLICK_DBNAME,
            user=CLICK_USER,
            password=CLICK_PWD,
            secure=True,verify=False)
        

        with connection:
            connection.insert_dataframe(f'INSERT INTO { table_name } VALUES', df, settings=dict(use_numpy=True))            
        # print(Fore.GREEN + 'Ok' + Fore.RESET)
        return(True, len(df))

    except Exception as e:

        print(Fore.RED + 'Error' + Fore.RESET)
        return(False, repr(e))


def sqlite3_del(source_name, project):
    try:
        with sqlite3.connect(STORAGE_SQLITE3_PATH) as conn:
            cur = conn.cursor()
            sql = f"DELETE FROM raw{project} WHERE `Исходник` ='{source_name}'"
            cur.execute(sql)
        return (True, 'Ok')
    
    except Exception as e:
        return(False, repr(e))


def sqlite3_insert(project, df):
    try:
        with sqlite3.connect(STORAGE_SQLITE3_PATH) as conn:
            df.to_sql(f'raw{project}', conn, if_exists='append', index=False)           
        return(True, len(df))

    except Exception as e:
        return(False, repr(e))
    



def duckdb_del(source_name, project):
    try:
        with closing(duckdb.connect(STORAGE_DUCKDB_PATH)) as conn:
            cur = conn.cursor()
            sql = f"DELETE FROM raw{project} WHERE `Исходник` ='{source_name}'"
            cur.execute(sql)
        return (True, 'Ok')
    
    except Exception as e:
        return(False, repr(e))


def duckdb_insert(project, df):
    try:
        table_name = f'raw{project}'
        with closing(duckdb.connect(STORAGE_DUCKDB_PATH)) as conn:
            # Регистрируем DataFrame как виртуальную таблицу
            conn.register('df_view', df)
            # Вставляем данные
            conn.execute(f"INSERT INTO {table_name} SELECT * FROM df_view")
            conn.unregister('df_view')
        return (True, len(df))
    except Exception as e:
        return (False, repr(e))
    
def processed_check(project_names, storages):
    """
    Проверка все ли файлы загрузились успешно
    """
    print(Fore.MAGENTA + 'Проверяем всё ли загрузилось корректно' + Fore.RESET)
    print(Fore.GREEN, end='')

    check_dict = {}
    for project_mame in project_names:
        project = get_project_info(project_mame)['project']
        check_dict[project]=[]

        for storage in storages:
            sql = (
                f"SELECT * "
                f"FROM prgs_{storage}{project} "
                f"WHERE stage GLOB '*[^0-9-]*' "
                f"OR (stage GLOB '*-*' AND stage NOT GLOB '-[0-9]*') "
                f"OR stage = '';"
                )
            
            with sqlite3.connect(os.path.join(os.getcwd(), 'progress_all.db')) as conn:
                cur = conn.cursor()
                res = cur.execute(sql).fetchall()
                # print(res)
                if res:
                    print(Fore.RED)
                    check_dict[project].append(storage)

    pprint(check_dict)
    print(Fore.RESET)               


            


storage_fns = {
    "clickhouse": {
        "del": click_del,
        "insert": click_insert
        },
    "postgres": {
        "del": postgres_del,
        "insert": postgres_insert
        },
    "sqlite3": {
        "del": sqlite3_del,
        "insert": sqlite3_insert
    },
    "duckdb": {
        "del": duckdb_del,
        "insert": duckdb_insert
        }
    }
 
    
if __name__ == '__main__':
    print(start_time())
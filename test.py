import sqlite3
import duckdb
from contextlib import closing

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


STORAGE_SQLITE3_PATH = os.getenv('STORAGE_SQLITE3_PATH')
STORAGE_DUCKDB_PATH = os.getenv('STORAGE_DUCKDB_PATH')


print(STORAGE_DUCKDB_PATH)


print(2)
with closing(duckdb.connect(STORAGE_DUCKDB_PATH)) as duckdb_conn:
    print('Ok')


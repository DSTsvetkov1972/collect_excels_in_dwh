import sqlite3
from jinja2 import Environment, FileSystemLoader
from main import project_names
from package.init_infrastructure import get_project_info
from package.processors import start_time
from pprint import pprint
from colorama import Fore



for project_name in project_names:
    try:

        project_info = get_project_info(project_name)
        # pprint(project_info)
        project = project_info['project']

        print(Fore.MAGENTA + f'{start_time()} запустили sqlite Transform->Load для {project}' + Fore.RESET)
        sqlite_target_db = project_info['sqlite_TL_target_db']
        project_path = project_info['project_path']
        sqlite_TL_script = project_info['sqlite_TL_script']

        loader = FileSystemLoader(project_path)
        env = Environment(loader=loader, trim_blocks=True, lstrip_blocks=True)

        with sqlite3.connect(sqlite_target_db) as conn:
            cur = conn.cursor()
            sql = env.get_template(sqlite_TL_script).render()
            cur.executescript(sql)
    except Exception as e:
        print(Fore.RED + repr(e) + Fore.RESET)

print(Fore.GREEN + f"{start_time()} Готово!" + Fore.RESET)        

import os
from pathlib import Path
import pandas as pd

from package.init_infrastructure import get_project_info

project_name = "заказы"

project_info = get_project_info(project_name)
print(project_info)

sources_dir = project_info['sources_dir']
file = list(os.walk(sources_dir))[0][2][0]

file_path = Path().joinpath(sources_dir, file)

df = pd.read_csv(file_path, nrows=1, dtype=str, sep=';')

print(str(list(df.columns)).replace("'", '"'))

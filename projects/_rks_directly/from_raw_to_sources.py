import os

raw_folder = r'c:\Users\tsvetkovds\Documents\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\projects\_rks_directly\sources_raw'
folder = r'c:\Users\tsvetkovds\Documents\.PROJECTS\СОБИРАЕМ Excels В ТАБЛИЦУ DWH\projects\_rks_directly\sources'

raw_files = list(os.walk(raw_folder))[0][2]

#print(raw_files)

for raw_file in raw_files:
    YF = raw_file[-8:-4]
    MF = raw_file[-11:-9]
    DF = raw_file[-14:-12]

    YS = raw_file[-21:-17]
    MS = raw_file[-24:-22]
    DS = raw_file[-27:-25]

    print(raw_file)

    file = f'{YS}-{MS}-{DS}_{YF}-{MF}-{DF}_{raw_file}' 


    os.rename(
        os.path.join(raw_folder, raw_file),
        os.path.join(folder, file)
    )
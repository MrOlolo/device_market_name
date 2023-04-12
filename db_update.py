import sqlite3
import csv
import requests
import os

androidUrl = "https://storage.googleapis.com/play_public/supported_devices.csv"
iosDevicesUrl = "https://raw.githubusercontent.com/MrOlolo/ios-device-identifiers/without-network-info/ios-device-identifiers.json"
iosDevicesWithoutNetworkUrl = "https://raw.githubusercontent.com/MrOlolo/ios-device-identifiers/without-network-info/ios-device-identifiers_without-network.json"
path = './lib/'
dbDir = 'db'
fullPath = path+dbDir
androidDbName = 'android_market_names.db'
iosDeviceDbName = 'ios_market_names.json'
iosDeviceWithoutNetworkInfoDbName = 'ios_market_names_without_network_id.json'


def createAndroidDb():
    con = sqlite3.connect(f'{fullPath}/{androidDbName}')
    cur = con.cursor()
    cur.execute(
        'DROP TABLE IF EXISTS marketnames;')
    cur.execute(
        'CREATE TABLE marketnames(retail_branding text,market_name text,device text,model text);')

    with requests.get(androidUrl) as r:
        reader = csv.reader(r.content.decode('utf16').split('\n'))
        # skip first row with names
        for row in list(reader)[1:-1]:
            if row:
                cur.execute(
                    'INSERT INTO marketnames(retail_branding,market_name,device,model) VALUES (?, ?, ?, ?);', row)

    cur.execute('select count(*) from marketnames;')
    print('Database size:')
    print(cur.fetchone())

    con.commit()
    con.close()


def createIOSDb():
    iosD = requests.get(iosDevicesUrl)
    if(iosD.status_code == 200):
        with open(f'{fullPath}/{iosDeviceDbName}', 'wb') as f:
            f.write(iosD.content)

    iosDN = requests.get(iosDevicesWithoutNetworkUrl)
    if(iosDN.status_code == 200):
        with open(f'{fullPath}/{iosDeviceWithoutNetworkInfoDbName}', 'wb') as f:
            f.write(iosDN.content)


print(f'Create new directory {dbDir} at {path}\n')
try:
    os.mkdir(fullPath)
except OSError as error:
    print(f'Directory {dbDir} already exist\n')
print('Update database..')
createAndroidDb()
createIOSDb()

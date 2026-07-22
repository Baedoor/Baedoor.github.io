from os.path import getsize, exists
from os import remove
import requests
import sys

def downloadGoogleSheet():
    ITEMS = {"B3D Asset List.ods": "https://docs.google.com/spreadsheets/d/1qCKEiaXCVPrr48Cs_vC7xtMIZoZcmbq3-rhlrjN5FBA/export?format=ods"}
    for file, link in ITEMS.items():

        response = requests.get(link)
        if response.status_code == 200:
            NEW = True # to be overwritten if file has the same size
            with open(f"_{file}", 'wb') as tf:
                tf.write(response.content)
            if exists(file):
                if getsize(file) == getsize(f"_{file}"):
                    NEW = False
            if NEW: # if file differs or doesn't exist
                with open(file, 'wb') as f:
                    f.write(response.content)
                    print('File saved to: {}'.format(file))
                remove(f"_{file}")
        else:
            print(f'Error downloading Google Sheet: {response.status_code}')
            sys.exit(1)


##############################################
downloadGoogleSheet()

sys.exit(0)  ## success
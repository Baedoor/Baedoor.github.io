import requests
import sys

def downloadGoogleSheet():
    ITEMS = {"B3D Asset List.ods": "https://docs.google.com/spreadsheets/d/1qCKEiaXCVPrr48Cs_vC7xtMIZoZcmbq3-rhlrjN5FBA/export?format=ods"}
    for file, link in ITEMS.items():

        response = requests.get(link)
        if response.status_code == 200:
            with open(file, 'wb') as f:
                f.write(response.content)
                print('File saved to: {}'.format(file))
        else:
            print(f'Error downloading Google Sheet: {response.status_code}')
            sys.exit(1)


##############################################
downloadGoogleSheet()

sys.exit(0)  ## success
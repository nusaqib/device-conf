import json
import requests
import subprocess
from AMS.src._AMS import AMS
from eTraveler.src._Traveler import COTSTraveler


def input_handler(prompt):
    user_input = input(prompt).strip()
    while True:
        if user_input.lower() in ('n', 'no'):
            raise RuntimeError("Test failed")
        elif user_input.lower() in ('y', 'yes'):
            print("Confirmed. Moving on...")
            break
        else:
            user_input = input("Please enter 'y' or 'n': ").strip()


def fetch_asset(asset_input, valid_models):
    if asset_input.startswith('http'):
        asset_id = asset_input.rsplit('/', 1)[-1]
        asset_url = asset_input
    else:
        asset_tag = asset_input.zfill(6)
        tag_url = f"https://ctrlassets.als.lbl.gov/api/v1/hardware/bytag/{asset_tag}"
        response = requests.get(tag_url, headers=AMS().headers)
        asset_dict = json.loads(response.text)
        asset_id = asset_dict['id']
        asset_url = f"https://ctrlassets.als.lbl.gov/hardware/{asset_id}"

    api_url = f"{AMS().HARDWARE_ENDPOINT}/{asset_id}"
    asset = json.loads(requests.get(api_url, headers=AMS().headers).text)

    if asset['model']['name'] not in valid_models:
        raise ValueError(f"Asset model must be one of {valid_models}")

    print(f"Asset found: {asset['model']['name']}")
    return asset, asset_url


def handle_etraveler(asset, asset_url, config):
    print("Checking eTraveler status...")
    etraveler_url = asset['custom_fields'].get('eTraveler URL', {}).get('value', '')

    if etraveler_url:
        print("eTraveler form already exists for this asset.")
        return

    print("Creating eTraveler form...")
    new_traveler = COTSTraveler().create(config["traveler_name"], config["device_type"])
    traveler_id = new_traveler['_id']

    print("Completing eTraveler form...")
    COTSTraveler().set_ams_url(traveler_id, asset_url)
    COTSTraveler().set_completed(traveler_id)

    new_url = f"https://etraveler.lbl.gov/travelers/{traveler_id}/"
    AMS().update_eTraveler_url(asset_url, new_url)
    print("eTraveler setup complete.")

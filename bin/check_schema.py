import requests
import json

url = "https://uwfhvulbhydohufiocev.supabase.co/rest/v1/"
headers = {
    "apikey": "sb_publishable_zbFbRuu8-VFEql_UE-oVWw_9OjyJ-NC"
}

try:
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        definitions = data.get("definitions", {})
        events_def = definitions.get("events", {})
        properties = events_def.get("properties", {})
        print("EVENTS COLUMNS:")
        for prop in properties:
            print(f"  {prop}: {properties[prop].get('type')}")
    else:
        print(f"Failed with status: {response.status_code}")
        print(response.text)
except Exception as e:
    print(f"Error: {e}")

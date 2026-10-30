import requests

url = "https://portal.unib.ac.id/api/login"

payload = {
    "username": "G1F024047",
    "password": "Rivan2006#"
}

r = requests.post(url, json=payload)

data = r.json()

print(data["access_token"])
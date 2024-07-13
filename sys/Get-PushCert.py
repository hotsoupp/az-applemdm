
import msal
import sqlite3
import requests
import json

def get_bearer_token(t_id):
    with open('./db/keyvault.json') as f:
        data = json.load(f)
        customer = {}
        for c in data['customers']:
            if c['tenantId'] == t_id:
                customer = c  # Fixed typo: costumer -> customer
                break
        tenant_id = t_id
        client_id = customer['clientId']
        client_secret = customer['clientSecret']

    authority = f'https://login.microsoftonline.com/{tenant_id}'
    scope = ['https://graph.microsoft.com/.default']

    # Create an MSAL instance providing the client_id, authority and client_credential parameters
    client = msal.ConfidentialClientApplication(client_id, authority=authority, client_credential=client_secret)

    bearer_token = client.acquire_token_for_client(scopes=scope)
    return bearer_token['access_token']

def get_apple_pushcert(bearer_token):
    url = 'https://graph.microsoft.com/v1.0/deviceManagement/applePushNotificationCertificate'
    headers = {
        'Accept': '*/*',
        'Authorization': f'{bearer_token}'
    }
    response = requests.get(url, headers=headers)
    json_response = response.json()
    return {
        'id': json_response['id'],
        'appleIdentifier': json_response['appleIdentifier'],
        'expirationDateTime': json_response['expirationDateTime'],
        'lastModifiedDateTime': json_response['lastModifiedDateTime'],
        'certificateSerialNumber': json_response['certificateSerialNumber']
    }

with sqlite3.connect('./db/data.db') as conn:
    c = conn.cursor()
    c.execute("SELECT tenantId FROM costumerData")
    result = c.fetchall()
 
    for r in result:
        t_id = r[0]
        try:
            bearer_token = get_bearer_token(t_id)
        except:
            webhook_url = "https://discord.com/api/webhooks/1261691990018490489/HcW3IKrLTu1j11bQP9C8QbYU3yVzGZrg4o5UL1Y_FGHmwuS8Q-0_-gfruO0JK6Nc3P11" 
            payload = {"content": "Failed requesting bearer token for tenantId: " + t_id}
            response = requests.post(webhook_url, json=payload)
            if response.status_code == 204:
                print("Webhook sent successfully")
            else:
                print("Failed to send webhook")
            continue
        bearer_token = get_bearer_token(t_id)
        apple_pushcert = get_apple_pushcert(bearer_token)
        c.execute("UPDATE costumerData SET appleIdentifier = ?, expirationDateTime = ?, certificateSerialNumber = ? WHERE tenantId = ?", (apple_pushcert['appleIdentifier'], apple_pushcert['expirationDateTime'], apple_pushcert['certificateSerialNumber'], t_id))
        conn.commit()
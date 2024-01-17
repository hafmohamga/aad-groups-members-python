import pandas as pd
import requests
from msal import ConfidentialClientApplication

def get_access_token(client_id, client_secret, tenant_id):
    authority = f"https://login.microsoftonline.com/{tenant_id}"
    app = ConfidentialClientApplication(
        client_id,
        authority=authority,
        client_credential=client_secret
    )
    token_response = app.acquire_token_for_client(scopes=["https://graph.microsoft.com/.default"])
    return token_response['access_token']

def get_group_id(access_token, group_name):
    graph_url = f"https://graph.microsoft.com/v1.0/groups?$filter=displayName eq '{group_name}'"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    response = requests.get(graph_url, headers=headers)

    if response.status_code == 200:
        groups = response.json().get("value", [])
        if groups:
            return groups[0]["id"]
        else:
            raise Exception(f"Group '{group_name}' not found.")
    else:
        raise Exception(f"Error retrieving group: {response.status_code}, {response.text}")

def get_group_members(access_token, group_id):
    graph_url = f"https://graph.microsoft.com/v1.0/groups/{group_id}/members"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    response = requests.get(graph_url, headers=headers)

    if response.status_code == 200:
        return response.json().get("value", [])
    else:
        raise Exception(f"Error retrieving group members: {response.status_code}, {response.text}")

def get_user_details(access_token, user_id):
    graph_url = f"https://graph.microsoft.com/v1.0/users/{user_id}"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    response = requests.get(graph_url, headers=headers)

    if response.status_code == 200:
        user_data = response.json()
        return {
            "user_id": user_data["id"],
            "user_name": user_data.get("displayName"),
            "user_email": user_data.get("userPrincipalName")
        }
    else:
        raise Exception(f"Error retrieving user details: {response.status_code}, {response.text}")

def get_group_names_from_excel(file_path):
    df = pd.read_excel(file_path)
    return df['GroupName'].tolist()

def main():
    excel_file_path = "C:/Users/Book1.xlsx" 
    group_names = get_group_names_from_excel(excel_file_path)
    client_id = "****"
    client_secret = "****"
    tenant_id = "****"

    try:
        access_token = get_access_token(client_id, client_secret, tenant_id)

        all_data = []

        for group_name in group_names:
            try:
                group_id = get_group_id(access_token, group_name)
                group_members = get_group_members(access_token, group_id)
                
                for member in group_members:
                    user_details = get_user_details(access_token, member["id"])
                    all_data.append({
                        "Group": group_name,
                        "User Name": user_details['user_name'],
                        "UserID": user_details['user_id'],
                        "Email": user_details['user_email']
                    })
            except Exception as e:
                print(f"Error fetching members for group '{group_name}': {e}")

        df = pd.DataFrame(all_data)

        output_excel_file = "C:/Users/Output-35.xlsx"
        df.to_excel(output_excel_file, index=False)
        
        print(f"Updated data saved to: {output_excel_file}")

    except Exception as e:
        print(f"Error during authentication: {e}")

if __name__ == "__main__":
    main()

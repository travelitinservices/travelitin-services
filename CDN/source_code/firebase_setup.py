# This file connects firestore,authentication and storage

import firebase_admin
from firebase_admin import credentials,firestore,storage,auth
from google.cloud import storage

cred = credentials.Certificate("asafetyguide-369ee-firebase-adminsdk-ilndk-bbf4e105c0.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred, {"storageBucket": "asafetyguide-369ee.appspot.com"})


db = firestore.client()  #initializing firestore
storage_client =storage.Client.from_service_account_json("asafetyguide-369ee-firebase-adminsdk-ilndk-bbf4e105c0.json")
bucket = storage_client.bucket("asafetyguide-369ee.appspot.com")


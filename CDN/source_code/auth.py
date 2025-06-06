#Handles user sign-in, subscription verification, and JWT (JSON Web Token) generation for secure API access.

from firebase_admin import auth, firestore,credentials
import firebase_admin
import jwt
import time
from config import SECRET_KEY, JWT_EXPIRY_HOURS

import logging
import bcrypt #Library for password hashing

logging.basicConfig(level=logging.DEBUG)

cred = credentials.Certificate("asafetyguide-369ee-firebase-adminsdk-ilndk-bbf4e105c0.json")

# Force Firebase to use this specific credential
firebase_admin.initialize_app(cred, {"projectId": "asafetyguide-369ee"})


# Ensure Firebase is initialized
if not firebase_admin._apps:
    logging.info("Initializing Firebase with service account")
    firebase_admin.initialize_app()

# Initialize Firestore database
db = firestore.client()
logging.info("Firestore client created successfully!")


# Function to sign in users and verify subscription and JWT token assignment
def user_sign_in(email, password):
    try:
        logging.info(f"User {email} attempting sign-in...")
        
        # Get user data from Firebase Authentication
        user = auth.get_user_by_email(email)

        # Retrieve stored hashed password & subscription status from Firestore
        user_doc = db.collection("users").document(user.uid).get()
        
        if user_doc.exists:
            user_data = user_doc.to_dict()
            stored_hash = user_data.get("password")
            subscription_status = user_data.get("subscription_status", "inactive")  # Default to inactive
            
            if stored_hash and bcrypt.checkpw(password.encode('utf-8'), stored_hash.encode('utf-8')):
                if subscription_status == "active":
                    jwt_token = generate_signed_jwt(user.uid, "Paid User")
                    # Store session details
                    db.collection("sessions").document(user.uid).set({"token": jwt_token, "role": "Paid User"}) ##
                    logging.info(f"JWT issued successfully for {email}.")
                    
                    return {"status": "success", "jwt": jwt_token}
                else:
                    logging.warning(f"User {email} has an inactive subscription.")
                    return {"status": "error", "message": "Subscription inactive"}
            else:
                logging.warning(f"Invalid password attempt for user {email}.")
                return {"status": "error", "message": "Invalid password"}
        else:
            logging.warning(f"User {email} not found in Firestore.")
            return {"status": "error", "message": "User not found"}

    except firebase_admin.auth.UserNotFoundError:
        logging.error(f"User {email} is not registered in Firebase Auth.")
        return {"status": "error", "message": "User not registered"}
    except Exception as e:
        logging.error(f"Error during authentication: {str(e)}")
        return {"status": "error", "message": f"Error: {str(e)}"}



# Function to generate JWT token
def generate_signed_jwt(user_id, role):
    payload = {
        "sub": user_id,
        "role": role,
        "iat": int(time.time()),
        "exp": int(time.time()) + (JWT_EXPIRY_HOURS*3600)  # Token expires in 1 hour
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

def verify_jwt(token):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload if payload else None
    except jwt.ExpiredSignatureError:
        return {"error": "Token expired"}, 403
    except jwt.InvalidTokenError:
        return {"error": "Invalid token"}, 403



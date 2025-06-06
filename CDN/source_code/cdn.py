# Handles secure file serving, CDN caching, and validation of JWT tokens

import jwt
import logging
from google.cloud import storage
from config import SECRET_KEY, CDN_CACHE, CACHE_EXPIRY_SECONDS

# Setup logging
logging.basicConfig(level=logging.INFO)

# Function to validate JWT token
def verify_jwt(jwt_token):
    try:
        claims = jwt.decode(jwt_token, SECRET_KEY, algorithms=["HS256"])
        
        if claims.get("role") == "Paid User":
            return claims  # Return claims for further validation if needed
        
        logging.warning("Unauthorized JWT: Role mismatch")
        return None
    
    except jwt.ExpiredSignatureError:
        logging.warning("JWT expired")
        return None
    except jwt.InvalidTokenError:
        logging.warning("Invalid JWT token")
        return None

# Function to serve CDN content securely
def serve_content_via_cdn(file_path, jwt_token):
    claims = verify_jwt(jwt_token)
    if not claims:
        return {"status": "error", "message": "403 Forbidden: Invalid token"}

    # Serve from cache if available
    if file_path in CDN_CACHE:
        logging.info(f"Serving {file_path} from cache.")
        return {"status": "success", "url": CDN_CACHE[file_path]}

    try:
        client = storage.Client()  # Initialize Firebase Storage connection
        bucket = client.get_bucket("asafetyguide-369ee.firebasestorage.app")  # Retrieve storage bucket

        blob = bucket.blob(file_path)  # Create a blob reference
        file_url = blob.generate_signed_url(expiration=CACHE_EXPIRY_SECONDS)  # Secure signed URL

        # Store in cache
        CDN_CACHE[file_path] = file_url
        logging.info(f"File {file_path} served securely.")
        
        return {"status": "success", "url": file_url}
    
    except Exception as e:
        logging.error(f"Error retrieving {file_path}: {str(e)}")
        return {"status": "error", "message": f"Failed to serve file: {str(e)}"}

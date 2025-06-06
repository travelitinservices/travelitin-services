#Creates an API endpoint where users can request files from the CDN

from flask import Flask, request, jsonify
from auth import verify_jwt
from firebase_setup import db


app = Flask(__name__)

@app.route("/cdn/<user_id>", methods=["GET"])

def get_user_files(user_id):
    token = request.headers.get("Authorization")  # Retrieve JWT from headers

    if not token:
        return jsonify({"error": "Missing authorization header"}), 401
    
    token = token.split(" ")[1]  # Extract the token from 'Bearer <TOKEN>'
    payload = verify_jwt(token)

    if not payload or payload["sub"] != user_id:
        return jsonify({"error": "Permission denied"}), 403

    user_files = db.collection("intel").document(user_id).get()
    
    if user_files.exists:
        return jsonify(user_files.to_dict())
    else:
        return jsonify({"error": "No data found"}), 404



if __name__ == "__main__":
    app.run(port=5000, debug=True)
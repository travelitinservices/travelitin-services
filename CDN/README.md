# Firebase-Integrated CDN for Flutter

## 🚀 Overview
This project implements a **CDN (Content Delivery Network)** using **Python and Firebase**, allowing authenticated **paid users** to access and cache assets securely.

## 📂 Project Structure

/CDN
│── /src                 # Main source code
|   │── main.py              # Entry point to start the app
│   ├── firebase_setup.py    # Firebase authentication & database connection
│   ├── auth.py             # User authentication & JWT handling
│   ├── cdn.py              # CDN logic for retrieving & caching files
│   ├── api.py              # Flask API for serving content
│   ├── config.py           # Configuration settings
│── /static              # CDN cached files 
│── requirements.txt     # Python dependencies
│── README.md            # Project documentation


## 🔑 Features
- 🔒 **JWT-based authentication** for paid users.
- 🚀 **Content delivery via Firebase Storage**.
- ⚡ **Caching & optimized asset retrieval**.
- 🔄 **Session persistence** for returning users.


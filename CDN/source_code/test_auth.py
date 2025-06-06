import requests

jwt_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJKbHQwTEFGZDgyUTVXY1RiVFZaQnpucXFRZW8xIiwiaWF0IjoxNzQ4OTM0NzE0LCJleHAiOjE3NDkwMjExMTR9.8Ny1kbY7Ho97E5Kv5Q00BYPgXxyTncBQg39adWYkqnk"
headers = {"Authorization": f"Bearer {jwt_token}"}
response = requests.get("http://127.0.0.1:5000/cdn/Jlt0LAFd82Q5WcTbTVZBznqqQeo1", headers=headers)

print(response.json())  # Expected API response
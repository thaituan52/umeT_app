# umeT_app

A full-stack Flutter application with FastAPI backend, MySQL database, and passwordless email authentication.
Currently, only avaible on Android

---

## 🛠 Tech Stack

- **Frontend:** Flutter
- **Backend:** FastAPI (Python)
- **Database:** MySQL
- **Authentication:** Passwordless Email OTP (Gmail SMTP or SendGrid)

---

## ✨ Features

- Passwordless login using Email OTP (inspired by Temu system)
- User authentication without phone number (to avoid SMS costs)
- Google/Facebook login integration (future enhancement)
- API-first architecture with clear backend separation
- Secure handling of secrets via `.env` file

---

## 📂 Project Structure

```bash
umeT_app/
├── shopping_app/
│   └── lib/
│       └── backend_api/
│           └── backend.py   # FastAPI backend code
|       └── cus_wid
|       └── login
|       └── main.dart
├── sql/                     # SQL scripts & migrations
├── examples/                # Example/test data (optional)
├── .env                      # Environment variables (not committed)
├── .gitignore
└── README.md


for checking api : 
uvicorn shopping_app.lib.backend_api.backend:app --reload 
then check on :
http://127.0.0.1:8000/docs#/
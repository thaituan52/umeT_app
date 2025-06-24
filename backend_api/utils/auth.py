# ----------------------------------------
# Password Hashing Utility -- havent used yet
# ----------------------------------------
import hashlib
import os
from dotenv import load_dotenv

load_dotenv()
def hash_password(password: str) -> str:
    """Generate SHA-256 hash of the password with salt"""
    salt = os.getenv("PASSWORD_SALT", "default_salt")  # Always use a salt
    return hashlib.sha256((password + salt).encode()).hexdigest()
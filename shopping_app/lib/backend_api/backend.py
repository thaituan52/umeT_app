from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy import Boolean, create_engine, Column, Integer, String, TIMESTAMP
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from jose import jwt
from datetime import datetime, timedelta
import random
from typing import Optional

#Security imports
from dotenv import load_dotenv
import os

# Load .env file automatically
load_dotenv()

# Read variables
DATABASE_URL = os.getenv("DATABASE_URL") 
SECRET_KEY = os.getenv("SECRET_KEY")

# ----------------------------------------
# DATABASE CONFIGURATION
# ----------------------------------------

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# ----------------------------------------
# JWT CONFIGURATION
# ----------------------------------------
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # 7 days expiration

# ----------------------------------------
# DATABASE MODEL //need to use only needed fields here
# ----------------------------------------

class User(Base):
    __tablename__ = "user_info"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True)
    google_id = Column(String(100), unique=True, index=True)
    facebook_id = Column(String(100), unique=True, index=True)
    phone = Column(String(20), unique=True, index=True)
    first_name = Column(String(100))
    last_name = Column(String(100))
    profile_picture_url = Column(String(500))
    is_active = Column(Boolean, default=True)
    email_verified = Column(Boolean, default=False)
    phone_verified = Column(Boolean, default=False)
    last_login = Column(TIMESTAMP, nullable=True)
    created_at = Column(TIMESTAMP, default=datetime.now)
    updated_at = Column(TIMESTAMP, default=datetime.now, onupdate=datetime.now)

# Create tables if not exist
Base.metadata.create_all(bind=engine)

# ----------------------------------------
# FASTAPI APP INITIALIZATION
# ----------------------------------------

app = FastAPI()

# ----------------------------------------
# DATABASE SESSION DEPENDENCY
# ----------------------------------------

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ----------------------------------------
# MODELS / SCHEMAS
# ----------------------------------------

class GoogleLoginRequest(BaseModel):
    email: EmailStr
    google_id: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    profile_picture_url: Optional[str] = None


class TokenResponse(BaseModel):
    token: str
    user: dict


# ----------------------------------------
# HELPER FUNCTIONS - Gonna delete/ change later
# ----------------------------------------

def create_access_token(data: dict):
    expire = datetime.now() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

def print_user_debug_info(user: User, is_new_user: bool):
    """Print user info and last login for debugging"""
    print("=" * 50)
    print("🔍 USER DEBUG INFO")
    print("=" * 50)
    print(f"Status: {'NEW USER CREATED' if is_new_user else 'EXISTING USER FOUND'}")
    print(f"User ID: {user.id}")
    print(f"Email: {user.email}")
    print(f"Google ID: {user.google_id}")
    print(f"First Name: {user.first_name}")
    print(f"Last Name: {user.last_name}")
    print(f"Profile Picture: {user.profile_picture_url}")
    print(f"Email Verified: {user.email_verified}")
    print(f"Is Active: {user.is_active}")
    print(f"Created At: {user.created_at}")
    print(f"Last Login: {user.last_login}")
    print(f"Updated At: {user.updated_at}")
    print("=" * 50)

def create_user_response(user: User):
    """Create user response dictionary"""
    return {
        "id": user.id,
        "email": user.email,
        "google_id": user.google_id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "profile_picture_url": user.profile_picture_url,
        "is_active": user.is_active,
        "email_verified": user.email_verified,
        "last_login": user.last_login.isoformat() if user.last_login else None,
        "created_at": user.created_at.isoformat() if user.created_at else None
    }


# ----------------------------------------
# GOOGLE LOGIN ENDPOINT
# ----------------------------------------

@app.post("/api/google-login", response_model=TokenResponse)
def google_login(request: GoogleLoginRequest, db: Session = Depends(get_db)):
    is_new_user = False
    
    # Check if user exists by Google ID first
    user = db.query(User).filter(User.google_id == request.google_id).first()
    
    if not user:
        # Check if user exists by email
        user = db.query(User).filter(User.email == request.email).first()
        
        if user:
            print(f"📧 Found existing user by email: {request.email}")
            # Update existing user with Google ID
            user.google_id = request.google_id
            user.email_verified = True
            if request.profile_picture_url:
                user.profile_picture_url = request.profile_picture_url
            if request.first_name:
                user.first_name = request.first_name
            if request.last_name:
                user.last_name = request.last_name
        else:
            print(f"✨ Creating new user for: {request.email}")
            is_new_user = True
            # Create new user
            user = User(
                email=request.email,
                google_id=request.google_id,
                first_name=request.first_name,
                last_name=request.last_name,
                profile_picture_url=request.profile_picture_url,
                email_verified=True
            )
            db.add(user)
            db.commit()
            db.refresh(user)
    else:
        print(f"🔍 Found existing user by Google ID: {request.google_id}")

    # Update last login
    previous_last_login = user.last_login
    user.last_login = datetime.utcnow()
    user.updated_at = datetime.utcnow()
    db.commit()
    
    # Debug output
    print_user_debug_info(user, is_new_user)
    
    # Print last login comparison
    print("🕐 LAST LOGIN DEBUG:")
    print(f"Previous Last Login: {previous_last_login}")
    print(f"Current Last Login: {user.last_login}")
    print("=" * 50)

    # Generate JWT token
    token_data = {"sub": user.email, "user_id": user.id}
    token = create_access_token(token_data)

    return TokenResponse(
        token=token,
        user=create_user_response(user)
    )

# ----------------------------------------
# HEALTHCHECK (OPTIONAL)
# ----------------------------------------

@app.get("/")
def healthcheck():
    return {"status": "Backend is running"}

# ----------------------------------------
# NOTE: VIBE CODING AND NEED TO CHECK SERIOUSLY
# This code is a basic implementation and should be tested thoroughly.
# ----------------------------------------

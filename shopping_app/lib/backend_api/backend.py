from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from datetime import datetime
from typing import Optional
import hashlib
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL")

# Database setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ----------------------------------------
# SQLAlchemy Models
# ----------------------------------------

class User(Base):
    __tablename__ = "user_info"
    
    id = Column(Integer, primary_key=True, index=True)
    uid = Column(String(100), unique=True, index=True)  # Firebase UID
    provider = Column(String(50))  # google, facebook, email, phone
    identifier = Column(String(100))  # email or phone number
    photo_url = Column(String(500), nullable=True)
    display_name = Column(String(100), nullable=True)
    password_hash = Column(String(255), nullable=True)  # SHA-256 hashed password
    is_active = Column(Boolean, default=True)
    last_login = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

Base.metadata.create_all(bind=engine)

# ----------------------------------------
# Pydantic Models
# ----------------------------------------

class UserBase(BaseModel):
    uid: str
    provider: str
    identifier: str
    photo_url: Optional[str] = None
    display_name: Optional[str] = None
    is_active: Optional[bool] = True

class UserCreate(UserBase):
    password: Optional[str] = None  # Plain text password for email signups

class UserResponse(UserBase):
    id: int
    last_login: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# ----------------------------------------
# Password Hashing Utility
# ----------------------------------------

def hash_password(password: str) -> str:
    """Generate SHA-256 hash of the password with salt"""
    salt = os.getenv("PASSWORD_SALT", "default_salt")  # Always use a salt
    return hashlib.sha256((password + salt).encode()).hexdigest()

# ----------------------------------------
# FastAPI App
# ----------------------------------------

app = FastAPI()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ----------------------------------------
# Helper Functions
# ----------------------------------------

def get_user_by_uid(db: Session, uid: str):
    return db.query(User).filter(User.uid == uid).first()

def create_or_update_user(db: Session, user_data: dict):
    user = get_user_by_uid(db, user_data["uid"])
    
    # Hash password if provided
    if "password" in user_data and user_data["password"]:
        user_data["password_hash"] = hash_password(user_data["password"])
        del user_data["password"]
    
    if user:
        # Update existing user
        for key, value in user_data.items():
            if value is not None and hasattr(user, key):
                setattr(user, key, value)
        user.updated_at = datetime.utcnow()
    else:
        # Create new user
        user = User(**user_data)
        db.add(user)
    
    user.last_login = datetime.utcnow()
    db.commit()
    db.refresh(user)
    return user

# ----------------------------------------
# API Endpoints
# ----------------------------------------

@app.post("/users/", response_model=UserResponse)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    Create or update a user record from Firebase auth data.
    For email/password users, the password will be hashed.
    """
    db_user = create_or_update_user(db, user.dict())
    return db_user

@app.get("/users/{uid}", response_model=UserResponse)
async def read_user(uid: str, db: Session = Depends(get_db)):
    """Get user by Firebase UID"""
    db_user = get_user_by_uid(db, uid=uid)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@app.post("/users/verify-password")
async def verify_password(
    uid: str, 
    password: str, 
    db: Session = Depends(get_db)
):
    """
    Verify a password for email/password users.
    Returns boolean indicating if password is correct.
    """
    user = get_user_by_uid(db, uid)
    if not user or not user.password_hash:
        return {"valid": False}
    
    hashed_input = hash_password(password)
    return {"valid": hashed_input == user.password_hash}

# ----------------------------------------
# Health Check
# ----------------------------------------

@app.get("/")
def health_check():
    return {"status": "API is running"}
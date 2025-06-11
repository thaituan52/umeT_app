from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from jose import jwt
from datetime import datetime, timedelta
import random

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
# DATABASE MODEL
# ----------------------------------------

class User(Base):
    __tablename__ = "user_info"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(100), unique=True, index=True)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)

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

class OTPRequest(BaseModel):
    email: EmailStr

class OTPVerifyRequest(BaseModel):
    email: EmailStr
    code: str

class TokenResponse(BaseModel):
    token: str

# ----------------------------------------
# OTP IN-MEMORY STORAGE (TEMPORARY)
# ----------------------------------------

otp_store = {}

# ----------------------------------------
# JWT TOKEN GENERATOR
# ----------------------------------------

def create_access_token(data: dict):
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

# ----------------------------------------
# GOOGLE LOGIN ENDPOINT
# ----------------------------------------

@app.post("/api/google-login", response_model=TokenResponse)
def google_login(request: GoogleLoginRequest, db: Session = Depends(get_db)):
    # check if user exists
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        # create new user if not exist
        user = User(email=request.email)
        db.add(user)
        db.commit()
        db.refresh(user)

    # generate JWT token
    token_data = {"sub": user.email, "user_id": user.id}
    token = create_access_token(token_data)

    return TokenResponse(token=token)

# ----------------------------------------
# EMAIL OTP: REQUEST OTP ENDPOINT
# ----------------------------------------

@app.post("/api/request-otp")
def request_otp(request: OTPRequest):
    otp_code = f"{random.randint(100000, 999999)}"
    otp_store[request.email] = otp_code

    # For demo: just print instead of sending real email/SMS
    print(f"Send OTP to {request.email}: {otp_code}")

    return {"message": "OTP sent successfully"}

# ----------------------------------------
# EMAIL OTP: VERIFY OTP ENDPOINT
# ----------------------------------------

@app.post("/api/verify-otp", response_model=TokenResponse)
def verify_otp(request: OTPVerifyRequest, db: Session = Depends(get_db)):
    stored_otp = otp_store.get(request.email)

    if not stored_otp or stored_otp != request.code:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    # same logic as Google login
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        user = User(email=request.email)
        db.add(user)
        db.commit()
        db.refresh(user)

    token_data = {"sub": user.email, "user_id": user.id}
    token = create_access_token(token_data)

    return TokenResponse(token=token)

# ----------------------------------------
# HEALTHCHECK (OPTIONAL)
# ----------------------------------------

@app.get("/")
def healthcheck():
    return {"status": "Backend is running"}

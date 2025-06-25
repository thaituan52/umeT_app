# your_project/api/users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..schemas import UserCreate, UserResponse # Relative import
from ..crud import users as crud_users # Import crud functions
from ..database import get_db # Import DB dependency
from ..utils.auth import hash_password # For password verification

router = APIRouter(
    prefix="/users",
    tags=["Users"],
)

@router.post("/", response_model=UserResponse)
async def create_user_endpoint(user: UserCreate, db: Session = Depends(get_db)):
    """
    Create or update a user record from Firebase auth data.
    For email/password users, the password will be hashed.
    """
    try:
        db_user = crud_users.create_or_update_user(db, user.model_dump()) # Use model_dump() for Pydantic V2
        return db_user
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{uid}", response_model=UserResponse)
async def read_user_endpoint(uid: str, db: Session = Depends(get_db)):
    """Get user by Firebase UID"""
    db_user = crud_users.get_user_by_uid(db, uid=uid)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@router.post("/verify-password")
async def verify_password_endpoint(
    uid: str, 
    password: str, 
    db: Session = Depends(get_db)
):
    """
    Verify a password for email/password users.
    Returns boolean indicating if password is correct.
    """
    user = crud_users.get_user_by_uid(db, uid)
    if not user or not user.password_hash:
        return {"valid": False}
    
    hashed_input = hash_password(password)
    return {"valid": hashed_input == user.password_hash}
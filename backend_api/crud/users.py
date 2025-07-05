#CRUD for user
from sqlalchemy.orm import Session
from datetime import datetime, timezone
from typing import Optional

from ..models import User 
from ..schemas import UserCreate 
from ..utils.auth import hash_password 


def get_user_by_uid(db: Session, uid: str):
    return db.query(User).filter(User.uid == uid).first()

def create_or_update_user(db: Session, user_data: dict):
    # Extract password first if it exists
    password = user_data.pop('password', None)
    
    user = get_user_by_uid(db, user_data["uid"])
    
    # Hash password if provided and store in password_hash
    if password:
        user_data["password_hash"] = hash_password(password)
    
    if user:
        # Update existing user
        for key, value in user_data.items():
            if value is not None and hasattr(user, key):
                setattr(user, key, value)
        user.updated_at = datetime.now()
    else:
        # Create new user - now user_data doesn't contain 'password'
        user = User(**user_data)
        db.add(user)
    
    user.last_login = datetime.now()
    db.commit()
    db.refresh(user)
    return user
    #MAY WORK IN CASE NO PASSWORD LIKE CURRENT

# your_project/api/users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..schemas import ShippingAddressCreate, ShippingAddressResponse, ShippingAddressUpdate, UserCreate, UserResponse # Relative import
from ..crud import shipping_address as crud_addresses # Import crud functions
from ..database import get_db # Import DB dependency
from ..utils.auth import hash_password # For password verification

router = APIRouter(
    prefix="/user/{user_uid}/addresses",
    tags=["Shipping Addresses"],
)

@router.post("/", response_model=ShippingAddressResponse)
async def create_address_for_user(
    user_uid: str,
    address: ShippingAddressCreate,
    db: Session = Depends(get_db)
    ):
    db_address = crud_addresses.create_shipping_address(db, address, user_uid) # Use model_dump() for Pydantic V2
    if db_address is None:
        raise HTTPException(status_code=404, detail="Duplicate address")
    return db_address

@router.get("/", response_model=List[ShippingAddressResponse])
async def get_user_address(
    user_uid: str, 
    db: Session = Depends(get_db)):
    db_addresses = crud_addresses.get_addresses_by_user(db, user_uid)
    return db_addresses

@router.put("/{address_id}", response_model=ShippingAddressResponse)
async def update_user_address(
    address_id: int,
    address_update: ShippingAddressUpdate,
    db: Session = Depends(get_db)
):
    db_address = crud_addresses.update_shipping_address(db, address_id, address_update)
    if not db_address:
        raise HTTPException(status_code=404, detail="Address not found")
    return db_address

@router.delete("/{address_id}")
async def delete_address(
    address_id: int, 
    db: Session = Depends(get_db)):

    db_address = crud_addresses.delete_shipping_address(db, address_id)
    if not db_address:
        raise HTTPException(status_code=404, detail="Address logic error")
    return db_address
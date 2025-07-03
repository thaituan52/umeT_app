#CRUD for orders
from datetime import datetime, timezone
from sqlalchemy import null
from sqlalchemy.orm import Session

from ..schemas import ShippingAddressCreate, ShippingAddressUpdate
from ..models import ShippingAddress 

#check existence ?
def get_address_by_id(db: Session, address_id: int):
    return db.query(ShippingAddress).filter(ShippingAddress.id == address_id).first()

def get_addresses_by_user(db: Session, user_uid: str):
    return db.query(ShippingAddress).filter(ShippingAddress.user_uid == user_uid).all()

def create_shipping_address(db: Session, address: ShippingAddressCreate, user_uid: str):
    exist = db.query(ShippingAddress).filter(
        ShippingAddress.user_uid == user_uid,
        ShippingAddress.address == address.address).first()
    
    if exist:
        return None 
    should_be_default = address.is_default
    # Check if this is the very first address for this user
    total_addresses_for_user = db.query(ShippingAddress).filter(
        ShippingAddress.user_uid == user_uid
    ).count() 

    if total_addresses_for_user == 0:
        should_be_default = True

    if should_be_default:
        db.query(ShippingAddress).filter(
            ShippingAddress.user_uid == user_uid,
            ShippingAddress.is_default == True
        ).update({"is_default": False})

    db_address = ShippingAddress(
        user_uid=user_uid,
        address=address.address,
        is_default=should_be_default  
    )
    db.add(db_address)
    db.commit()
    db.refresh(db_address)
    return db_address

def update_shipping_address(db: Session, address_id: int, address_update: ShippingAddressUpdate):
    db_address = get_address_by_id(db, address_id)
    if not db_address:
        return None
    update_data = address_update.model_dump(exclude_unset=True)
    if update_data.get("is_default") is False and db_address.is_default is True:
        update_data["is_default"] = True
    

    if update_data.get("is_default") is True:
        db.query(ShippingAddress).filter( #Update the rest is_default to False
            ShippingAddress.user_uid == db_address.user_uid,
            ShippingAddress.is_default == True,
            ShippingAddress.id != address_id
        ).update({"is_default": False})

    for key, value in update_data.items():
        setattr(db_address, key, value)
    
    db.commit()
    db.refresh(db_address)
    return db_address

def delete_shipping_address(db: Session, address_id: int):
    db_address = db.query(ShippingAddress).filter(ShippingAddress.id == address_id).first()
    
    if not db_address:
        return None 
    user_uid = db_address.user_uid
    existing = db.query(ShippingAddress).filter(
        ShippingAddress.user_uid == user_uid,
        ShippingAddress.is_default == True).count()

    if db_address.is_default:
        if existing == 1:
            return None
        #if exist another shippingAddress, promote it to default, else not delete anymore
        other_address_to_promote = db.query(ShippingAddress).filter( 
            ShippingAddress.user_uid == db_address.user_uid,
            ShippingAddress.id != address_id
        ).order_by(ShippingAddress.created_at).first()
        
        if not other_address_to_promote:
            return None
        else:
            other_address_to_promote.is_default = True

    db.delete(db_address)
    db.commit()

    return db_address # Return the object that was just deleted



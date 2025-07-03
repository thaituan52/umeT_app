# Product endpoints
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from grpc import Status
from sqlalchemy.orm import Session
from typing import List, Optional

from ..models import Order, OrderItem

from ..schemas import OrderCreate,OrderResponse, OrderUpdate
from ..crud import orders as crud_orders # Import crud functions
from ..database import get_db # Import DB dependency

router = APIRouter(
    prefix="",
    tags=["Orders"],
)


@router.post("/orders/", response_model=OrderResponse)
async def create_order_endpoint(order: OrderCreate, db: Session = Depends(get_db)):
    """Create a new order with items"""
    try:
        db_order = crud_orders.create_order(db, order)
        return db_order
    except ValueError as e:
        # This will catch the ValueError from the CRUD function
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        # Catch other unexpected errors
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/orders/{order_id}", response_model=OrderResponse)
async def get_order(order_id: int, db: Session = Depends(get_db)):
    """Get order by ID"""
    order = crud_orders.get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@router.get("/users/{user_uid}/orders/", response_model=List[OrderResponse])
async def get_user_orders(
    user_uid: str, 
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    """Get all orders for a specific user"""
    orders = crud_orders.get_orders_by_user(db, user_uid, skip=skip, limit=limit)
    
    return orders

@router.get("/users/{user_uid}/cart/", response_model=OrderResponse)
async def get_user_cart_endpoint(user_uid: str, db: Session = Depends(get_db)):
    """Get user's active cart"""
    cart = crud_orders.get_user_cart(db, user_uid)
    if not cart:
        raise HTTPException(status_code=404, detail="Cart not found")
    
    return cart


# USING TO ADD ITEM TO CART
@router.post("/users/{user_uid}/cart/items/")
async def add_to_cart(
    user_uid: str,
    product_id: int,
    quantity: int = 1,
    db: Session = Depends(get_db)
):
    """Add item to user's cart"""
    try:
        cart = crud_orders.add_item_to_cart(db, user_uid, product_id, quantity)
        return {"message": "Item added to cart", "cart_id": cart.id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/orders/{order_id}", response_model=OrderResponse)
async def update_order_endpoint(
    order_id: int,
    order_update: OrderUpdate,
    db: Session = Depends(get_db)
):
    """Update an order"""
    try:
        db_order = crud_orders.update_order(db, order_id, order_update)
        if not db_order:
            raise HTTPException(status_code=404, detail="Order not found")
        return db_order
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/orders/{order_id}/status/{status}")
async def update_order_status(
    order_id: int,
    status: int,
    db: Session = Depends(get_db)
):
    """Update order status (0: deactivated, 1: cart, 2: processing, 3: completed)"""
    order = crud_orders.get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if status not in [0, 1, 2, 3]:
        raise HTTPException(status_code=400, detail="Invalid status. Must be 0, 1, 2, or 3")
    
    # Validate shipping address for processing/completed orders
    if status in [2, 3] and not order.shipping_address_id:
        raise HTTPException(
            status_code=400, 
            detail="Shipping address is required before moving order to processing or completed status"
        )
    # try:
    #     updated_order = crud_orders.update_order(db, order_id, OrderUpdate(status=status))
    #     if not updated_order:
    #         raise HTTPException(status_code=404, detail="Order not found")
    #     return updated_order
    # except Exception as e:
    #     raise HTTPException(status_code=400, detail=str(e))
    
    updated_order = crud_orders.update_order(db, order_id, OrderUpdate(status=status))
    return updated_order

@router.delete("/orders/{order_id}")
async def delete_order(order_id: int, db: Session = Depends(get_db)):
    """Delete an order (soft delete by setting status to 0)"""
    order = crud_orders.get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    order.status = 0  # Deactivated
    order.updated_at = datetime.now(timezone.utc)
    db.commit()
    
    return {"message": "Order deleted successfully"}

@router.delete("/order-items/{item_id}")
async def delete_order_item(item_id: int, db: Session = Depends(get_db)):
    """Remove an item from an order and recalculate total"""
    item = db.query(OrderItem).filter(OrderItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Order item not found")
    
    order_id = item.order_id
    db.delete(item)
    db.commit()
    
    # Recalculate order total
    order = crud_orders.get_order_by_id(db, order_id)
    if order:
        total_amount = crud_orders.calculate_order_total(db, order_id)
        order.total_amount = str(total_amount)
        order.updated_at = datetime.utcnow()
        db.commit()
    
    return order

# ----------------------------------------
# Additional Utility Endpoints
# ----------------------------------------

@router.get("/orders/")
async def get_all_orders(
    skip: int = 0,
    limit: int = 100,
    status: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Get all orders (admin endpoint)"""
    query = db.query(Order)
    
    if status is not None:
        query = query.filter(Order.status == status)
    
    orders = query.offset(skip).limit(limit).all()
    
    return orders
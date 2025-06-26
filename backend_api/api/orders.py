# Product endpoints
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from ..models import Order, OrderItem

from ..schemas import OrderCreate, OrderItemResponse, OrderResponse, OrderUpdate, ProductCreate, ProductResponse, ProductUpdate, UserResponse # Relative import
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
        
        # Build response with items
        items = []
        for item in db_order.items:
            items.append(OrderItemResponse(
                id=item.id,
                product_id=item.product_id,
                quantity=item.quantity,
                price_per_unit=float(item.price_per_unit),
                created_at=item.created_at
            ))
        
        return OrderResponse(
            id=db_order.id,
            user_uid=db_order.user_uid,
            status=db_order.status,
            total_amount=float(db_order.total_amount),
            shipping_address=db_order.shipping_address,
            billing_method=db_order.billing_method,
            contact_phone=db_order.contact_phone,
            created_at=db_order.created_at,
            updated_at=db_order.updated_at,
            items=items
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/orders/{order_id}", response_model=OrderResponse)
async def get_order(order_id: int, db: Session = Depends(get_db)):
    """Get order by ID"""
    order = crud_orders.get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Build response with items
    items = []
    for item in order.items:
        items.append(OrderItemResponse(
            id=item.id,
            product_id=item.product_id,
            quantity=item.quantity,
            price_per_unit=float(item.price_per_unit),
            created_at=item.created_at
        ))
    
    return OrderResponse(
        id=order.id,
        user_uid=order.user_uid,
        status=order.status,
        total_amount=float(order.total_amount),
        shipping_address=order.shipping_address,
        billing_method=order.billing_method,
        contact_phone=order.contact_phone,
        created_at=order.created_at,
        updated_at=order.updated_at,
        items=items
    )

@router.get("/users/{user_uid}/orders/", response_model=List[OrderResponse])
async def get_user_orders(
    user_uid: int, 
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    """Get all orders for a specific user"""
    orders = crud_orders.get_orders_by_user(db, user_uid, skip=skip, limit=limit)
    
    result = []
    for order in orders:
        items = []
        for item in order.items:
            items.append(OrderItemResponse(
                id=item.id,
                product_id=item.product_id,
                quantity=item.quantity,
                price_per_unit=float(item.price_per_unit),
                created_at=item.created_at
            ))
        
        result.append(OrderResponse(
            id=order.id,
            user_uid=order.user_uid,
            status=order.status,
            total_amount=float(order.total_amount),
            shipping_address=order.shipping_address,
            billing_method=order.billing_method,
            contact_phone=order.contact_phone,
            created_at=order.created_at,
            updated_at=order.updated_at,
            items=items
        ))
    
    return result

@router.get("/users/{user_uid}/cart/", response_model=OrderResponse)
async def get_user_cart_endpoint(user_uid: str, db: Session = Depends(get_db)):
    """Get user's active cart"""
    cart = crud_orders.get_user_cart(db, user_uid)
    if not cart:
        raise HTTPException(status_code=404, detail="Cart not found")
    
    # Build response with items
    items = []
    for item in cart.items:
        items.append(OrderItemResponse(
            id=item.id,
           # order_id=cart.id, #order id if need
            product_id=item.product_id,
            quantity=item.quantity,
            price_per_unit=float(item.price_per_unit),
            created_at=item.created_at
        ))
    
    return OrderResponse(
        id=cart.id,
        user_uid=cart.user_uid,
        status=cart.status,
        total_amount=float(cart.total_amount),
        shipping_address=cart.shipping_address,
        billing_method=cart.billing_method,
        contact_phone=cart.contact_phone,
        created_at=cart.created_at,
        updated_at=cart.updated_at,
        items=items
    )
# USING TO ADD ITEM TO CART
@router.post("/users/{user_uid}/cart/items/")
async def add_to_cart(
    user_uid: int,
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
        
        # Build response with items
        items = []
        for item in db_order.items:
            items.append(OrderItemResponse(
                id=item.id,
                product_id=item.product_id,
                quantity=item.quantity,
                price_per_unit=float(item.price_per_unit),
                created_at=item.created_at
            ))
        
        return OrderResponse(
            id=db_order.id,
            user_uid=db_order.user_uid,
            status=db_order.status,
            total_amount=float(db_order.total_amount),
            shipping_address=db_order.shipping_address,
            billing_method=db_order.billing_method,
            contact_phone=db_order.contact_phone,
            created_at=db_order.created_at,
            updated_at=db_order.updated_at,
            items=items
        )
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
    if status in [2, 3] and not order.shipping_address:
        raise HTTPException(
            status_code=400, 
            detail="Shipping address is required before moving order to processing or completed status"
        )
    
    order.status = status
    order.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "Order status updated", "order_id": order_id, "new_status": status}

@router.delete("/orders/{order_id}")
async def delete_order(order_id: int, db: Session = Depends(get_db)):
    """Delete an order (soft delete by setting status to 0)"""
    order = crud_orders.get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    order.status = 0  # Deactivated
    order.updated_at = datetime.utcnow()
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
    
    result = []
    for order in orders:
        items = []
        for item in order.items:
            items.append({
                "id": item.id,
                "product_id": item.product_id,
                "quantity": item.quantity,
                "price_per_unit": float(item.price_per_unit),
                "created_at": item.created_at
            })
        
        result.append({
            "id": order.id,
            "user_uid": order.user_uid,
            "status": order.status,
            "total_amount": float(order.total_amount),
            "shipping_address": order.shipping_address,
            "billing_method": order.billing_method,
            "contact_phone": order.contact_phone,
            "created_at": order.created_at,
            "updated_at": order.updated_at,
            "items": items
        })
    
    return result
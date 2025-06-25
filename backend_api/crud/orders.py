#CRUD for orders
from datetime import datetime, timezone
from sqlalchemy.orm import Session

from ..schemas import OrderCreate, OrderUpdate
from ..crud.products import get_product_by_id
from ..models import Order, OrderItem


def get_order_by_id(db: Session, order_id: int):
    return db.query(Order).filter(Order.id == order_id).first()

def get_orders_by_user(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(Order).filter(Order.user_id == user_id).offset(skip).limit(limit)

def get_user_cart(db: Session, user_id: int):
    return db.query(Order).filter(Order.user_id == user_id, Order.status == 1).first()


# may need OrderItem.order_id to be unique
def calculate_order_total(db: Session, order_id: int):
    items = db.query(OrderItem).filter(OrderItem.order_id == order_id)
    total = sum(float(item.price_per_unit) * item.quantity for item in items)
    return total

def _process_order_items(db: Session, order_id: int, items_data: list) -> float:
    """
    Helper function to add/update order items and calculate total amount.
    Assumes existing items for the order_id have been cleared if this is an update.
    """
    total_amount = 0.0
    for item_data in items_data:
        product = get_product_by_id(db, item_data['product_id'])
        if not product:
            raise ValueError(f"Product with ID {item_data['product_id']} not found")

        price_per_unit = str(item_data['price_per_unit'])
        db_item = OrderItem(
            order_id=order_id,
            product_id=item_data['product_id'],
            quantity=item_data['quantity'],
            price_per_unit=price_per_unit
        )
        db.add(db_item)
        total_amount += float(price_per_unit) * item_data['quantity']
    return total_amount

def update_order(db: Session, order_id: int, order_update: OrderUpdate):
    db_order = get_order_by_id(db, order_id)
    if not db_order:
        return None

    update_data = order_update.model_dump(exclude_unset=True)
    items_data = update_data.pop('items', None)

    # Update order fields
    for field, value in update_data.items():
        setattr(db_order, field, value)

    # Update items if provided
    if items_data is not None:
        # Remove existing items before adding new ones
        db.query(OrderItem).filter(OrderItem.order_id == order_id).delete()
        total_amount = _process_order_items(db, order_id, items_data)
        db_order.total_amount = str(total_amount)

    db_order.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(db_order)
    return db_order

def create_order(db: Session, order: OrderCreate):

    user_id = order.user_id
    requested_status = order.status

    existing_order = db.query(Order).filter(
        Order.user_id == user_id,
        Order.status == requested_status
    ).first()

    if(existing_order):
        order_update_data = order.model_dump(exclude_unset=True)
        order_update_data['items'] = order.items # Explicitly set items from OrderCreate
        order_update_obj = OrderUpdate(**order_update_data)
        
        try:
            # Call the update_order function to update the existing order
            db_order = update_order(db, existing_order.id, order_update_obj)
            return db_order
        except ValueError as e:
            # If product not found during item processing in update_order,
            # re-raise the error. update_order already handles commit/refresh.
            raise e
    else: 
        order_data = order.model_dump()
        items_data = order_data.pop('items', [])
        db_order = Order(**order_data)
        db.add(db_order)
        db.commit()
        db.refresh(db_order)

    try:
        total_amount = _process_order_items(db, db_order.id, items_data)
        db_order.total_amount = str(total_amount)
        db.commit()
        db.refresh(db_order)
    except ValueError as e:
        db.rollback() # Rollback the order creation if product not found
        raise e

    return db_order


def add_item_to_cart(db: Session, user_id: int, product_id: int, quantity: int):
    #Get or create cart for user
    cart = get_user_cart(db, user_id)
    if not cart:
        cart = Order(user_id=user_id, status = 1)
        db.add(cart)
        db.commit()
        db.refresh(cart)
    
    #Check product exist
    product = get_product_by_id(db, product_id)
    if not product:
        raise ValueError(f"Product with ID {product_id} not found")
    
    #Check if item already exists in cart
    existing_item = db.query(OrderItem).filter(
        OrderItem.order_id == cart.id,
        OrderItem.product_id == product_id
    ).first()

    if  existing_item:
        existing_item.quantity += quantity
    else:
        new_item = OrderItem(
            order_id = cart.id,
            product_id = product_id,
            quantity = quantity,
            price_per_unit = product.price
        )
        db.add(new_item)
    
    db.commit()
    total_amount = calculate_order_total(db, cart.id)
    cart.total_amount = str(total_amount)
    cart.updated = datetime.now(timezone.utc)
    db.commit()
    db.refresh(cart)

    return cart
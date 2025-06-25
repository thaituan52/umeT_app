#CRUD for orders
from sqlalchemy.orm import Session

from ..schemas import OrderCreate
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

def create_order(db: Session, order: OrderCreate):
    #Create the order and retrieve items data
    order_data = order.model_dump()
    items_data = order_data.pop('items', [])

    db_order = Order(**order_data)
    db.add(db_order)
    db.commit()
    db.refresh(db_order)

    #Add items to the order
    total_amount = 0.0

    for item_data in items_data:
        #Verify product exists
        product = get_product_by_id(db, item_data['product_id'])
        if not product:
            db.rollback()
            raise ValueError(f"Product with ID {item_data['product_id']} not found")
        
        
        price_per_unit = str(item_data['price_per_unit'])
        
        db_item = OrderItem(
            order_id = db_order.id,
            product_id = item_data['product_id'],
            quantity = item_data['quantity'],
            price_per_unit=price_per_unit
        )

        db.add(db_item)
        total_amount += float(price_per_unit) * item_data['quantity']

    # Update order total
    db_order.total_amount = str(total_amount)
    db.commit()
    db.refresh(db_order)

    return db_order
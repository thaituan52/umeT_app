# ----------------------------------------
# SQLAlchemy Models
# ----------------------------------------
from sqlalchemy import ForeignKey, Text, Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from .database import Base


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
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    category_products = relationship("ProductCategory", back_populates="category")


class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=True)
    image_url = Column(String(500), nullable=True)
    price = Column(String(10), nullable=False)  # Using String to handle decimal precision
    sold_count = Column(Integer, default=0)
    rating = Column(String(4), default="0.0")  # Using String for decimal precision
    review_count = Column(Integer, default=0)
    delivery_info = Column(String(255), nullable=True)
    seller_info = Column(String(255), nullable=True)
    stock_quantity = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


    product_categories = relationship("ProductCategory", back_populates="product")


class ProductCategory(Base):
    __tablename__ = "product_categories"
    
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)  
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)  
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    product = relationship("Product", back_populates="product_categories")
    category = relationship("Category", back_populates="category_products")


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    user_uid = Column(Text, ForeignKey("user_info.uid"), nullable = False)
    status = Column(Integer, default = 1) #0: deactivated, 1: cart, 2: processing, 3: completed
    total_amount = Column(String(10), default = 0.0)
    shipping_address = Column(Text, nullable = True)
    billing_method = Column(String(20), default = "Cash")
    contact_phone = Column(String(20), nullable = True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


    user = relationship("User")
    items = relationship("OrderItem", back_populates= "order")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable = False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable = False)
    quantity = Column(Integer, nullable = False)
    price_per_unit = Column(String(10), nullable = False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    order = relationship("Order", back_populates= "items")
    product = relationship("Product")
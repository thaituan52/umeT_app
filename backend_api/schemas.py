#Contains all schema models


# ----------------------------------------
# Pydantic Models
# ----------------------------------------

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ValidationInfo, field_validator


class UserBase(BaseModel):
    uid: str
    provider: str
    identifier: str
    photo_url: Optional[str] = None
    display_name: Optional[str] = None
    is_active: Optional[bool] = True

class UserCreate(UserBase):
    password: Optional[str] = None
    
    @field_validator('password')
    def validate_password(cls, v):
        if v is not None:
            if len(v) < 8:
                raise ValueError('Password must be at least 8 characters')
            if not any(c.isupper() for c in v):
                raise ValueError('Password must contain at least one uppercase letter')
            if not any(c.isdigit() for c in v):
                raise ValueError('Password must contain at least one digit')
        return v

class UserResponse(UserBase):
    id: int
    last_login: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None



class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    is_active: Optional[bool] = True

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    price: float
    sold_count: Optional[int] = 0
    rating: Optional[float] = 0.0
    review_count: Optional[int] = 0
    delivery_info: Optional[str] = None
    seller_info: Optional[str] = None
    stock_quantity: Optional[int] = 0
    is_active: Optional[bool] = True

class ProductCreate(ProductBase):
    category_ids: List[int] = []

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    price: Optional[float] = None
    sold_count: Optional[int] = None
    rating: Optional[float] = None
    review_count: Optional[int] = None
    delivery_info: Optional[str] = None
    seller_info: Optional[str] = None
    stock_quantity: Optional[int] = None
    is_active: Optional[bool] = None
    category_ids: Optional[List[int]] = None

class ProductResponse(ProductBase):
    id: int
    categories: List[CategoryResponse] = []
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None



class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    price_per_unit: float

class OrderItemCreate(OrderItemBase):
    pass

class OrderItemResponse(OrderItemBase):
    id: int
    created_at: datetime

    class Config:
        from_atrributes = True


class OrderBase(BaseModel):
    user_id: int
    status: Optional[int] = 1
    shipping_address: Optional[str] = None
    billing_method: Optional[str] = "Cash"
    contact_phone: Optional[str]= None


class OrderCreate(OrderBase):
    items: List[OrderItemCreate]

    @field_validator('shipping_address')
    def validate_shipping_address(cls, v, info: ValidationInfo):
        status = info.data.get('status',1)
        if status in [2,3] and not v:
            raise ValueError('Shipping address is required for processing and completed orders')
        return v


class OrderUpdate(BaseModel):
    status: Optional[int] = None
    shipping_address: Optional[str] = None
    billing_method: Optional[str] = None
    contact_phone: Optional[str] = None
    items: Optional[List[OrderItemCreate]] = None
    
    @field_validator('shipping_address')
    def validate_shipping_address(cls, v, info: ValidationInfo):
        status = info.data.get('status')
        # If updating status to processing/completed, require shipping address
        if status in [2, 3] and not v:
            raise ValueError('Shipping address is required when updating to processing or completed status')
        return v

class OrderResponse(BaseModel):
    id: int
    total_amount: float
    created_at: datetime
    updated_at: datetime
    items: List[OrderItemResponse]    

    class Config:
        from_attributes = True
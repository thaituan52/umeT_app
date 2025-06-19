from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, validator
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime, text
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from datetime import datetime
from typing import List, Optional
import hashlib
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

# Load environment variables
load_dotenv()

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL")

# Database setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ----------------------------------------
# SQLAlchemy Models
# ----------------------------------------

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
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow) #might delete
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow) #might delete

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
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ProductCategory(Base):
    __tablename__ = "product_categories"
    
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, nullable=False)
    category_id = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


Base.metadata.create_all(bind=engine)

# ----------------------------------------
# Pydantic Models
# ----------------------------------------

class UserBase(BaseModel):
    uid: str
    provider: str
    identifier: str
    photo_url: Optional[str] = None
    display_name: Optional[str] = None
    is_active: Optional[bool] = True

class UserCreate(UserBase):
    password: Optional[str] = None
    
    @validator('password')
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
# ----------------------------------------
# Password Hashing Utility
# ----------------------------------------

def hash_password(password: str) -> str:
    """Generate SHA-256 hash of the password with salt"""
    salt = os.getenv("PASSWORD_SALT", "default_salt")  # Always use a salt
    return hashlib.sha256((password + salt).encode()).hexdigest()

# ----------------------------------------
# FastAPI App
# ----------------------------------------

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
) # CORS configuration 

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ----------------------------------------
# Helper Functions
# ----------------------------------------

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





def get_category_by_id(db: Session, category_id: int):
    return db.query(Category).filter(Category.id == category_id).first()

#might change
def get_categories(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Category).filter(Category.is_active == True).offset(skip).limit(limit).all()

def create_category(db: Session, category: CategoryCreate):
    db_category = Category(**category.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

def get_product_by_id(db: Session, product_id: int):
    return db.query(Product).filter(Product.id == product_id).first()

def get_products(db: Session, skip: int = 0, limit: int = 100, category_id: Optional[int] = None):
    query = db.query(Product).filter(Product.is_active == True)
    
    if category_id:
        query = query.join(ProductCategory).filter(ProductCategory.category_id == category_id)
    
    return query.offset(skip).limit(limit).all()

def get_product_categories(db: Session, product_id: int):
    result = db.execute(
        text("""
        SELECT c.* FROM categories c
        JOIN product_categories pc ON c.id = pc.category_id
        WHERE pc.product_id = :product_id AND c.is_active = TRUE
        """),
        {"product_id": product_id}
    )
    return result.fetchall()

def create_product(db: Session, product: ProductCreate):
    # Convert float values to strings for database storage
    product_data = product.dict()
    category_ids = product_data.pop('category_ids', [])
    
    # Convert numeric fields to strings
    product_data['price'] = str(product_data['price'])
    if product_data.get('rating'):
        product_data['rating'] = str(product_data['rating'])
    
    db_product = Product(**product_data)
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    
    # Add category associations
    for category_id in category_ids:
        db_product_category = ProductCategory(product_id=db_product.id, category_id=category_id)
        db.add(db_product_category)
    
    db.commit()
    return db_product

def update_product(db: Session, product_id: int, product_update: ProductUpdate):
    db_product = get_product_by_id(db, product_id)
    if not db_product:
        return None
    
    update_data = product_update.dict(exclude_unset=True)
    category_ids = update_data.pop('category_ids', None)
    
    # Convert numeric fields to strings
    if 'price' in update_data:
        update_data['price'] = str(update_data['price'])
    if 'rating' in update_data and update_data['rating']:
        update_data['rating'] = str(update_data['rating'])
    
    # Update product fields
    for field, value in update_data.items():
        setattr(db_product, field, value)
    
    # Update categories if provided
    if category_ids is not None:
        # Remove existing category associations
        db.query(ProductCategory).filter(ProductCategory.product_id == product_id).delete()
        
        # Add new category associations
        for category_id in category_ids:
            db_product_category = ProductCategory(product_id=product_id, category_id=category_id)
            db.add(db_product_category)
    
    db_product.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_product)
    return db_product


# ----------------------------------------
# API Endpoints
# ----------------------------------------

@app.post("/users/", response_model=UserResponse)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    Create or update a user record from Firebase auth data.
    For email/password users, the password will be hashed.
    """
    try :
        db_user = create_or_update_user(db, user.dict())
        return db_user
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    

@app.get("/users/{uid}", response_model=UserResponse)
async def read_user(uid: str, db: Session = Depends(get_db)):
    """Get user by Firebase UID"""
    db_user = get_user_by_uid(db, uid=uid)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@app.post("/users/verify-password")
async def verify_password(
    uid: str, 
    password: str, 
    db: Session = Depends(get_db)
):
    """
    Verify a password for email/password users.
    Returns boolean indicating if password is correct.
    """
    user = get_user_by_uid(db, uid)
    if not user or not user.password_hash:
        return {"valid": False}
    
    hashed_input = hash_password(password)
    return {"valid": hashed_input == user.password_hash}




# Category endpoints
@app.post("/categories/", response_model=CategoryResponse)
async def create_category_endpoint(category: CategoryCreate, db: Session = Depends(get_db)):
    """Create a new category"""
    try:
        return create_category(db, category)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/categories/", response_model=List[CategoryResponse])
async def read_categories(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all active categories"""
    categories = get_categories(db, skip=skip, limit=limit)
    return categories

@app.get("/categories/{category_id}", response_model=CategoryResponse)
async def read_category(category_id: int, db: Session = Depends(get_db)):
    """Get category by ID"""
    category = get_category_by_id(db, category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

# Product endpoints
@app.post("/products/", response_model=ProductResponse)
async def create_product_endpoint(product: ProductCreate, db: Session = Depends(get_db)):
    """Create a new product"""
    try:
        db_product = create_product(db, product)
        
        # Get categories for response
        categories_data = get_product_categories(db, db_product.id)
        categories = []
        for cat_data in categories_data:
            categories.append(CategoryResponse(
                id=cat_data[0],
                name=cat_data[1],
                description=cat_data[2],
                icon=cat_data[3],
                is_active=cat_data[4],
                created_at=cat_data[5],
                updated_at=cat_data[6]
            ))
        
        # Convert string fields back to appropriate types for response
        response_data = {
            "id": db_product.id,
            "name": db_product.name,
            "description": db_product.description,
            "image_url": db_product.image_url,
            "price": float(db_product.price),
            "sold_count": db_product.sold_count,
            "rating": float(db_product.rating),
            "review_count": db_product.review_count,
            "delivery_info": db_product.delivery_info,
            "seller_info": db_product.seller_info,
            "stock_quantity": db_product.stock_quantity,
            "is_active": db_product.is_active,
            "categories": categories,
            "created_at": db_product.created_at,
            "updated_at": db_product.updated_at
        }
        
        return ProductResponse(**response_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/products/", response_model=List[ProductResponse])
async def read_products(
    skip: int = 0, 
    limit: int = 100, 
    category_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Get all active products, optionally filtered by category"""
    products = get_products(db, skip=skip, limit=limit, category_id=category_id)
    
    result = []
    for product in products:
        # Get categories for each product
        categories_data = get_product_categories(db, product.id)
        categories = []
        for cat_data in categories_data:
            categories.append(CategoryResponse(
                id=cat_data[0],
                name=cat_data[1],
                description=cat_data[2],
                is_active=cat_data[3],
                created_at=cat_data[4],
                updated_at=cat_data[5]
            ))
        
        # Convert string fields back to appropriate types
        response_data = {
            "id": product.id,
            "name": product.name,
            "description": product.description,
            "image_url": product.image_url,
            "price": float(product.price),
            "sold_count": product.sold_count,
            "rating": float(product.rating),
            "review_count": product.review_count,
            "delivery_info": product.delivery_info,
            "seller_info": product.seller_info,
            "stock_quantity": product.stock_quantity,
            "is_active": product.is_active,
            "categories": categories,
            "created_at": product.created_at,
            "updated_at": product.updated_at
        }
        
        result.append(ProductResponse(**response_data))
    
    return result

@app.get("/products/{product_id}", response_model=ProductResponse)
async def read_product(product_id: int, db: Session = Depends(get_db)):
    """Get product by ID"""
    product = get_product_by_id(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    # Get categories
    categories_data = get_product_categories(db, product.id)
    categories = []
    for cat_data in categories_data:
        categories.append(CategoryResponse(
            id=cat_data[0],
            name=cat_data[1],
            description=cat_data[2],
            is_active=cat_data[3],
            created_at=cat_data[4],
            updated_at=cat_data[5]
        ))
    
    # Convert string fields back to appropriate types
    response_data = {
        "id": product.id,
        "name": product.name,
        "description": product.description,
        "image_url": product.image_url,
        "price": float(product.price),
        "sold_count": product.sold_count,
        "rating": float(product.rating),
        "review_count": product.review_count,
        "delivery_info": product.delivery_info,
        "seller_info": product.seller_info,
        "stock_quantity": product.stock_quantity,
        "is_active": product.is_active,
        "categories": categories,
        "created_at": product.created_at,
        "updated_at": product.updated_at
    }
    
    return ProductResponse(**response_data)

@app.put("/products/{product_id}", response_model=ProductResponse)
async def update_product_endpoint(
    product_id: int, 
    product_update: ProductUpdate, 
    db: Session = Depends(get_db)
):
    """Update a product"""
    try:
        db_product = update_product(db, product_id, product_update)
        if not db_product:
            raise HTTPException(status_code=404, detail="Product not found")
        
        # Get categories for response
        categories_data = get_product_categories(db, db_product.id)
        categories = []
        for cat_data in categories_data:
            categories.append(CategoryResponse(
                id=cat_data[0],
                name=cat_data[1],
                description=cat_data[2],
                is_active=cat_data[3],
                created_at=cat_data[4],
                updated_at=cat_data[5]
            ))
        
        # Convert string fields back to appropriate types for response
        response_data = {
            "id": db_product.id,
            "name": db_product.name,
            "description": db_product.description,
            "image_url": db_product.image_url,
            "price": float(db_product.price),
            "sold_count": db_product.sold_count,
            "rating": float(db_product.rating),
            "review_count": db_product.review_count,
            "delivery_info": db_product.delivery_info,
            "seller_info": db_product.seller_info,
            "stock_quantity": db_product.stock_quantity,
            "is_active": db_product.is_active,
            "categories": categories,
            "created_at": db_product.created_at,
            "updated_at": db_product.updated_at
        }
        
        return ProductResponse(**response_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.delete("/products/{product_id}")
async def delete_product(product_id: int, db: Session = Depends(get_db)):
    """Soft delete a product (set is_active to False)"""
    product = get_product_by_id(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    product.is_active = False
    product.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "Product deleted successfully"}

@app.get("/products/category/{category_id}", response_model=List[ProductResponse])
async def get_products_by_category(
    category_id: int, 
    skip: int = 0, 
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all products in a specific category"""
    return await read_products(skip=skip, limit=limit, category_id=category_id, db=db)

# ----------------------------------------
# Health Check
# ----------------------------------------

@app.get("/")
def health_check():
    return {"status": "API is running"}
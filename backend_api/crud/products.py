#CRUD for products
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import or_, text
from sqlalchemy.orm import Session

from ..models import Product, ProductCategory 
from ..schemas import ProductCreate, ProductUpdate 




def get_product_by_id(db: Session, product_id: int):
    return db.query(Product).filter(Product.id == product_id).first()

def get_products(
        db: Session, 
        skip: int = 0, 
        limit: int = 100, 
        category_id: Optional[int] = None, 
        q: Optional[str] = None
    ):
    query = db.query(Product).filter(Product.is_active == True)
    
    if category_id:
        query = (
            query
            .join(ProductCategory, Product.id == ProductCategory.product_id)
            .filter(ProductCategory.category_id == category_id)
        )
    if q and q.strip():
        search_term = f"%{q.strip()}%"
        query = query.filter(
            or_(
                Product.name.ilike(search_term),
                Product.description.ilike(search_term)
            )
        )
    #print(str(query.statement.compile(compile_kwargs={"literal_binds": True})))
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
    
    update_data = product_update.model_dump(exclude_unset=True)
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
    
    db_product.updated_at = datetime.now()
    db.commit()
    db.refresh(db_product)
    return db_product
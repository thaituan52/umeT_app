# Product endpoints
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from ..schemas import CategoryResponse, ProductCreate, ProductResponse, ProductUpdate, UserResponse # Relative import
from ..crud import products as crud_products # Import crud functions
from ..database import get_db # Import DB dependency

router = APIRouter(
    prefix="/products",
    tags=["Products"],
)


@router.post("/", response_model=ProductResponse)
async def create_product_endpoint(product: ProductCreate, db: Session = Depends(get_db)):
    """Create a new product"""
    try:
        db_product = crud_products.create_product(db, product)
        
        # Get categories for response
        categories_data = crud_products.get_product_categories(db, db_product.id)
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

@router.get("/", response_model=List[ProductResponse])
async def read_products(
    skip: int = 0, 
    limit: int = 100, 
    category_id: Optional[int] = None,
    q: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all active products, optionally filtered by category"""
    products = crud_products.get_products(db, skip=skip, limit=limit, category_id=category_id, q = q)
    
    result = []
    for product in products:
        # Get categories for each product
        categories_data = crud_products.get_product_categories(db, product.id)
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

@router.get("/{product_id}", response_model=ProductResponse)
async def read_product(product_id: int, db: Session = Depends(get_db)):
    """Get product by ID"""
    product = crud_products.get_product_by_id(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    # Get categories
    categories_data = crud_products.get_product_categories(db, product.id)
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

@router.put("/{product_id}", response_model=ProductResponse)
async def update_product_endpoint(
    product_id: int, 
    product_update: ProductUpdate, 
    db: Session = Depends(get_db)
):
    """Update a product"""
    try:
        db_product = crud_products.update_product(db, product_id, product_update)
        if not db_product:
            raise HTTPException(status_code=404, detail="Product not found")
        
        # Get categories for response
        categories_data = crud_products.get_product_categories(db, db_product.id)
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

@router.delete("/{product_id}")
async def delete_product(product_id: int, db: Session = Depends(get_db)):
    """Soft delete a product (set is_active to False)"""
    product = crud_products.get_product_by_id(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    product.is_active = False
    product.updated_at = datetime.now()
    db.commit()
    
    return {"message": "Product deleted successfully"}

@router.get("/category/{category_id}", response_model=List[ProductResponse])
async def get_products_by_category(
    category_id: int, 
    skip: int = 0, 
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all products in a specific category"""
    return await read_products(skip=skip, limit=limit, category_id=category_id, db=db)

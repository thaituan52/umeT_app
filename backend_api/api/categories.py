# Category endpoints

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..schemas import CategoryCreate, CategoryResponse, UserResponse # Relative import
from ..crud import categories as crud_categories # Import crud functions
from ..database import get_db # Import DB dependency

router = APIRouter(
    prefix="/categories",
    tags=["Categories"],
)
@router.post("/", response_model=CategoryResponse)
async def create_category_endpoint(category: CategoryCreate, db: Session = Depends(get_db)):
    """Create a new category"""
    try:
        return crud_categories.create_category(db, category)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[CategoryResponse])
async def read_categories(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all active categories"""
    categories = crud_categories.get_categories(db, skip=skip, limit=limit)
    return categories

@router.get("/{category_id}", response_model=CategoryResponse)
async def read_category(category_id: int, db: Session = Depends(get_db)):
    """Get category by ID"""
    category = crud_categories.get_category_by_id(db, category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category
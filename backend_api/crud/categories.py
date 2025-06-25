#CRUD for categories
from sqlalchemy.orm import Session

from ..models import Category 
from ..schemas import CategoryCreate 


def get_category_by_id(db: Session, category_id: int):
    return db.query(Category).filter(Category.id == category_id).first()

#might change
def get_categories(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Category).filter(Category.is_active == True).offset(skip).limit(limit).all()

def create_category(db: Session, category: CategoryCreate):
    db_category = Category(**category.model_dump())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category
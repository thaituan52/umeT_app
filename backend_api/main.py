# your_project/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import your database base for metadata.create_all
from .database import Base, engine 
# Import your API routers
from .api import users, categories, products, orders # Assuming you'll create these

app = FastAPI(
    title="Shopping_app API",
    description="A simple e-commerce backend with users, categories, products, and orders.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(users.router)
app.include_router(categories.router)
app.include_router(products.router)
app.include_router(orders.router)

# Health Check
@app.get("/")
def health_check():
    return {"status": "API is running"}

# Optional: Create database tables on startup (good for development, use migrations in production)
@app.on_event("startup")
async def startup_event():
    Base.metadata.create_all(bind=engine)
    print("Database tables created/checked.")
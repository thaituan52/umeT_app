# your_project/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import your database base for metadata.create_all
from .database import Base, engine 
# Import your API routers
from .api import users, categories, products, orders, shipping_address # Assuming you'll create these`

# Optional: Create database tables on startup (good for development, use migrations in production)
@asynccontextmanager
async def lifespan(app: FastAPI):
    # --- startup code ---
    Base.metadata.create_all(bind=engine)
    print("Database tables created/checked.")
    # now the app starts serving requests
    yield
    # --- shutdown code (optional) ---
    # e.g. await some_client.disconnect()`

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
app.include_router(shipping_address.router)

# Health Check
@app.get("/")
def health_check():
    return {"status": "API is running"}


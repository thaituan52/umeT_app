#SETTING UP THE DB FOR THE API ENDPOINT


# Load environment variables
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


load_dotenv()

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL")

# Database setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Dependency to get a DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# You can keep Base.metadata.create_all here or move it to a script
# that's run once for database initialization. For development, keeping it
# here is common, but in production, you'd use Alembic migrations.
# Base.metadata.create_all(bind=engine)
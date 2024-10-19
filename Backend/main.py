from fastapi import FastAPI
from api.routes import router as auth_router

app = FastAPI()

# Register authentication routes
app.include_router(auth_router)

# Root route for testing
@app.get("/")
def root():
    return {"message": "Welcome to the Proximity-based Professional Locator API"}

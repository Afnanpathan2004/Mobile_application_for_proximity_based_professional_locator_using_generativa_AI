from fastapi import FastAPI
from api.routes import router as auth_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Register authentication routes
app.include_router(auth_router)

# Root route for testing
@app.get("/")
def root():
    return {"message": "Welcome to the Proximity-based Professional Locator API"}

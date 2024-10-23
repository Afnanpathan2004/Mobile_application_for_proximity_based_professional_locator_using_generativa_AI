from fastapi import FastAPI
from api.routes import router as auth_router
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import os
from fastapi.staticfiles import StaticFiles

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
base_dir = os.path.dirname(os.path.abspath(__file__))  
# print (base_dir)
web_dir = os.path.join(base_dir, "..", "new_project", "build", "web")
# print (web_dir)
app.mount("/", StaticFiles(directory=web_dir, html=True), name="static")
# Root route for testing
@app.get("/")
async def serve_index():
    # Get the current directory of the Python file
    file_path =os.path.join(base_dir, "..", "new_project", "build", "web", "index.html")  # Navigate to the correct path
    # print(file_path)

    if not os.path.exists(file_path):
        return {"error": "File not found"}
    
    return FileResponse(file_path)

@app.get("/{full_path:path}")
async def serve_files(full_path: str):
    return FileResponse(os.path.join("build", "web", full_path))
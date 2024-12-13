from passlib.context import CryptContext
from fastapi import Depends, HTTPException, Response
from pymongo import MongoClient
from fastapi.security import OAuth2PasswordRequestForm
from .jwt import create_access_token
from datetime import timedelta
import os
from dotenv import load_dotenv
load_dotenv()

# Token expiration time
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_MINUTES = 525600

# connecting Mongo
client = MongoClient(os.getenv('mongo'))
db = client["Mini_Project"]
collection = db["User_Auth"]


# hashing password
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password : str):
    return pwd_context.hash(password)

# verifying passwords
def verify_password(plain_password:str, hashed_password:str):
    return pwd_context.verify(plain_password, hashed_password)

# authenticate user
async def authenticate_user (username : str, password : str) :
    # user = await collection.find_one({'username':username})
    user = collection.find_one({'username':username})
    # print(user)
    if user and verify_password(password, user['hashed_password']) :
        return user
    return None

# register user
async def register_user (username : str, password : str, dob: str, profession: str, address: str, pincode: str, contact_number: str, email: str, latitude: str, longitude: str) :
    hashed_password = hash_password(password)
    hashed_contact = hash_password(contact_number)

    # user = await collection.insert_one({'username':username, 'hashed_password':hashed_password})
    user = collection.insert_one({'username':username,
                                'hashed_password':hashed_password,
                                'dob': dob,
                                'profession': profession,
                                'address': address,
                                'pincode': pincode,
                                'contact_number': hashed_contact,
                                'email': email,
                                'latitude': latitude,
                                'longitude': longitude,
                                })
    return user


# login user
async def login_for_access_token(response: Response, form_data: OAuth2PasswordRequestForm = Depends()):
    # print(form_data)
    user = await authenticate_user(form_data.username, form_data.password)
    # print(user)
    if not user:
        raise HTTPException(status_code=401, detail="Incorrect username or password")
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    refresh_token_expires = timedelta(minutes= REFRESH_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(data={'sub' : user['username']}, expires_delta=access_token_expires)
    refresh_token = create_access_token(data={'sub' : user['username']}, expires_delta=refresh_token_expires)
    # Set secure HTTP-only cookies for access and refresh tokens
    response.set_cookie(
        key="access_token",
        value=f"Bearer {access_token}",
        httponly=True,                 # Prevents JavaScript from accessing the token
        secure=True,                   # Ensures it's only sent over HTTPS
        samesite="Lax",                # Helps prevent CSRF attacks
        max_age=ACCESS_TOKEN_EXPIRE_MINUTES * 60  # Expiry in seconds
    )

    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,                 # Prevents JavaScript from accessing the token
        secure=True,                   # Ensures it's only sent over HTTPS
        samesite="Lax",                # Helps prevent CSRF attacks
        max_age=REFRESH_TOKEN_EXPIRE_MINUTES * 60  # Expiry in seconds
    )
    return {"message": "User logged in successfully!"}
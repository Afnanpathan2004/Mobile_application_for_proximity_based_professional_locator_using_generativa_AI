from datetime import datetime, timedelta
from jose import jwt, JWTError
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from pydantic import ValidationError
from typing import Optional
import os
from dotenv import load_dotenv

load_dotenv()
Secret_key = os.getenv('Secret_key')
algo = 'HS256'
Access_token_expire_minutes = 30
REFRESH_TOKEN_EXPIRE_DAYS = 365

oauth2 = OAuth2PasswordBearer(tokenUrl='token')

# Creating token
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=Access_token_expire_minutes)
    to_encode.update({'exp':expire})
    encoded_jwt = jwt.encode(to_encode, Secret_key, algorithm=algo)
    return encoded_jwt

# verifying token 
def verify_token(token: str, credentials_exception):
    try:
        payload = jwt.decode(token, Secret_key, algorithms=[algo])
        username: str = payload.get("sub")
        # print("userID", username)
        if username is None:
            raise credentials_exception
        return username
    except JWTError as e:
        if "expired" in str(e):
            raise HTTPException(status_code=401, detail="Access token has expired.")
        raise credentials_exception
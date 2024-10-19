from fastapi import APIRouter, Depends, HTTPException, status, Response, Cookie
from fastapi.security import OAuth2PasswordRequestForm
from auth.user_auth import register_user, login_for_access_token, collection, ACCESS_TOKEN_EXPIRE_MINUTES
from auth.jwt import verify_token, Secret_key, algo
from auth.user_schema import UserCreate, Token
from auth.jwt import oauth2, create_access_token
from jose import JWTError, jwt
from datetime import timedelta

router = APIRouter()


# Register a new user
@router.post("/register", status_code=201)
async def register(user: UserCreate):
    # existing_user = await collection.find_one({"username": user.username})
    existing_user = collection.find_one({"username": user.username})
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    new_user = await register_user(user.username, user.password)
    return {"message": "User registered successfully"}


@router.get("/refresh")
async def refresh_token(refresh_token: str = Cookie(None)):
    if refresh_token is None : 
        raise HTTPException(status_code=403, detail='Refresh token not found!!')
    try:
        payload = jwt.decode(refresh_token, Secret_key, algorithms=[algo])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=403, detail="Invalid refresh token")
    except JWTError:
        raise HTTPException(status_code=403, detail="refresh token expired, login Again!!")

    # Generate new access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    new_access_token = create_access_token(data={"sub": username}, expires_delta=access_token_expires)

    return new_access_token


# User login and token generation
@router.post("/token")
async def login(response: Response, form_data: OAuth2PasswordRequestForm = Depends()):
    return await login_for_access_token(response, form_data)


# Protected route example: Only accessible with valid token
@router.get("/users/me")
async def read_users_me(response:Response, access_token: str = Cookie(None)):
    if not access_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing access token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    # print(f"Received token: {token}")
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    if access_token.startswith("Bearer "):
        access_token = access_token[len("Bearer "):]
    
    try:
        username = verify_token(access_token, credentials_exception)
    except HTTPException as e:
        if e.status_code == 401 and "expired" in str(e.detail):
            # Attempt to refresh the token
            new_access_token = await refresh_token()
            # Optionally, set the new access token in the cookies
            response.set_cookie(key="access_token", value=f"Bearer {new_access_token}", httponly=True, secure=True, samesite='lax')
            username = verify_token(new_access_token, credentials_exception) 
        else:
            raise e
    user = collection.find_one({"username": username})
    if not user:
        raise credentials_exception
    
    return {"message": 'Authenticated' }

# Logout
@router.post("/logout")
async def logout(response: Response):
    # Clear the access token cookie by setting it with an expired time
    response.delete_cookie("access_token")
    
    return {"message": "Successfully logged out"}

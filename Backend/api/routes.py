from fastapi import APIRouter, Depends, HTTPException, status, Response, Cookie, Body
from fastapi.security import OAuth2PasswordRequestForm
from auth.user_auth import register_user, login_for_access_token, collection, ACCESS_TOKEN_EXPIRE_MINUTES
from auth.jwt import verify_token, Secret_key, algo
from auth.user_schema import UserCreate, Token, Message, MessageSchema
from Community.community import message_analysis, display_messages, update_DB
from auth.jwt import oauth2, create_access_token
from jose import JWTError, jwt
from datetime import timedelta
from pymongo import MongoClient
import json
from datetime import datetime, timedelta
import asyncio
from fastapi.websockets import WebSocket
import os

router = APIRouter()
active_connections = {}

# connecting Mongo
client = MongoClient(os.getenv('mongo'))
db = client["Mini_Project"]
community_coll = db["Community"]
Chat = db["Chat"]

# Register a new user
@router.post("/register", status_code=201)
async def register(user: UserCreate):
    # existing_user = await collection.find_one({"username": user.username})
    # print(user)
    existing_user = collection.find_one({"username": user.username})
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    new_user = await register_user(
        user.username,
        user.password,
        user.dob,
        user.profession,
        user.address,
        user.pincode,
        user.contact_number,
        user.email,
        user.latitude,
        user.longitude,)
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
async def logout(response: Response, access_token: str = Cookie(None)):
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
    # Clear the access token cookie by setting it with an expired time
    response.delete_cookie("access_token")
    
    return {"message": "Successfully logged out"}


# Search 
@router.post("/search")
async def search(response:Response, query:str = Body(...), access_token: str = Cookie(None)):
    query = query.lower()
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
    
    # Extract user's current location (latitude, longitude)
    user_location = user.get("location")
    if not user_location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User location not found",
        )
    
    # MongoDB query to search for professionals of the given profession near the current user
    search_results = collection.find(
        {
            "profession": query,  
            "location": {
                "$nearSphere": {
                    "$geometry": {
                        "type": "Point",
                        "coordinates": [user_location["coordinates"][0], user_location["coordinates"][1]]  
                    },
                    "$maxDistance": 5000  
                }
            }
        }
    )
    
# Collect and return the search results
    results = []
    for result in search_results:
        results.append({
            "username": result["username"],
            "profession": result["profession"],
            "location": result["location"],
            "address": result["address"],
            "contact_number": result["contact_number"],
        })
    
    return {"message": "Search results", "data": results}


# Community Chat 
@router.post("/community")
async def community(response:Response, message_data: Message, access_token: str = Cookie(None) ):
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
    
    # Validate the message
    if not message_data.message.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Message cannot be empty.",
        )
    sentiment = message_analysis(message_data.message)
    # print(sentiment)
    if sentiment == "negative":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Follow the community guidelines. Negative messages are not allowed."
        )
    # Store Message in MongoDB
    message_entry = {
        "username": username,
        "message": message_data.message,
        "timestamp": datetime.utcnow()
    }
    community_coll.insert_one(message_entry)
    return  {"success": True, "message": message_data.message, "sentiment": sentiment}


# Display Community Chat
@router.get("/display_community")
async def  community_load (response:Response, access_token: str = Cookie(None)):
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
    
    # Update the Community DB
    update_DB()
    
    # Display messages
    community_dislpay_messages = display_messages()
    return community_dislpay_messages



# Real time chat

# 1. Fetch Chat History
@router.get("/chat/{professional_username}")
async def get_chat(response: Response, professional_username: str, access_token: str = Cookie(None)):
    """Fetch chat history between logged-in user and the selected professional."""
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

    chat = Chat.find_one({"$or": [
        {"user 1": username, "user 2": professional_username},
        {"user 1": professional_username, "user 2": username}
    ]})
    
    if chat:
        return {"messages": chat["messages"]}
    
    return {"messages": []}  # Return empty if no chat history


# 2. Send Message
@router.post("/chat/send")
async def send_message(response: Response, message_data: MessageSchema, access_token: str = Cookie(None)):
    """Send a message and update chat history."""
    
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

    chat = Chat.find_one({"$or": [
        {"user 1": username, "user 2": message_data.receiver},
        {"user 1": message_data.receiver, "user 2": username}
    ]})
    
    new_message = {
        "text": message_data.message,
        "timestamp": datetime.utcnow(),
        "sender": username
    }

    if chat:
        Chat.update_one({"_id": chat["_id"]}, {"$push": {"messages": new_message}, "$set": {"last_updated": datetime.utcnow()}})
    else:
        Chat.insert_one({
            "user 1": username,
            "user 2": message_data.receiver,
            "messages": [new_message],
            "last_updated": datetime.utcnow()
        })
    if message_data.receiver in active_connections:
                await active_connections[message_data.receiver].send_text(
                    json.dumps({"message": message_data.message, "sender": username, "receiver": message_data.receiver})
                )    

    return {"success": True, "message": "Message sent!"}


# 3. Establish 1-1 Chat 
@router.websocket("/chat/ws/{sender}")
async def chat_ws(websocket: WebSocket, sender: str):
    await websocket.accept()  # Accept the WebSocket connection
    active_connections[sender] = websocket  # Store WebSocket connection for this receiver

    try:
        while True:
            data = await websocket.receive_text()  # Receive data from client
    except Exception as e:
        print("Error:", e)  # Print any exceptions that occur
    finally:
        # Unregister the user when the WebSocket connection closes
        active_connections.pop(sender, None)
        await websocket.close()  # Close the WebSocket connection

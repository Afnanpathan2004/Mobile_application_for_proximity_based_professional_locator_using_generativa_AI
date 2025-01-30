import google.generativeai as genai
from dotenv import load_dotenv
from datetime import datetime, timedelta
from pymongo import MongoClient
import os
load_dotenv()

# Connecting to MongoDB
client = MongoClient(os.getenv('mongo'))
db = client["Mini_Project"]
messages_collection = db["Community"]

# Fetching the API Key
api_key = os.getenv("LLM")
if not api_key:
    raise EnvironmentError("LLM API key not found. Please check your .env file.")

# Configuring LLM
genai.configure(api_key = api_key)
model = genai.GenerativeModel("gemini-1.5-flash")

# Function to determine the message sentiment
def message_analysis(message_data):
    prompt = f"""Act as a professional sentiment analyzer and analyze the sentiment of the message on the basis of its context and not just the tone ex(the message can be in any language) given below in just one word (positive/negative/neutral):
    Message: "{message_data}"."""
    try:
        response = model.generate_content(prompt)
        # print(response)
        sentiment = response.text.strip().lower()
        return sentiment
    except Exception as e:
        raise RuntimeError("Failed to analyze sentiment." + str(e))
    

# Fetching the Community Chat messaages of past 2 days only
def display_messages():
    expiry_time = datetime.utcnow() - timedelta(days=2)
    messages = list(messages_collection.find({"timestamp": {"$gte": expiry_time}}, {"_id": 0}))
    return {"messages": messages}

# Updating the Community DB by deleting messages older than 2 days
def update_DB():
    expiry_time = datetime.utcnow() - timedelta(days=2)
    messages_collection.delete_many({"timestamp": {"$lt": expiry_time}})
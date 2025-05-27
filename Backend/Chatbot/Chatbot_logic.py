from pymongo import MongoClient 
import google.generativeai as genai
from dotenv import load_dotenv
import os

# Loading gemini
load_dotenv()
gemini_api_key = os.getenv("LLM")
if not gemini_api_key:
    raise ValueError("GEMINI_API_KEY environment variable not set")
genai.configure(api_key=gemini_api_key)
model = genai.GenerativeModel("gemini-1.5-flash")


# Connecting to Mongo
Mongo_url = os.getenv('mongo')
client = MongoClient(Mongo_url)
db = client["Mini_Project"]
convo = db["Chatbot"]


def get_chatbot_response(user_message, user_id,  is_first_message=False):
    user_data = convo.find_one({'username': user_id})
    # print(user_data)
    if not user_data:
        convo.insert_one({'username': user_id})
        convo.update_one(
        {'username': user_id},  
        {'$set': {'conversation_log': []}}  
        )
        is_first_message = True
        convo_log = []
    else:    
        convo_log = user_data.get('conversation_log', [])
    if is_first_message:
        prompt = "Ask only the content given in the backticks `Hello! How can I assist you today?`"
    else:
        prompt = f"""Role: You are an AI assistant for the **Proximity-Based Professional Locator** project. Your role is to assist users with queries related to the project while maintaining professionalism and ethical standards.

**Project Overview**:
- **Objective**: Help users find nearby professionals (e.g., plumbers, electricians, tutors, doctors) based on location and service preferences.
- **Key Features**:
    1. Location-based search.
    2. AI-powered recommendations (ratings, reviews, user preferences).
    3. Verified professional profiles.
    4. Direct contact and booking options.
    5. Category-based filtering (profession type, ratings, availability).
    6. Real-time updates from professionals.

**Response Guidelines**:
1. **Relevant Queries**: Only answer questions directly related to the project. Provide accurate, concise, and helpful information.
2. **Out-of-Scope Queries**: Politely redirect users to focus on the project. Example: "I specialize in the Proximity-Based Professional Locator. How can I assist you with it?"
3. **Inappropriate Queries**: Decline to engage. Example: "I cannot assist with unethical or illegal activities. Let me know how I can help with the project."

**Response Format**:
- Always respond directly to the user's query without adding unrelated information or follow-up questions.
- Example:
    - User: "How does the system rank professionals?"
    - Response: "Professionals are ranked based on ratings, reviews, location proximity, and service quality using machine learning algorithms.
    
    User Query: {user_message}"""

    response = model.generate_content(prompt)
    bot_response = response.text

    convo_log.append({
        "user_message": user_message,
        "bot_response": bot_response
    })
    convo.update_one(
        {'username': user_id},
        {'$set': {'conversation_log': convo_log}}
    )

    return bot_response, convo_log


def get_conversation_history(user_id):
    user_data = convo.find_one({'username': user_id})
    if user_data and 'conversation_log' in user_data:
        convo_log = user_data.get('conversation_log', [])
        return convo_log
    else:
        convo.insert_one({'username': user_id})
        convo.update_one(
        {'username': user_id},  
        {'$set': {'conversation_log': []}}  
        )
        return []
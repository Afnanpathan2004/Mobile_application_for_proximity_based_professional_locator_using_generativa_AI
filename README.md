📍 Mobile application for proximity based professional locator using generativa AI
A mobile application that connects users with nearby professionals—doctors, electricians, tutors, and more—through geolocation and machine learning-based recommendations.

🔍 Overview:

The Proximity-Based Professional Locator (PBPL) is a smart mobile application designed to simplify how users discover, connect, and interact with nearby professionals based on their location and preferences. It integrates Flutter (frontend), FastAPI (backend), MongoDB (database), and Random Forest Classifier (RFC) to deliver personalized and accurate professional suggestions in real-time.

🚀 Features:

-🔎 Proximity-based search using GPS
-🤖 Machine learning-powered recommendations (RFC)
-💬 In-app real-time chat and chatbot support
-🌐 Interactive UI with map and list views
-🔐 Secure login/authentication (Google & OTP)
-🌍 Multilingual & accessibility support
-⭐ Professional ratings and reviews
-📆 Predictive availability modeling
-📂 Professional profile management

🎯 Objectives:

-Help users find professionals quickly based on real-time location and availability.
-Integrate ML algorithms to personalize search and prediction of availability.
-Streamline user experience with communication, scheduling, and future payment integration.

🧠 Machine Learning Model:

Algorithm: Random Forest Classifier
Purpose: Predict and recommend the best professionals based on user behavior, preferences, and professional history.
Data Handling: Includes preprocessing, NLP-based feature extraction, model training, and feedback-based continuous learning.

🧱 Architecture

User Interface (Flutter)
     ↓
FastAPI Backend (Python)
     ↓
Machine Learning Module (RFC)
     ↓
MongoDB Database
     ↓
Google Maps API & Geo-location Services

🛠️ Tech Stack

-Layer	Technology
-Frontend	Flutter
-Backend	FastAPI (Python)
-Database	MongoDB
-ML Model	Random Forest (Scikit-learn)
-APIs	Google Maps API
-Tools	Git, VS Code

📸 Screenshots

Registration	Dashboard	Nearby Results

Professional Profile	Chat	Chatbot

🔮 Future Enhancements

✅ Advanced smart search & auto-booking system

🧠 Adaptive learning for better suggestions

💬 Community features with moderation

🤝 Integrated payment gateways

🧾 Smart contracts & document storage

📦 How to Run

Clone the repo

```
git clone https://github.com/your-username/PBPL.git
Install dependencies (backend)

```
```
cd backend/
pip install -r requirements.txt
Run the FastAPI server
```
```
uvicorn main:app --reload
Launch Flutter frontend

```
```
cd ../frontend/
flutter pub get
flutter run
```


⚖️ License
This project is under the MIT License – feel free to use, modify, and contribute!

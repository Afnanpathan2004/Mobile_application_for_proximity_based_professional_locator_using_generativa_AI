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

-APIs	google gemini

-Tools	Git, VS Code

📸 Screenshots

![WhatsApp Image 2025-05-27 at 21 31 13_47980fc9](https://github.com/user-attachments/assets/edbcfdff-4cb8-4fb1-bf62-39a1509f9c5d)

![WhatsApp Image 2025-05-27 at 21 29 24_8d1a34c3](https://github.com/user-attachments/assets/c24bcb05-0277-43e4-b406-b8f2d5d820f5)

![WhatsApp Image 2025-05-27 at 21 31 13_bcc0cd0f](https://github.com/user-attachments/assets/81e73f6f-9d8a-4225-b98c-ad1414b061a8)

![WhatsApp Image 2025-05-27 at 21 31 13_490f545b](https://github.com/user-attachments/assets/7392c6a5-d1b6-4568-8356-98fc45b5bffe)

![WhatsApp Image 2025-05-27 at 21 31 11_47407fa0](https://github.com/user-attachments/assets/e286306a-a94f-48ef-9a95-a6e00cc998b6)

![WhatsApp Image 2025-05-27 at 21 31 14_f4061080](https://github.com/user-attachments/assets/bbe5b192-79eb-43bf-a5f3-c0b1c885c71c)






🔮 Future Enhancements

✅ Advanced smart search & auto-booking system

🧠 Adaptive learning for better suggestions

💬 Community features with moderation

🤝 Integrated payment gateways

🧾 Smart contracts & document storage

📦 How to Run

```
Clone the repo
```
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

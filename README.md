**Mobile application for proximity based professional locator using generativa AI**

This is a mobile application built using Flutter and FastAPI that allows users to search and locate nearby professionals (like doctors, electricians, tutors, etc.) using real-time geolocation and filtering. The system provides a clean interface, real-time map-based discovery, and one-to-one communication between users and professionals.

### Key Features

Search Nearby Professionals: Based on  geolocation.

Dynamic Filtering: Search by category, distance, and availability.

User Authentication: Basic login system.

Professional Profiles: View details about listed professionals.

Real-Time Chat: One-to-one messaging between users and professionals.

### Technology Stack 

Frontend	Flutter

Backend	FastAPI (Python)

Api Google Gemeni

Database	MongoDB

Version Control  Git + GitHub

### Installation

1.Clone the Repository

```
git clone https://github.com/YourUsername/PBPL.git
cd PBPL
```

2.Install Backend Dependencies
```
cd backend
pip install -r requirements.txt
```

3.Run the Backend
```
uvicorn main:app --reload
```

4.Run the Frontend
```
cd ../frontend
flutter pub get
flutter run
```

### Screenshot

Login Page	Home Page	Search Results Map

Professional Profile	Chat Interface	Chatbot Assistant

(Make sure the /screenshots folder contains the correctly named image files.)

### License
This project is licensed under the MIT License.


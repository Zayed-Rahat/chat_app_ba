# Chat AB - Flutter Chat Application

Chat AB is a real-time chat application built with **Flutter** and **Firebase**. It allows users to register, login, add contacts, and chat in real-time with image and text messages. The app also keeps track of the user's online status and last active time. 

It uses a simple layered / feature-based structure with a service-style API layer (APIs class) — essentially an informal MVC/layered approach, not a strict Clean architecture.

---

## Details
  -  Presentation: screens/ and widgets/ contain UI and directly call APIs — Views + controller logic mixed in widgets/screens.
  - Data/Service: api/apis.dart acts as a singleton service (Firebase calls, messaging, etc.).
  - Models: models/ holds data models (ChatUser, Message).
  - Helpers: helpers/ contains utilities and UI dialogs.

## Features

- Firebase Authentication for secure login and registration
- Cloud Firestore for real-time chat and user data
- Firebase Cloud Messaging for push notifications
- Add users by email
- Real-time online/offline status and last active time
- Send text and image messages
- Edit and delete text
- Upload profile picture using Cloudinary
- Search users by name or email
- Delete messages or entire chat history


---

## Screenshots

<kbd>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/1.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/2.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/3.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/4.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/5.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/6.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/7.jpeg" width=30% height=40%/>
  <img src="https://github.com/Zayed-Rahat/chat_app_ba/blob/main/screenshots/8.jpeg" width=30% height=40%/>
</kbd>


---


### Clone the repository

```bash

git clone https://github.com/Zayed-Rahat/chat_app_ba.git
cd chat_app_ba

```
### Download exe file from

```bash

  https://github.com/Zayed-Rahat/chat_app_ba/installers

```

 ### Folder Structure


 ```bash
lib/
│
├── api/             # All API calls including Firebase integration
├── helpers/         # Utility functions and dialogs
├── models/          # Data models like ChatUser and Message
├── screens/         # All app screens (Home, Chat, Profile)
├── widgets/         # Reusable UI widgets
└── firebase_option.dart     
└── main.dart        # App entry point

```
 

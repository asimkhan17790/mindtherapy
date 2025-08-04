# MindTherapy 💖

A mental wellness mobile app built with Flutter & Node.js

## 🎯 Current Implementation Status

### ✅ **COMPLETED MVP FEATURES**
- **Daily Positive Affirmations**: Random motivational quotes with beautiful UI
- **Mood Check-in System**: Happy/Neutral/Sad selection with emoji interface  
- **Smart Task Suggestions**: Mood-based personalized recommendations
- **Full-Stack Integration**: Working API communication between Flutter frontend and Node.js backend
- **Cross-Platform Flutter App**: Responsive UI working on web (mobile-ready)

### 🏗️ **Technical Architecture (Fully Implemented)**
- **Backend**: Node.js + Express + In-memory data store (demo mode)
- **Frontend**: Flutter with Provider state management
- **API Endpoints**: 3 working REST endpoints with proper error handling
- **Project Structure**: Clean separation of concerns, modular codebase

### 📱 **UI Screens (All Working)**
1. **Splash Screen**: Daily affirmation display with fade animations
2. **Home Dashboard**: Main navigation with mood check-in card
3. **Mood Selection**: Interactive emoji-based mood picker
4. **Task Suggestions**: Personalized recommendations based on selected mood
5. **Settings**: Notification preferences and app configuration

### 🔌 **API Endpoints (Tested & Working)**
```
GET  /api/affirmations/random  → Fetch random motivational message
POST /api/mood                 → Save today's mood selection  
GET  /api/tasks/suggestions?mood=sad → Get mood-based task suggestions
```

## 🚀 **Quick Start & Demo**

### **Run Backend (Demo Mode)**
```bash
cd backend-nodejs
npm install
node src/server-demo.js  # Starts on localhost:3000 with sample data
```

### **Run Frontend**
```bash
cd frontend-flutter  
flutter pub get
flutter run -d chrome --web-port 8081  # Opens in browser
```

### **Test API Endpoints**
```bash
# Test affirmations
curl http://localhost:3000/api/affirmations/random

# Test mood saving
curl -X POST http://localhost:3000/api/mood -H "Content-Type: application/json" -d '{"mood":"happy","userId":"test123"}'

# Test task suggestions
curl "http://localhost:3000/api/tasks/suggestions?mood=sad"
```

## 📁 **Project Structure**
```
mindtherapy/
├── backend-nodejs/           # Node.js + Express API
│   ├── src/
│   │   ├── models/           # Data models (Mood, Affirmation, Task)
│   │   ├── routes/           # API endpoints
│   │   └── server-demo.js    # Demo server with sample data
│   └── package.json          # Dependencies
├── frontend-flutter/         # Flutter mobile app
│   ├── lib/
│   │   ├── models/           # Data models
│   │   ├── providers/        # State management
│   │   ├── screens/          # UI screens
│   │   ├── services/         # API & notifications
│   │   └── main.dart         # App entry point
│   └── pubspec.yaml          # Dependencies
└── PROJECT_PLAN.md           # Detailed development roadmap
```

## 🎯 **Next Development Steps**

### **Phase 1: Production Setup**
- [ ] Connect to MongoDB Atlas (replace in-memory store)
- [ ] Add user authentication & registration
- [ ] Deploy backend to cloud service (Railway/Render)
- [ ] Build Flutter mobile apps (iOS/Android)

### **Phase 2: Enhanced Features**
- [ ] Push notifications with Firebase Cloud Messaging
- [ ] Local notification scheduling for daily reminders
- [ ] Mood history tracking & analytics
- [ ] More personalized task suggestions

### **Phase 3: Advanced Features**
- [ ] Social features (share progress with loved ones)
- [ ] Custom affirmation creation
- [ ] Streak tracking & achievements
- [ ] Professional therapist integration

## 🧪 **Development Notes**

### **What's Working Right Now**
- Complete end-to-end data flow from Flutter UI → Node.js API → Response
- All 5 screens navigate properly with real data
- Mood selection saves to backend and influences task suggestions
- Error handling and loading states implemented
- Responsive design tested on web browser

### **Technical Decisions Made**
- **Flutter over React Native**: Better cross-platform consistency
- **Node.js over Spring Boot**: Faster MVP development, familiar to most developers
- **Provider over Bloc**: Simpler state management for current scope
- **In-memory data**: Allows demo without MongoDB setup complexity

### **Ready for Next Developer**
- Clean, well-documented codebase
- Working development environment setup
- All core MVP features functional
- Clear next steps outlined in PROJECT_PLAN.md

Built with ❤️ for mental wellness

---
*Last updated: MVP complete with working demo - ready for production setup*




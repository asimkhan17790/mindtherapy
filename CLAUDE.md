# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MindTherapy is a mental wellness mobile application with a Node.js backend API and Flutter frontend. The application provides daily affirmations, mood tracking, and personalized task suggestions to support mental health.

## Development Commands

### Backend (Node.js)
```bash
cd backend-nodejs
npm install                    # Install dependencies
npm run dev                   # Start development server with nodemon
npm start                     # Start production server
npm test                      # Run Jest tests
node src/server-demo.js       # Start demo server with in-memory data
```

### Flutter Frontend
```bash
cd frontend-flutter
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter run -d chrome --web-port 8081  # Run on web browser
flutter test                 # Run tests
flutter build apk           # Build Android APK
flutter build ios           # Build iOS app
```

### Testing API Endpoints
```bash
# Health check
curl http://localhost:3000/health

# Get random affirmation
curl http://localhost:3000/api/affirmations/random

# Save mood
curl -X POST http://localhost:3000/api/mood \
  -H "Content-Type: application/json" \
  -d '{"mood":"happy","userId":"test123"}'

# Get task suggestions
curl "http://localhost:3000/api/tasks/suggestions?mood=sad"
```

## Architecture

### Backend Structure (`backend-nodejs/`)
- **Entry Point**: `src/server.js` (production) / `src/server-demo.js` (demo)
- **Models**: `src/models/` - Mongoose schemas for Mood, Affirmation, Task
- **Routes**: `src/routes/` - Express route handlers for API endpoints
- **Database**: MongoDB with Mongoose ODM
- **Security**: Helmet, CORS, Morgan logging

### Frontend Structure (`frontend-flutter/`)
- **Entry Point**: `lib/main.dart` with Provider state management
- **Models**: `lib/models/` - Data classes for Mood, Affirmation, Task
- **Providers**: `lib/providers/` - State management with ChangeNotifier
- **Screens**: `lib/screens/` - UI screens (Splash, Home, Mood, Suggestions, Settings)
- **Services**: `lib/services/` - API service and notification service
- **Theme**: Material 3 with custom color scheme and Google Fonts

### API Endpoints
- `GET /health` - Health check
- `GET /api/affirmations/random` - Random daily affirmation
- `GET /api/affirmations` - All affirmations
- `POST /api/mood` - Save user mood entry
- `GET /api/mood/user/:userId` - User mood history
- `GET /api/mood/user/:userId/latest` - Latest mood entry
- `GET /api/tasks/suggestions?mood=<mood>` - Mood-based task suggestions
- `GET /api/tasks` - All available tasks

## Configuration

### Backend Environment Variables (`.env`)
```
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/mindtherapy
FIREBASE_PROJECT_ID=your-firebase-project-id
```

### API Base URL (Frontend)
- Development: `http://localhost:3000/api`
- Update `lib/services/api_service.dart` for different environments

## Development Workflow

### Demo Mode
The project includes a demo mode with in-memory data:
1. Run `node src/server-demo.js` for backend
2. Contains sample affirmations, tasks, and mood data
3. No database setup required

### Production Setup
1. Set up MongoDB Atlas cluster
2. Configure Firebase project for push notifications
3. Update environment variables
4. Run `npm run dev` for backend
5. Run `flutter run` for frontend

### Data Models
- **Mood**: `{ mood: 'happy'|'neutral'|'sad', userId: string, timestamp: ISO string }`
- **Affirmation**: `{ message: string, category: string }`
- **Task**: `{ title: string, description: string, moodTags: string[], category: string, estimatedMinutes: number }`

## State Management
Flutter frontend uses Provider pattern:
- `MoodProvider` - Handles mood selection and history
- `AffirmationProvider` - Manages daily affirmations
- `TaskProvider` - Handles task suggestions and completion

## Key Features Implemented
- Daily positive affirmations with random selection
- Mood check-in system with emoji interface
- Mood-based task suggestions
- Cross-platform Flutter UI with responsive design
- Full-stack integration between Flutter and Node.js
- Error handling and loading states

## Navigation Flow
1. **Splash Screen** → Daily affirmation display
2. **Home Screen** → Main dashboard with mood check-in
3. **Mood Screen** → Emoji-based mood selection
4. **Suggestions Screen** → Personalized task recommendations
5. **Settings Screen** → App preferences and configuration

## Testing
- Backend: Jest framework with Supertest for API testing
- Frontend: Flutter test framework for widget and unit tests
- Manual testing: Use demo mode for rapid development

## Next Development Steps
1. Connect to MongoDB Atlas (replace in-memory demo data)
2. Implement user authentication and registration
3. Add Firebase Cloud Messaging for push notifications
4. Deploy backend to cloud service (Railway/Render)
5. Build mobile apps for iOS/Android distribution
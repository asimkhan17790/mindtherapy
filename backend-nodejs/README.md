# MindTherapy Backend API (Node.js)

## Quick Start

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file with your configuration:
```
PORT=3000
MONGODB_URI=mongodb+srv://your-username:your-password@cluster.mongodb.net/mindtherapy
FIREBASE_PROJECT_ID=your-firebase-project-id
```

3. Start development server:
```bash
npm run dev
```

## API Endpoints

- `GET /api/affirmations/random` - Get random affirmation
- `POST /api/mood` - Save mood entry
- `GET /api/tasks/suggestions?mood=sad` - Get task suggestions
- `GET /health` - Health check

## Technologies Used

- Express.js - Web framework
- MongoDB + Mongoose - Database
- Firebase Admin SDK - Push notifications
- Helmet - Security middleware
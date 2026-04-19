# MindTherapy

A mental wellness app built with Flutter (frontend) and Node.js/Express (backend).

## Features

- Daily positive affirmations
- 10-state mood check-in with emoji interface
- Mood-based smart task suggestions
- Mood history, streaks, and trends
- Google OAuth authentication (JWT sessions)

## Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [MongoDB](https://www.mongodb.com/try/download/community) running locally on port 27017
- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Chrome target configured
- A Google Cloud project with OAuth 2.0 credentials (redirect URI: `http://localhost:8081`)

## Setup

### 1. Clone & install

```bash
git clone <repo-url>
cd mindtherapy
```

### 2. Backend

```bash
cd backend-nodejs
npm install
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/mindtherapy
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
JWT_SECRET=<generate: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))">
```

```bash
npm run seed      # seed initial affirmations + tasks
npm run dev       # start dev server on port 3001
```

Demo mode (no MongoDB or Google credentials needed):
```bash
node src/server-demo.js   # port 3000, in-memory sample data
```

### 3. Frontend

```bash
cd frontend-flutter
flutter pub get
flutter run -d chrome --web-port 8081
```

> **Important:** Port 8081 is required. Any other port causes `redirect_uri_mismatch` from Google OAuth.

## Project Structure

```
mindtherapy/
├── backend-nodejs/
│   └── src/
│       ├── models/           # Mongoose models (User, Mood, Task, Affirmation)
│       ├── routes/           # auth, moods, affirmations, tasks
│       ├── server.js         # Production server (port 3001, MongoDB)
│       └── server-demo.js    # In-memory demo server (port 3000)
└── frontend-flutter/
    └── lib/
        ├── models/
        ├── providers/        # AuthProvider, MoodProvider, AffirmationProvider, TaskProvider
        ├── screens/          # splash → login → home → mood → suggestions → trends → profile
        ├── services/         # api_service.dart (baseUrl: http://localhost:3001/api)
        └── main.dart
```

<!-- AUTO-GENERATED: scripts -->
## Backend Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with nodemon |
| `npm start` | Start production server |
| `npm test` | Run Jest test suite |
| `npm run seed` | Seed DB — skips if data already exists |
| `npm run seed:fresh` | Clear DB and reseed from scratch |
<!-- END AUTO-GENERATED: scripts -->

<!-- AUTO-GENERATED: env -->
## Environment Variables (`backend-nodejs/.env`)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `PORT` | No | Server port (default: 3001) | `3001` |
| `MONGODB_URI` | Yes | MongoDB connection string | `mongodb://localhost:27017/mindtherapy` |
| `GOOGLE_CLIENT_ID` | Yes | Google OAuth client ID | `xxx.apps.googleusercontent.com` |
| `JWT_SECRET` | Yes | 256-bit random secret for signing JWTs | `node -e "require('crypto')..."` |
| `ALLOWED_ORIGINS` | No | Comma-separated CORS origins (default: localhost:8081) | `https://app.example.com` |
| `FIREBASE_PROJECT_ID` | No | Firebase project for push notifications | `my-project` |
<!-- END AUTO-GENERATED: env -->

## API Reference

All authenticated endpoints require `Authorization: Bearer <jwt>`.

```
GET  /health
GET  /api/affirmations/random
POST /api/auth/google-signin         body: { idToken }
GET  /api/auth/profile               (auth)
PUT  /api/auth/preferences           (auth) body: { preferences }
POST /api/auth/signout               (auth)
POST /api/mood                       (auth) body: { moodType, intensity }
GET  /api/mood/history               (auth)
GET  /api/mood/latest                (auth)
GET  /api/mood/today                 (auth)
GET  /api/tasks/suggestions?mood=    (mood: amazing|happy|good|neutral|low|sad|anxious|angry|tired|stressed)
GET  /api/tasks/category/:category   (category: family|self-care|activity|creativity|social)
```

## Mood Types

`amazing` `happy` `good` `neutral` `low` `sad` `anxious` `angry` `tired` `stressed`

These must stay consistent across backend enums, frontend models, and the task suggestion query parameter.

## Security

- JWT signed with a 256-bit random secret (rotate via `JWT_SECRET` env var)
- CORS restricted to configured origins (default: `localhost:8081`)
- Rate limiting: 20 req/15 min on auth endpoints, 200 req/15 min on API
- Demo token bypass (`google-demo-token-*`) disabled in `NODE_ENV=production`
- Helmet security headers enabled

## Next Steps

- [ ] Firebase push notifications (`firebase-admin` + `node-cron` installed, not wired up)
- [ ] Jest/Supertest unit tests (deps installed, no tests written)
- [ ] Deploy backend (Railway / Render) — set `NODE_ENV=production` and `ALLOWED_ORIGINS`
- [ ] Build Flutter mobile apps (iOS/Android)

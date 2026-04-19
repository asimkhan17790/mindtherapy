# MindTherapy Backend API

Node.js + Express REST API for the MindTherapy wellness app.

## Prerequisites

- Node.js v18+
- MongoDB running locally on port 27017 (or a remote URI)
- Google Cloud OAuth 2.0 credentials

## Setup

```bash
npm install
cp .env.example .env   # then edit .env with your values
npm run seed           # seed initial affirmations + tasks
npm run dev            # nodemon on port 3001
```

Demo mode — no MongoDB or credentials required:
```bash
node src/server-demo.js   # port 3000, in-memory sample data
```

## Generating a JWT Secret

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Paste the output into `JWT_SECRET` in `.env`. Never commit this value.

<!-- AUTO-GENERATED: scripts -->
## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with nodemon |
| `npm start` | Start production server |
| `npm test` | Run Jest test suite |
| `npm run seed` | Seed DB — skips if data already exists |
| `npm run seed:fresh` | Clear DB and reseed from scratch |
<!-- END AUTO-GENERATED: scripts -->

<!-- AUTO-GENERATED: env -->
## Environment Variables

Copy `.env.example` to `.env` and fill in:

| Variable | Required | Description |
|----------|----------|-------------|
| `PORT` | No | Server port (default: 3001) |
| `MONGODB_URI` | Yes | MongoDB connection string |
| `GOOGLE_CLIENT_ID` | Yes | Google OAuth client ID |
| `JWT_SECRET` | Yes | 256-bit random secret — generate with `crypto.randomBytes(32)` |
| `ALLOWED_ORIGINS` | No | Comma-separated CORS origins (default: `http://localhost:8081`) |
| `NODE_ENV` | No | Set to `production` to disable demo token bypass |
| `FIREBASE_PROJECT_ID` | No | Firebase project (push notifications, optional) |
<!-- END AUTO-GENERATED: env -->

## API Endpoints

All authenticated endpoints require `Authorization: Bearer <jwt>`.

### Auth
- `POST /api/auth/google-signin` — Verify Google idToken, return JWT
- `GET  /api/auth/profile` — Get user profile (auth)
- `PUT  /api/auth/preferences` — Update preferences (auth)
- `POST /api/auth/signout` — Sign out (auth)
- `GET  /api/auth/verify` — Verify JWT validity (auth)

### Moods (all require auth)
- `POST /api/mood` — Save mood entry `{ moodType, intensity }`
- `GET  /api/mood/history` — Full mood history
- `GET  /api/mood/latest` — Most recent mood
- `GET  /api/mood/today` — Today's mood entry

### Affirmations
- `GET  /api/affirmations/random` — Random affirmation
- `GET  /api/affirmations` — All affirmations
- `POST /api/affirmations` — Create affirmation (auth)

### Tasks
- `GET  /api/tasks/suggestions?mood=<type>` — Mood-filtered suggestions
- `GET  /api/tasks/category/:category` — Category-filtered tasks
- `POST /api/tasks` — Create task (auth)

### Health
- `GET /health`

## Security

- CORS restricted to `ALLOWED_ORIGINS` (default: `localhost:8081`)
- Rate limiting: 20 req/15 min on `/api/auth`, 200 req/15 min elsewhere
- Demo token bypass disabled when `NODE_ENV=production`
- Helmet security headers on all responses
- `error.message` never returned in HTTP responses — logged server-side only

## Technologies

- Express.js — web framework
- MongoDB + Mongoose — database
- `google-auth-library` — Google OAuth verification
- `jsonwebtoken` — JWT auth
- `helmet` + `cors` + `express-rate-limit` — security
- `firebase-admin` + `node-cron` — push notifications (stub, not wired)
- Jest + Supertest — testing (no tests written yet)

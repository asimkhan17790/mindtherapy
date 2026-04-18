# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MindTherapy is a mental wellness app: Node.js/Express backend + Flutter frontend. Features daily affirmations, mood tracking, mood-based task suggestions, and Google OAuth authentication.

## Development Commands

### Backend (Node.js — port 3001)
```bash
cd backend-nodejs
npm run dev              # Start with nodemon (development)
npm start                # Start production server
npm run seed             # Seed DB (safe — skips if data exists)
npm run seed:fresh       # Clear and reseed
node src/server-demo.js  # In-memory demo mode (no MongoDB needed, runs on port 3000)
```

### Flutter Frontend
```bash
cd frontend-flutter
flutter pub get
flutter run -d chrome --web-port 8081   # MUST use 8081 — Google OAuth redirect_uri is locked to this port
flutter build web
flutter test
```

### Testing API Endpoints
```bash
curl http://localhost:3001/health
curl http://localhost:3001/api/affirmations/random
curl -X POST http://localhost:3001/api/mood \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <jwt>" \
  -d '{"moodType":"happy","intensity":3}'
curl "http://localhost:3001/api/tasks/suggestions?mood=sad"
```

## Architecture

### Backend (`backend-nodejs/src/`)
- **`server.js`** — Express app; mounts 4 route modules under `/api/auth`, `/api/affirmations`, `/api/mood`, `/api/tasks`; connects to MongoDB with local fallback
- **`server-demo.js`** — Standalone with in-memory sample data; no DB or auth required
- **`seed.js`** — Seeds 30 affirmations + 24 tasks covering all 10 mood types

**Routes:**
- `auth.js` — `POST /api/auth/google-signin` verifies Google idToken, creates/updates User, issues 7-day JWT; also profile CRUD and token verify endpoints
- `moods.js` — `POST /api/mood`, `GET /api/mood/history`, `GET /api/mood/latest`, `GET /api/mood/today`; all require JWT
- `affirmations.js` — `GET /api/affirmations/random` uses MongoDB `$sample`; standard CRUD
- `tasks.js` — `GET /api/tasks/suggestions?mood=<type>` filters by `moodTags`; `GET /api/tasks/category/:category`

**Models (Mongoose):**
- `User.js` — `googleId` + `email` unique/indexed; `preferences` sub-doc for notification settings
- `Mood.js` — Compound index `{ userId: 1, timestamp: -1 }`; `moodType` enum (10 values); `intensity` 1–5
- `Task.js` — `moodTags` enum matches `Mood.moodType`; `category` enum: family, self-care, activity, creativity, social
- `Affirmation.js` — `category` enum: motivation, self-love, strength, gratitude, mindfulness

### Frontend (`frontend-flutter/lib/`)
- **`main.dart`** — `MultiProvider` with 4 providers; `AuthWrapper` handles routing (splash/login/home); `ProtectedRoute` redirects unauthenticated users
- **`services/api_service.dart`** — All HTTP calls; `baseUrl = 'http://localhost:3001/api'`; change here to switch environments

**Providers (ChangeNotifier):**
- `auth_provider.dart` — Google sign-in, JWT stored in `SharedPreferences` (`access_token`, `user_data`, `login_timestamp`), 7-day session expiry check on app init
- `mood_provider.dart` — Mood submission + history; computed helpers: `hasTodaysMood`, `moodStreak`, `moodStats`
- `affirmation_provider.dart` — Random and all-affirmations loading
- `task_provider.dart` — Suggestions by mood; category filtering

**Screens:** splash → login → home → mood → suggestions → mood_trends → profile → settings

**Widget:** `widgets/quick_mood_capture.dart` — Reusable emoji mood picker used across screens

## Authentication Flow

1. Flutter calls `google_sign_in`; on web, `idToken` is often `null` — provider falls back to `google-demo-token-<googleId>`
2. Backend `auth.js` detects `google-demo-token-` prefix and bypasses Google API verification; finds/creates User; issues JWT
3. JWT attached as `Authorization: Bearer` on all authenticated requests; refreshed on app init via stored `SharedPreferences` values

## Mood Types (10 values — must stay consistent across backend and frontend)
`amazing, happy, good, neutral, low, sad, anxious, angry, tired, stressed`

These appear in: `Mood.moodType` enum, `Task.moodTags` enum, task suggestion query parameter, and Flutter `Mood` model emoji/color maps.

## Environment Variables (`backend-nodejs/.env`)
```
PORT=3001
MONGODB_URI=mongodb://localhost:27017/mindtherapy
GOOGLE_CLIENT_ID=<google-oauth-client-id>
JWT_SECRET=<secret>
FIREBASE_PROJECT_ID=<optional>
```

## Flutter Layout Convention
All screens: `Center > ConstrainedBox(maxWidth: 800) > SingleChildScrollView > Column`. Login screen uses `maxWidth: 480`. `ConstrainedBox` must wrap `SingleChildScrollView`, not the reverse.

## Known Gotchas
- **`MoodProvider` init**: Use `addPostFrameCallback` in `initState`, not `didChangeDependencies` — causes setState-during-build error
- **Web port**: Running Flutter on any port other than 8081 causes `redirect_uri_mismatch` from Google OAuth
- **`server-demo.js` port**: Uses port 3000, not 3001 — don't mix with production server
- **Firebase/notifications**: `firebase-admin` and `node-cron` are installed; `notification_service.dart` is a stub — not yet wired up

<!-- code-review-graph MCP tools -->
## MCP Tools: code-review-graph

**IMPORTANT: This project has a knowledge graph. ALWAYS use the
code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore
the codebase.** The graph is faster, cheaper (fewer tokens), and gives
you structural context (callers, dependents, test coverage) that file
scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files
- **Finding relationships**: `query_graph` with callers_of/callees_of/imports_of/tests_for
- **Architecture questions**: `get_architecture_overview` + `list_communities`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key Tools

| Tool | Use when |
|------|----------|
| `detect_changes` | Reviewing code changes � gives risk-scored analysis |
| `get_review_context` | Need source snippets for review � token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `get_architecture_overview` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow

1. The graph auto-updates on file changes (via hooks).
2. Use `detect_changes` for code review.
3. Use `get_affected_flows` to understand impact.
4. Use `query_graph` pattern="tests_for" to check coverage.

# Artemis — Personal OS Dashboard

The Artemis app is the unified integration layer for the Rummel Tech platform. It provides a single pane of glass across all personal management modules: fitness, nutrition, home, vehicles, work, education, investments, and content.

## What It Does

- **Unified dashboard** — widget grid aggregating live data from all connected modules
- **Cross-module AI agent** — one chat interface with tools scoped to every domain
- **Single sign-on** — one login (Google OAuth) grants access to all modules
- **Module health** — status board for all connected services

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x, Dart |
| State management | Provider |
| HTTP | Dio + http |
| Navigation | go_router |
| Charts | fl_chart |
| Backend | FastAPI (Python 3.11+) in `services/artemis/` |
| Auth | RS256 JWT from `services/auth/` |

## Quick Start

### Prerequisites

- Flutter 3.x
- The Artemis backend running at `http://localhost:8080`
- The auth service running at `http://localhost:8090`

### Run

```bash
# From this directory
flutter pub get
flutter run -d chrome
```

The app connects to `http://localhost:8080` by default (configured in `lib/config/env_config.dart`).

### Run with a custom backend URL

```bash
flutter run -d chrome \
  --dart-define=PLATFORM_BASE_URL=https://your-backend.com
```

## Project Structure

```
lib/
├── main.dart               # App entry point, Provider setup
├── config/
│   └── env_config.dart     # API URL configuration
├── models/                 # Data models
├── providers/
│   └── dashboard_provider.dart  # Dashboard state (ChangeNotifier)
├── screens/
│   └── dashboard_screen.dart    # Main dashboard UI
├── services/
│   └── api_service.dart    # HTTP client for Artemis backend
├── theme/                  # RummelTheme (light/dark)
└── widgets/                # Reusable UI components
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Deployment](docs/DEPLOYMENT.md)
- [Dev Reference](docs/artemis-dev-reference.md)
- [Artemis Module Contract](../../resources/ARTEMIS_MODULE_CONTRACT.md)

## Related

- **Backend**: `services/artemis/` (FastAPI)
- **Auth service**: `services/auth/` (RS256 JWT)
- **Platform docs**: `docs/ARCHITECTURE.md`

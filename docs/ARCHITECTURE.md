# Artemis App — Architecture

## Overview

The Artemis app is the frontend integration layer. It talks exclusively to the Artemis backend (`services/artemis/`, port 8080) which aggregates data from all module backends. The app never calls module backends directly.

```
artemis_app (Flutter)
        │
        ▼
services/artemis (FastAPI :8080)
        │
        ├──▶ services/auth (:8090)        — JWT verification, user info
        ├──▶ services/workout-planner (:8000)  — fitness widget data
        ├──▶ services/meal-planner (:8010)     — nutrition widget data
        ├──▶ services/home-manager (:8020)     — home tasks widget data
        ├──▶ services/vehicle-manager (:8030)  — vehicle widget data
        └──▶ services/work-planner (:8040)     — work tasks widget data
```

## State Management

**Provider** pattern with a single `DashboardProvider` (ChangeNotifier).

```
main.dart
  └── MultiProvider
        └── DashboardProvider(ApiService)
              ├── state: DashboardState (initial | loading | loaded | error)
              ├── summary: DashboardSummary?
              └── error: String?
```

State transitions:
```
initial → loading (on loadDashboard())
loading → loaded  (on success)
loading → error   (on failure)
loaded  → loading (on refresh())
```

## Data Flow

```
DashboardScreen
  └── Consumer<DashboardProvider>
        ├── initState() → provider.loadDashboard()
        └── RefreshIndicator → provider.refresh()

DashboardProvider.loadDashboard()
  └── ApiService.getDashboard()
        └── GET /dashboard  (Authorization: Bearer <jwt>)
              └── Artemis backend aggregates module widgets in parallel
```

## Key Files

| File | Role |
|------|------|
| `lib/main.dart` | App entry, Provider tree, theme setup |
| `lib/config/env_config.dart` | `EnvConfig.apiBaseUrl` — set via `--dart-define` |
| `lib/providers/dashboard_provider.dart` | All dashboard state; calls ApiService |
| `lib/services/api_service.dart` | HTTP client; all backend endpoints |
| `lib/screens/dashboard_screen.dart` | Main UI; responsive grid; pull-to-refresh |
| `lib/theme/` | `RummelTheme.lightTheme` / `darkTheme` |

## API Client (`ApiService`)

All requests go to `EnvConfig.apiBaseUrl` (default: `http://localhost:8080`).

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `getHealth()` | `GET /health` | Backend health check |
| `getModuleManifests()` | `GET /modules/manifests` | Module registry |
| `getModuleStatus()` | `GET /modules/status` | Module health |
| `getDashboard()` | `GET /dashboard` | Aggregated widget data |
| `getDailySchedule()` | `GET /dashboard/schedule` | Today's schedule |
| `getUpcomingActivities()` | `GET /dashboard/activities` | Upcoming events |
| `getNotifications()` | `GET /notifications` | Unified notifications |
| `executeModuleAction()` | `POST /modules/{id}/action` | Module action |

## Authentication

1. User signs in with Google → app receives Google ID token
2. App posts ID token to `auth` service → receives RS256 JWT
3. JWT stored in `shared_preferences`
4. All API calls include `Authorization: Bearer <jwt>` header
5. `ApiService` reads JWT from storage before each request

## Responsive Layout

`DashboardScreen` uses three breakpoints:

| Width | Layout |
|-------|--------|
| < 600px (mobile) | 2-column widget grid |
| 600–840px (tablet) | 3-column widget grid |
| > 840px (desktop) | 4-column widget grid |

## Error Handling

- Network errors → `DashboardState.error` with user-friendly message
- Individual widget failures → widget shows error card; dashboard continues
- Auth expiry → redirect to login
- Backend unavailable → cached data shown with staleness banner

## Dependencies

Key packages from `pubspec.yaml`:

| Package | Purpose |
|---------|---------|
| `provider ^6.1.0` | State management |
| `dio ^5.4.0` | HTTP client |
| `go_router ^13.0.0` | Navigation |
| `shared_preferences ^2.2.2` | Local storage (JWT) |
| `fl_chart ^0.66.0` | Charts for module data |
| `intl ^0.19.0` | Date/number formatting |

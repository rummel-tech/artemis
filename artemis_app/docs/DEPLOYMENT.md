# Artemis App — Deployment

## Deployment Targets

| Target | Method | URL |
|--------|--------|-----|
| Web (GitHub Pages) | GitHub Actions | `https://rummel-tech.github.io/artemis` |
| Android | Manual / Play Store | APK / AAB |
| iOS | Manual / App Store | IPA |

## Prerequisites

- Flutter 3.x installed
- GitHub repository: `rummel-tech/artemis` (or the configured remote)
- Backend services deployed and accessible (auth + artemis at minimum)

## Environment Variables

Set these as **GitHub Secrets** in the repo:

| Secret | Description |
|--------|-------------|
| `GOOGLE_CLIENT_ID` | Google OAuth 2.0 Web client ID |
| `AUTH_BASE_URL` | Auth service public URL (e.g. `http://<AUTH_IP>:8090`) |
| `PLATFORM_BASE_URL` | Artemis backend public URL (e.g. `http://<ARTEMIS_IP>:8080`) |

## Web Deployment (GitHub Pages)

The workflow at `.github/workflows/deploy-web.yml` (or via `infrastructure/.github/workflows/deploy-frontend.yml`) handles web builds.

**Manual build:**
```bash
cd artemis/artemis_app

flutter build web --release \
  --dart-define=PLATFORM_BASE_URL=https://your-backend.com \
  --dart-define=AUTH_BASE_URL=https://your-auth.com

# Output: build/web/
```

**GitHub Pages setup:**
1. Push to `rummel-tech/artemis` repository
2. GitHub Actions builds and deploys to `gh-pages` branch
3. Enable Pages: Settings → Pages → Deploy from `gh-pages`
4. Set GitHub Secrets: `GOOGLE_CLIENT_ID`, `AUTH_BASE_URL`, `PLATFORM_BASE_URL`

**Google OAuth setup** (required before deploying):
- Google Cloud Console → APIs & Services → Credentials
- Create OAuth 2.0 Web Application credential
- Authorized JavaScript origins:
  - `http://localhost` (development)
  - `https://rummel-tech.github.io` (production)
- Copy client ID into:
  - GitHub Secret: `GOOGLE_CLIENT_ID`
  - AWS Secrets Manager: `auth/google-client-id`

## Android Deployment

```bash
flutter build apk --release \
  --dart-define=PLATFORM_BASE_URL=https://your-backend.com

# Or AAB for Play Store:
flutter build appbundle --release \
  --dart-define=PLATFORM_BASE_URL=https://your-backend.com
```

## iOS Deployment

```bash
flutter build ios --release \
  --dart-define=PLATFORM_BASE_URL=https://your-backend.com

# Open in Xcode for signing and Archive
open ios/Runner.xcworkspace
```

## Backend Dependencies

The app requires these backends to be running and reachable:

| Service | Port | Required |
|---------|------|---------|
| auth | 8090 | Yes — login fails without it |
| artemis | 8080 | Yes — dashboard is empty without it |
| Module backends | 8000–8060 | No — dashboard degrades gracefully |

## Smoke Test Checklist

After deployment:
- [ ] App loads at GitHub Pages URL
- [ ] Google Sign-In completes successfully
- [ ] Dashboard loads (even if modules show errors)
- [ ] At least one module widget shows live data
- [ ] `/health` check passes: `curl https://your-backend.com/health`

## Configuration Reference

`lib/config/env_config.dart` reads `--dart-define` values at build time:

```dart
const apiBaseUrl = String.fromEnvironment(
  'PLATFORM_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

No runtime config files — all URLs are baked into the build.

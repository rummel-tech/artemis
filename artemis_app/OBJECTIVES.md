# Artemis App — Objectives

## Mission

Provide a unified personal OS dashboard that surfaces the right information from all life domains at the right moment, eliminating the need to switch between multiple apps.

## Primary Objectives

1. **Unified dashboard** — single screen showing live widget data from all active modules
2. **Cross-module AI** — one conversational agent with full access to all domain tools
3. **Seamless auth** — one sign-in (Google OAuth) that propagates RS256 tokens to all modules
4. **Graceful degradation** — dashboard remains functional when individual modules are unavailable

## Functional Requirements

### FR-1: Module Registry

- Display health status for all registered modules
- Enable/disable individual modules per user preference
- Show module metadata: name, version, port, last seen

### FR-2: Dashboard

- Widget grid with data from each active module
- Pull-to-refresh updates all widgets in parallel
- Responsive layout (mobile, tablet, desktop breakpoints)
- Error state per widget (failed module does not crash dashboard)

### FR-3: Authentication

- Google Sign-In → RS256 JWT from `services/auth`
- JWT stored securely (shared_preferences)
- Automatic token refresh before expiry
- Sign-out clears all local state

### FR-4: AI Agent

- Chat interface backed by `/agent/chat` REST endpoint
- Agent has tools for each active module (workouts, meals, tasks, etc.)
- Conversation history persisted locally
- Voice input (future)

### FR-5: Cross-Module Data

- Dashboard summary aggregates: today's workout, upcoming meals, open home tasks, vehicle service due
- Data fetched in parallel with independent error handling
- User consent required before cross-module data sharing

## Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Dashboard load time | < 2 seconds on 4G |
| Widget update time | < 500ms per widget |
| Module switch time | < 300ms |
| Uptime (depends on backend) | 99.9% |
| Offline mode | Shows cached data with staleness indicator |

## Integration Points

Each module exposes a contract (see `resources/ARTEMIS_MODULE_CONTRACT.md`) with:
- Health endpoint
- Manifest (widget definitions, agent tools, data schemas)
- Widget data endpoint
- Agent tool endpoints

## Development Phases

| Phase | Scope | Status |
|-------|-------|--------|
| 1 — Foundation | Dashboard shell, auth, module registry, API client | Complete |
| 2 — Widgets | Per-module widget data, live refresh, error states | In progress |
| 3 — AI Agent | Chat UI, agent tool integration, conversation history | Planned |
| 4 — Intelligence | Cross-module insights, automated workflows | Planned |

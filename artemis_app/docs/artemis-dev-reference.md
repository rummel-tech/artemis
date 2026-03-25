# Artemis Personal OS — Developer Reference

> **Version:** 0.3 — Alpha  
> **Stack:** Python 3.11+ · FastAPI · Pydantic v2 · PostgreSQL · Flutter 3.x  
> **Repo layout:** monorepo — `core/`, `modules/`, `api/`, `app/`

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Module Manifest System](#module-manifest-system)
3. [Discovery Service](#discovery-service)
4. [Activity Orchestrator](#activity-orchestrator)
5. [Notification Manager](#notification-manager)
6. [API Endpoints](#api-endpoints)
7. [Database Schema](#database-schema)
8. [Cross-Module Data Sharing](#cross-module-data-sharing)
9. [Flutter Integration](#flutter-integration)
10. [Adding a New Module](#adding-a-new-module)

---

## Architecture Overview

Artemis is a layered personal operating system. Each layer communicates only with the layer directly adjacent to it.

```
┌─────────────────────────────────────────────────────────┐
│  Flutter UI                                             │
│  Dashboard Builder · Calendar · Notifications · Widgets │
└────────────────────┬────────────────────────────────────┘
                     │  REST API / JSON
┌────────────────────▼────────────────────────────────────┐
│  FastAPI Layer                                          │
│  Module API · Activity API · Notification API · Auth    │
└────────────────────┬────────────────────────────────────┘
                     │  Service calls / Events
┌────────────────────▼────────────────────────────────────┐
│  Core Platform                                          │
│  Manifest System · Discovery · Orchestrator · Notifs    │
└────────────────────┬────────────────────────────────────┘
                     │  Manifest registration / Data sharing
┌────────────────────▼────────────────────────────────────┐
│  Modules                                                │
│  work · fitness · nutrition · finance · sleep · ...     │
└────────────────────┬────────────────────────────────────┘
                     │  ORM / SQL
┌────────────────────▼────────────────────────────────────┐
│  Data Layer — PostgreSQL                                │
│  module_registry · scheduled_activities · notifications │
└─────────────────────────────────────────────────────────┘
```

---

## Module Manifest System

Every module **must** implement `get_manifest() -> ModuleManifest`. This is how Artemis discovers what a module provides — data models, UI widgets, schedulable activities, notifications, and integration points.

### ModuleManifest structure

```python
from artemis.core.manifest import ModuleManifest

class ModuleManifest(BaseModel):
    # Identity
    name: str                              # unique snake_case identifier
    version: str                           # semver
    description: str
    icon: str                              # Material icon name
    color: str                             # hex, used for UI theming

    # Data
    entities: List[EntitySchema]           # data models this module owns

    # UI
    widgets: List[WidgetDefinition]        # Flutter widget descriptors
    dashboard_cards: List[DashboardCardDefinition]

    # Behaviour
    actions: List[ActionDefinition]
    quick_actions: List[QuickActionDefinition]
    schedulable_activities: List[ActivityDefinition]
    notification_types: List[NotificationDefinition]

    # Integration
    provides_data: List[DataProviderDefinition]
    consumes_data: List[DataConsumerDefinition]

    # Analytics
    metrics: List[MetricDefinition]

    # Capabilities
    has_settings: bool = False
    settings_schema: Optional[Dict[str, Any]] = None
    requires_modules: List[str] = []       # dependency declarations
    supports_export: bool = False
    supports_import: bool = False
```

### EntitySchema

```python
class EntitySchema(BaseModel):
    name: str                   # e.g. "Task", "WorkoutSession"
    fields: List[FieldDefinition]
    primary_key: str = "id"
    searchable_fields: List[str] = []
    sortable_fields: List[str] = []
```

### WidgetDefinition

```python
class WidgetDefinition(BaseModel):
    id: str                     # e.g. "task_summary_card"
    name: str
    description: str
    category: WidgetCategory    # dashboard | detail | list | chart | calendar
    template_type: str          # "summary_card" | "chart" | "list" | "custom"
    min_width: int = 1          # grid columns
    min_height: int = 1         # grid rows
    data_action: str            # action ID that provides widget data
    config_schema: Optional[Dict[str, Any]] = None
```

### ActivityDefinition

```python
class ActivityDefinition(BaseModel):
    id: str                     # e.g. "work_session"
    name: str
    description: str
    duration_minutes: int
    is_recurring: bool = False
    recurrence_pattern: Optional[str] = None   # cron expression
    reminder_minutes: List[int] = [15, 5]
    completion_action: Optional[str] = None    # action to call on complete
    feedback_type: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
```

### Example — Work Module manifest

```python
class WorkModule(BaseModule):
    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="work",
            version="1.0.0",
            description="Task and project management",
            icon="work",
            color="#4f8ef7",

            entities=[
                EntitySchema(
                    name="Task",
                    fields=[
                        FieldDefinition(name="title",    type="string",   required=True),
                        FieldDefinition(name="priority", type="enum",     default="medium"),
                        FieldDefinition(name="due_date", type="datetime", required=False),
                        FieldDefinition(name="status",   type="enum",     default="todo"),
                    ],
                    searchable_fields=["title"],
                    sortable_fields=["priority", "due_date"],
                )
            ],

            schedulable_activities=[
                ActivityDefinition(
                    id="work_session",
                    name="Work Session",
                    duration_minutes=90,
                    reminder_minutes=[15, 5],
                    feedback_type="work_session_feedback",
                )
            ],

            provides_data=[
                DataProviderDefinition(
                    id="calendar_availability",
                    name="Calendar Availability",
                    description="Work hours and blocked time",
                    schema={"type": "object"},
                    query_action="get_calendar_availability",
                )
            ],

            dashboard_cards=[
                DashboardCardDefinition(
                    id="task_overview",
                    name="Task Overview",
                    widget_id="task_summary_card",
                    default_position=CardPosition(row=0, column=0, width=2, height=1),
                )
            ],
        )
```

---

## Discovery Service

`artemis.core.discovery.DiscoveryService` is the central registry. All modules register here on startup.

```python
from artemis.core.discovery import discovery_service

# Register a module
discovery_service.register(module.get_manifest())

# Query the registry
all_manifests   = discovery_service.get_all_manifests()
widgets         = discovery_service.get_dashboard_widgets()
activities      = discovery_service.get_schedulable_activities()
providers       = discovery_service.get_data_providers(consumer_module="fitness")
module_manifest = discovery_service.get_manifest("work")
```

### Dependency resolution

If a module declares `requires_modules = ["work"]` and the Work module isn't registered yet, the Discovery Service queues it for deferred registration and emits a `MODULE_PENDING` status. Check status with:

```python
status = discovery_service.get_module_status("finance")
# returns: "active" | "pending" | "error"
```

---

## Activity Orchestrator

`artemis.core.orchestrator.ActivityOrchestrator` is the unified scheduler. Modules **never** schedule things directly — they call the orchestrator.

```python
from artemis.core.orchestrator import activity_orchestrator
from artemis.core.manifest import ScheduledActivity
from datetime import datetime

# Schedule an activity
activity = await activity_orchestrator.schedule(
    module_name="work",
    activity_type="work_session",
    title="Deep work — API layer",
    scheduled_time=datetime(2026, 3, 25, 9, 0),
    duration_minutes=90,
    data={"task_ids": ["abc123"]},
)

# Complete an activity
await activity_orchestrator.complete(activity.id, feedback={"rating": 4})

# Get today's schedule
schedule = await activity_orchestrator.get_daily_schedule(date=date.today())

# Get stats
stats = await activity_orchestrator.get_stats(module_name="fitness", days=30)
```

### Activity lifecycle

```
SCHEDULED → IN_PROGRESS → COMPLETED
                       ↘ MISSED → (reschedule offer)
         → CANCELLED
```

On completion, the orchestrator automatically triggers the `feedback_type` defined in the `ActivityDefinition` and updates module metrics.

---

## Notification Manager

`artemis.core.notifications.NotificationManager` handles all cross-module notifications. Modules emit events; the manager routes them.

```python
from artemis.core.notifications import notification_manager

# Emit a notification event
await notification_manager.emit(
    module_name="fitness",
    notification_type="workout_reminder",
    title="Workout in 15 minutes",
    message="Upper body session scheduled for 10:00",
    priority="high",
    actions=[
        {"id": "start", "label": "Start Early"},
        {"id": "snooze", "label": "Snooze 10 min"},
    ],
    related_activity_id=activity.id,
)
```

### Delivery channels

| Channel   | Config key              | Backend          |
|-----------|------------------------|------------------|
| `push`    | `notifications.push`   | FCM / APNs       |
| `in_app`  | `notifications.in_app` | WebSocket / poll |
| `email`   | `notifications.email`  | SMTP queue       |

Channel selection is driven by user preferences stored in `notification_preferences`. Modules do not choose the channel — users do.

---

## API Endpoints

All routes are prefixed `/api/v1`.

### Module Discovery

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/modules/manifests` | All registered module manifests |
| `GET` | `/modules/{name}/manifest` | Single module manifest |
| `GET` | `/modules/{name}/status` | Registration status |
| `GET` | `/widgets/dashboard` | All available dashboard widgets |

### Dashboard

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/dashboard` | User's current dashboard config |
| `POST` | `/dashboard/cards` | Add a widget card |
| `PUT` | `/dashboard/layout` | Update card positions |
| `DELETE` | `/dashboard/cards/{id}` | Remove a card |

### Activities

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/activities/schedule` | Schedule a new activity |
| `GET` | `/activities/daily` | Today's activity schedule |
| `GET` | `/activities/upcoming` | Next 7 days |
| `PUT` | `/activities/{id}` | Update activity |
| `POST` | `/activities/{id}/complete` | Mark complete + submit feedback |
| `POST` | `/activities/{id}/cancel` | Cancel activity |

### Notifications

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/notifications` | Unread notifications |
| `POST` | `/notifications/{id}/read` | Mark as read |
| `POST` | `/notifications/{id}/action` | Execute notification action |
| `GET` | `/notifications/preferences` | User delivery preferences |
| `PUT` | `/notifications/preferences` | Update preferences |

### Calendar

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/calendar/events` | All scheduled activities as calendar events |
| `GET` | `/calendar/availability` | Free time slots |
| `POST` | `/calendar/sync` | Trigger external calendar sync |

### Feedback

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/feedback` | Submit activity feedback |
| `GET` | `/feedback/insights/{module}` | Module-level insight aggregates |
| `GET` | `/feedback/suggestions` | AI-generated scheduling suggestions |

---

## Database Schema

```sql
-- Module registry
CREATE TABLE module_registry (
    name        VARCHAR(50) PRIMARY KEY,
    version     VARCHAR(20) NOT NULL,
    enabled     BOOLEAN DEFAULT true,
    manifest    JSONB NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Scheduled activities
CREATE TABLE scheduled_activities (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_name      VARCHAR(50) REFERENCES module_registry(name),
    activity_type    VARCHAR(50) NOT NULL,
    title            VARCHAR(255) NOT NULL,
    scheduled_time   TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER NOT NULL,
    status           VARCHAR(20) DEFAULT 'scheduled',
    data             JSONB DEFAULT '{}',
    created_at       TIMESTAMPTZ DEFAULT now(),
    updated_at       TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_activities_time   ON scheduled_activities(scheduled_time);
CREATE INDEX idx_activities_status ON scheduled_activities(status);
CREATE INDEX idx_activities_module ON scheduled_activities(module_name);

-- Notifications
CREATE TABLE notifications (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_name         VARCHAR(50) REFERENCES module_registry(name),
    notification_type   VARCHAR(50) NOT NULL,
    title               VARCHAR(255) NOT NULL,
    message             TEXT,
    priority            VARCHAR(20) DEFAULT 'normal',
    read                BOOLEAN DEFAULT false,
    actions             JSONB DEFAULT '[]',
    related_activity_id UUID REFERENCES scheduled_activities(id),
    created_at          TIMESTAMPTZ DEFAULT now()
);

-- Dashboard configuration
CREATE TABLE user_dashboards (
    user_id     UUID NOT NULL,
    card_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    module_name VARCHAR(50) NOT NULL,
    widget_id   VARCHAR(50) NOT NULL,
    position    JSONB NOT NULL,   -- {row, column, width, height}
    config      JSONB DEFAULT '{}',
    PRIMARY KEY (user_id, card_id)
);

-- Feedback
CREATE TABLE feedback (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_name VARCHAR(50) NOT NULL,
    activity_id UUID REFERENCES scheduled_activities(id),
    type        VARCHAR(50) NOT NULL,
    rating      SMALLINT CHECK (rating BETWEEN 1 AND 5),
    notes       TEXT,
    data        JSONB DEFAULT '{}',
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- Cross-module data sharing
CREATE TABLE cross_module_shares (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider    VARCHAR(50) NOT NULL,
    consumer    VARCHAR(50) NOT NULL,
    provider_id VARCHAR(50) NOT NULL,   -- DataProviderDefinition.id
    permission  VARCHAR(20) DEFAULT 'read',
    granted_at  TIMESTAMPTZ DEFAULT now(),
    expires_at  TIMESTAMPTZ,
    UNIQUE (provider, consumer, provider_id)
);
```

---

## Cross-Module Data Sharing

Modules declare what they share via `provides_data` and what they need via `consumes_data` in their manifests. All sharing is permissioned — the user must grant access.

```python
# Provider module declares:
DataProviderDefinition(
    id="calories_burned",
    name="Calories Burned",
    schema={"date": "date", "calories": "number", "activity_type": "string"},
    query_action="get_daily_calories",
)

# Consumer module declares:
DataConsumerDefinition(
    id="fitness_calories",
    provider_module="fitness",
    provider_id="calories_burned",
    required=False,
    use_case="Adjust daily calorie targets based on exercise",
)

# At runtime, consumer fetches shared data:
data = await discovery_service.fetch_shared_data(
    provider="fitness",
    provider_id="calories_burned",
    consumer="nutrition",
    params={"date": "2026-03-24"},
)
```

Permission records are stored in `cross_module_shares`. The core platform enforces access — modules cannot read each other's data directly.

---

## Flutter Integration

### Dynamic Widget Loading

```dart
class DynamicWidgetLoader {
  Widget build(WidgetDefinition def, Map<String, dynamic> data) {
    return switch (def.templateType) {
      'summary_card' => SummaryCardWidget(definition: def, data: data),
      'chart'        => ChartWidget(definition: def, data: data),
      'list'         => ListWidget(definition: def, data: data),
      'custom'       => ModuleWidgetRegistry.get(def.id, data),
      _              => const UnknownWidget(),
    };
  }
}
```

### Dashboard Grid

The Flutter dashboard fetches the user's saved layout from `GET /api/v1/dashboard`, then for each card calls the widget's `data_action` endpoint to hydrate it with live data. Cards are rendered in a `SliverGrid` using the position config (`row`, `column`, `width`, `height`).

### Activity Calendar

The `ActivityCalendar` widget calls `GET /api/v1/calendar/events` and renders a unified view of activities from all active modules. Each event is colored using its source module's `color` field from the manifest.

---

## Adding a New Module

1. **Create the module directory** under `modules/your_module/`
2. **Extend `BaseModule`** and implement `get_manifest()`
3. **Define your entities** — Pydantic models + SQLAlchemy ORM models
4. **Implement your actions** — async methods decorated with `@action`
5. **Register on startup** — call `discovery_service.register(manifest)` in your module's `startup()` hook
6. **Declare integrations** — add `provides_data` / `consumes_data` to the manifest if sharing data
7. **Write tests** — unit test the manifest, integration test the API endpoints

```python
# modules/sleep/module.py
from artemis.core.base import BaseModule
from artemis.core.manifest import ModuleManifest

class SleepModule(BaseModule):
    name = "sleep"

    async def startup(self):
        from artemis.core.discovery import discovery_service
        discovery_service.register(self.get_manifest())

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="sleep",
            version="0.1.0",
            description="Sleep schedule and quality tracking",
            icon="bedtime",
            color="#818cf8",
            # ... entities, activities, widgets, etc.
        )
```

---

*This document lives at `docs/ARCHITECTURE.md` in the Artemis monorepo.*  
*For product roadmap and sprint tracking, see the separate product management documents.*

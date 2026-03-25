import uuid
from datetime import date, datetime
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from ..core.discovery import discovery_service
from ..core.orchestrator import activity_orchestrator
from ..core.notifications import notification_manager
from ..modules import (
    AssetsModule,
    EntrepreneurshipModule,
    FinanceModule,
    FitnessModule,
    NutritionModule,
    WorkModule,
)


def _register_modules() -> None:
    for module in [
        WorkModule(),
        FitnessModule(),
        NutritionModule(),
        EntrepreneurshipModule(),
        FinanceModule(),
        AssetsModule(),
    ]:
        discovery_service.register(module.get_manifest())


_module_instances: dict[str, Any] = {}


def _build_module_instances() -> None:
    modules = [WorkModule(), FitnessModule(), NutritionModule(),
               EntrepreneurshipModule(), FinanceModule(), AssetsModule()]
    for m in modules:
        _module_instances[m.name] = m


_in_memory_dashboard: list[dict[str, Any]] = []


def create_app() -> FastAPI:
    app = FastAPI(
        title="Artemis Personal OS",
        description="Backend API for Artemis Personal OS — single pane of glass for all life domains.",
        version="0.3.0",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    _register_modules()
    _build_module_instances()

    # --- Request models ---

    class ActionRequest(BaseModel):
        action: str
        data: dict[str, Any] = {}

    class ScheduleActivityRequest(BaseModel):
        module_name: str
        activity_type: str
        title: str
        scheduled_time: str
        duration_minutes: int
        data: dict[str, Any] = {}

    class UpdateActivityRequest(BaseModel):
        title: str | None = None
        scheduled_time: str | None = None
        duration_minutes: int | None = None
        status: str | None = None

    class CompleteActivityRequest(BaseModel):
        feedback: dict[str, Any] = {}

    class AddDashboardCardRequest(BaseModel):
        module_name: str
        widget_id: str
        position: dict[str, Any]
        config: dict[str, Any] = {}

    class UpdateLayoutRequest(BaseModel):
        cards: list[dict[str, Any]]

    class FeedbackRequest(BaseModel):
        module_name: str
        activity_id: str | None = None
        type: str
        rating: int | None = None
        notes: str | None = None
        data: dict[str, Any] = {}

    class NotificationActionRequest(BaseModel):
        action_id: str

    class UpdatePreferencesRequest(BaseModel):
        preferences: dict[str, Any]

    # --- Health ---

    @app.get("/health", tags=["system"])
    async def health() -> dict[str, str]:
        return {"status": "ok", "service": "artemis"}

    # --- Module Discovery ---

    @app.get("/api/v1/modules/manifests", tags=["modules"])
    async def get_all_manifests() -> list[dict[str, Any]]:
        return [m.model_dump() for m in discovery_service.get_all_manifests()]

    @app.get("/api/v1/modules/{name}/manifest", tags=["modules"])
    async def get_module_manifest(name: str) -> dict[str, Any]:
        manifest = discovery_service.get_manifest(name)
        if not manifest:
            raise HTTPException(status_code=404, detail=f"Module '{name}' not found")
        return manifest.model_dump()

    @app.get("/api/v1/modules/{name}/status", tags=["modules"])
    async def get_module_status(name: str) -> dict[str, str]:
        status = discovery_service.get_module_status(name)
        if status == "error":
            raise HTTPException(status_code=404, detail=f"Module '{name}' not found")
        return {"name": name, "status": status}

    @app.get("/api/v1/widgets/dashboard", tags=["modules"])
    async def get_dashboard_widgets() -> list[dict[str, Any]]:
        return [w.model_dump() for w in discovery_service.get_dashboard_widgets()]

    @app.post("/api/v1/modules/{name}/action", tags=["modules"])
    async def execute_module_action(name: str, request: ActionRequest) -> dict[str, Any]:
        module = _module_instances.get(name)
        if not module:
            raise HTTPException(status_code=404, detail=f"Module '{name}' not found")
        return module.execute_action(request.action, request.data)

    # --- Dashboard ---

    @app.get("/api/v1/dashboard", tags=["dashboard"])
    async def get_dashboard() -> dict[str, Any]:
        if not _in_memory_dashboard:
            manifests = discovery_service.get_all_manifests()
            cards = []
            for manifest in manifests:
                for card_def in manifest.dashboard_cards:
                    cards.append({
                        "id": str(uuid.uuid4()),
                        "module_name": manifest.name,
                        "widget_id": card_def.widget_id,
                        "name": card_def.name,
                        "position": card_def.default_position.model_dump(),
                        "config": {},
                    })
            _in_memory_dashboard.extend(cards)
        return {"cards": _in_memory_dashboard}

    @app.post("/api/v1/dashboard/cards", tags=["dashboard"])
    async def add_dashboard_card(request: AddDashboardCardRequest) -> dict[str, Any]:
        card = {
            "id": str(uuid.uuid4()),
            "module_name": request.module_name,
            "widget_id": request.widget_id,
            "position": request.position,
            "config": request.config,
        }
        _in_memory_dashboard.append(card)
        return card

    @app.put("/api/v1/dashboard/layout", tags=["dashboard"])
    async def update_dashboard_layout(request: UpdateLayoutRequest) -> dict[str, Any]:
        for updated_card in request.cards:
            for i, card in enumerate(_in_memory_dashboard):
                if card["id"] == updated_card.get("id"):
                    _in_memory_dashboard[i] = {**card, **updated_card}
        return {"cards": _in_memory_dashboard}

    @app.delete("/api/v1/dashboard/cards/{card_id}", tags=["dashboard"])
    async def delete_dashboard_card(card_id: str) -> dict[str, Any]:
        original_len = len(_in_memory_dashboard)
        _in_memory_dashboard[:] = [c for c in _in_memory_dashboard if c["id"] != card_id]
        if len(_in_memory_dashboard) == original_len:
            raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
        return {"deleted": card_id}

    # --- Activities ---

    @app.post("/api/v1/activities/schedule", tags=["activities"])
    async def schedule_activity(request: ScheduleActivityRequest) -> dict[str, Any]:
        scheduled_time = datetime.fromisoformat(request.scheduled_time)
        activity = await activity_orchestrator.schedule(
            module_name=request.module_name,
            activity_type=request.activity_type,
            title=request.title,
            scheduled_time=scheduled_time,
            duration_minutes=request.duration_minutes,
            data=request.data,
        )
        return activity.model_dump()

    @app.get("/api/v1/activities/daily", tags=["activities"])
    async def get_daily_schedule(target_date: str | None = None) -> list[dict[str, Any]]:
        parsed_date = date.fromisoformat(target_date) if target_date else date.today()
        activities = await activity_orchestrator.get_daily_schedule(parsed_date)
        return [a.model_dump() for a in activities]

    @app.get("/api/v1/activities/upcoming", tags=["activities"])
    async def get_upcoming_activities() -> list[dict[str, Any]]:
        activities = await activity_orchestrator.get_upcoming()
        return [a.model_dump() for a in activities]

    @app.put("/api/v1/activities/{activity_id}", tags=["activities"])
    async def update_activity(activity_id: str, request: UpdateActivityRequest) -> dict[str, Any]:
        fields = {k: v for k, v in request.model_dump().items() if v is not None}
        activity = await activity_orchestrator.update(activity_id, fields)
        if not activity:
            raise HTTPException(status_code=404, detail=f"Activity '{activity_id}' not found")
        return activity.model_dump()

    @app.post("/api/v1/activities/{activity_id}/complete", tags=["activities"])
    async def complete_activity(activity_id: str, request: CompleteActivityRequest) -> dict[str, Any]:
        activity = await activity_orchestrator.complete(activity_id, feedback=request.feedback)
        if not activity:
            raise HTTPException(status_code=404, detail=f"Activity '{activity_id}' not found")
        return activity.model_dump()

    @app.post("/api/v1/activities/{activity_id}/cancel", tags=["activities"])
    async def cancel_activity(activity_id: str) -> dict[str, Any]:
        activity = await activity_orchestrator.cancel(activity_id)
        if not activity:
            raise HTTPException(status_code=404, detail=f"Activity '{activity_id}' not found")
        return activity.model_dump()

    # --- Notifications ---

    @app.get("/api/v1/notifications", tags=["notifications"])
    async def get_notifications() -> list[dict[str, Any]]:
        notifications = await notification_manager.get_unread()
        return [n.model_dump() for n in notifications]

    @app.post("/api/v1/notifications/{notification_id}/read", tags=["notifications"])
    async def mark_notification_read(notification_id: str) -> dict[str, Any]:
        notification = await notification_manager.mark_read(notification_id)
        if not notification:
            raise HTTPException(status_code=404, detail=f"Notification '{notification_id}' not found")
        return notification.model_dump()

    @app.post("/api/v1/notifications/{notification_id}/action", tags=["notifications"])
    async def execute_notification_action(notification_id: str, request: NotificationActionRequest) -> dict[str, Any]:
        return await notification_manager.execute_action(notification_id, request.action_id)

    @app.get("/api/v1/notifications/preferences", tags=["notifications"])
    async def get_notification_preferences() -> dict[str, Any]:
        return notification_manager.get_preferences()

    @app.put("/api/v1/notifications/preferences", tags=["notifications"])
    async def update_notification_preferences(request: UpdatePreferencesRequest) -> dict[str, Any]:
        return notification_manager.update_preferences(request.preferences)

    # --- Calendar ---

    @app.get("/api/v1/calendar/events", tags=["calendar"])
    async def get_calendar_events() -> list[dict[str, Any]]:
        activities = await activity_orchestrator.get_upcoming(days=30)
        manifests = {m.name: m for m in discovery_service.get_all_manifests()}
        events = []
        for activity in activities:
            manifest = manifests.get(activity.module_name)
            events.append({
                "id": activity.id,
                "title": activity.title,
                "start": activity.scheduled_time,
                "duration_minutes": activity.duration_minutes,
                "module_name": activity.module_name,
                "color": manifest.color if manifest else "#888888",
                "status": activity.status,
            })
        return events

    @app.get("/api/v1/calendar/availability", tags=["calendar"])
    async def get_calendar_availability() -> dict[str, Any]:
        return {"slots": [], "timezone": "UTC"}

    # --- Feedback ---

    _feedback_store: list[dict[str, Any]] = []

    @app.post("/api/v1/feedback", tags=["feedback"])
    async def submit_feedback(request: FeedbackRequest) -> dict[str, Any]:
        entry = {
            "id": str(uuid.uuid4()),
            **request.model_dump(),
        }
        _feedback_store.append(entry)
        return entry

    @app.get("/api/v1/feedback/insights/{module}", tags=["feedback"])
    async def get_feedback_insights(module: str) -> dict[str, Any]:
        entries = [f for f in _feedback_store if f.get("module_name") == module]
        ratings = [f["rating"] for f in entries if f.get("rating") is not None]
        return {
            "module": module,
            "total_feedback": len(entries),
            "average_rating": round(sum(ratings) / len(ratings), 2) if ratings else None,
        }

    return app

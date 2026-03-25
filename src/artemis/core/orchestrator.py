import uuid
from datetime import date, datetime
from typing import Any

from .manifest import ScheduledActivity


class ActivityOrchestrator:
    def __init__(self) -> None:
        self._activities: dict[str, ScheduledActivity] = {}

    async def schedule(
        self,
        module_name: str,
        activity_type: str,
        title: str,
        scheduled_time: datetime,
        duration_minutes: int,
        data: dict[str, Any] | None = None,
    ) -> ScheduledActivity:
        activity = ScheduledActivity(
            id=str(uuid.uuid4()),
            module_name=module_name,
            activity_type=activity_type,
            title=title,
            scheduled_time=scheduled_time.isoformat(),
            duration_minutes=duration_minutes,
            status="scheduled",
            data=data or {},
        )
        self._activities[activity.id] = activity
        return activity

    async def complete(self, activity_id: str, feedback: dict[str, Any] | None = None) -> ScheduledActivity | None:
        activity = self._activities.get(activity_id)
        if not activity:
            return None
        updated = activity.model_copy(update={"status": "completed"})
        self._activities[activity_id] = updated
        return updated

    async def cancel(self, activity_id: str) -> ScheduledActivity | None:
        activity = self._activities.get(activity_id)
        if not activity:
            return None
        updated = activity.model_copy(update={"status": "cancelled"})
        self._activities[activity_id] = updated
        return updated

    async def update(self, activity_id: str, fields: dict[str, Any]) -> ScheduledActivity | None:
        activity = self._activities.get(activity_id)
        if not activity:
            return None
        updated = activity.model_copy(update=fields)
        self._activities[activity_id] = updated
        return updated

    async def get_daily_schedule(self, target_date: date | None = None) -> list[ScheduledActivity]:
        target = target_date or date.today()
        return [
            a for a in self._activities.values()
            if a.scheduled_time.startswith(target.isoformat())
        ]

    async def get_upcoming(self, days: int = 7) -> list[ScheduledActivity]:
        now = datetime.now().isoformat()
        return [
            a for a in self._activities.values()
            if a.scheduled_time >= now and a.status == "scheduled"
        ]

    async def get_stats(self, module_name: str | None = None, days: int = 30) -> dict[str, Any]:
        activities = list(self._activities.values())
        if module_name:
            activities = [a for a in activities if a.module_name == module_name]
        return {
            "total": len(activities),
            "completed": sum(1 for a in activities if a.status == "completed"),
            "cancelled": sum(1 for a in activities if a.status == "cancelled"),
            "scheduled": sum(1 for a in activities if a.status == "scheduled"),
        }


activity_orchestrator = ActivityOrchestrator()

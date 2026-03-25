import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel


class Notification(BaseModel):
    id: str
    module_name: str
    notification_type: str
    title: str
    message: str | None = None
    priority: str = "normal"
    read: bool = False
    actions: list[dict[str, Any]] = []
    related_activity_id: str | None = None
    created_at: str


class NotificationManager:
    def __init__(self) -> None:
        self._notifications: dict[str, Notification] = {}
        self._preferences: dict[str, Any] = {
            "push": True,
            "in_app": True,
            "email": False,
        }

    async def emit(
        self,
        module_name: str,
        notification_type: str,
        title: str,
        message: str | None = None,
        priority: str = "normal",
        actions: list[dict[str, Any]] | None = None,
        related_activity_id: str | None = None,
    ) -> Notification:
        notification = Notification(
            id=str(uuid.uuid4()),
            module_name=module_name,
            notification_type=notification_type,
            title=title,
            message=message,
            priority=priority,
            actions=actions or [],
            related_activity_id=related_activity_id,
            created_at=datetime.now().isoformat(),
        )
        self._notifications[notification.id] = notification
        return notification

    async def get_unread(self) -> list[Notification]:
        return [n for n in self._notifications.values() if not n.read]

    async def mark_read(self, notification_id: str) -> Notification | None:
        notification = self._notifications.get(notification_id)
        if not notification:
            return None
        updated = notification.model_copy(update={"read": True})
        self._notifications[notification_id] = updated
        return updated

    async def execute_action(self, notification_id: str, action_id: str) -> dict[str, Any]:
        notification = self._notifications.get(notification_id)
        if not notification:
            return {"error": "Notification not found"}
        action = next((a for a in notification.actions if a.get("id") == action_id), None)
        if not action:
            return {"error": "Action not found"}
        return {"success": True, "action": action}

    def get_preferences(self) -> dict[str, Any]:
        return self._preferences

    def update_preferences(self, prefs: dict[str, Any]) -> dict[str, Any]:
        self._preferences.update(prefs)
        return self._preferences


notification_manager = NotificationManager()

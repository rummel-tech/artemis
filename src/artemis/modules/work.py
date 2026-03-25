from typing import Any

from ..core.base_module import BaseModule
from ..core.manifest import (
    ActivityDefinition,
    CardPosition,
    DashboardCardDefinition,
    DataProviderDefinition,
    EntitySchema,
    FieldDefinition,
    ModuleManifest,
    QuickActionDefinition,
    WidgetCategory,
    WidgetDefinition,
)


class WorkModule(BaseModule):
    name = "work"

    def __init__(self) -> None:
        self._tasks: list[dict[str, Any]] = []
        self._projects: list[dict[str, Any]] = []

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
                        FieldDefinition(name="title", type="string", required=True),
                        FieldDefinition(name="priority", type="enum", default="medium"),
                        FieldDefinition(name="due_date", type="datetime", required=False),
                        FieldDefinition(name="status", type="enum", default="todo"),
                    ],
                    searchable_fields=["title"],
                    sortable_fields=["priority", "due_date"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="task_summary_card",
                    name="Task Summary",
                    description="Overview of open tasks and projects",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_task_summary",
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
            quick_actions=[
                QuickActionDefinition(id="create_task", label="Add Task", action="create_task", icon="add_task"),
                QuickActionDefinition(id="create_project", label="New Project", action="create_project", icon="folder"),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="work_session",
                    name="Work Session",
                    description="Focused work block",
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
                    data_schema={"type": "object"},
                    query_action="get_calendar_availability",
                )
            ],
        )

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "create_task":
            task = {"id": len(self._tasks) + 1, "completed_today": False, **data}
            self._tasks.append(task)
            return {"success": True, "task": task}
        if action == "create_project":
            project = {"id": len(self._projects) + 1, **data}
            self._projects.append(project)
            return {"success": True, "project": project}
        if action == "list_tasks":
            return {"tasks": self._tasks}
        if action == "list_projects":
            return {"projects": self._projects}
        if action == "get_task_summary":
            return {
                "task_count": len(self._tasks),
                "project_count": len(self._projects),
                "completed_today": sum(1 for t in self._tasks if t.get("completed_today", False)),
            }
        return {"error": f"Unknown action: {action}"}

from typing import Any

from ..core.base_module import BaseModule
from ..core.manifest import (
    ActivityDefinition,
    CardPosition,
    DashboardCardDefinition,
    EntitySchema,
    FieldDefinition,
    ModuleManifest,
    QuickActionDefinition,
    WidgetCategory,
    WidgetDefinition,
)


class EntrepreneurshipModule(BaseModule):
    name = "entrepreneurship"

    def __init__(self) -> None:
        self._ventures: list[dict[str, Any]] = []
        self._ideas: list[dict[str, Any]] = []
        self._milestones: list[dict[str, Any]] = []

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="entrepreneurship",
            version="1.0.0",
            description="Business ventures, ideas, and milestone tracking",
            icon="lightbulb",
            color="#9c27b0",
            entities=[
                EntitySchema(
                    name="Venture",
                    fields=[
                        FieldDefinition(name="name", type="string", required=True),
                        FieldDefinition(name="stage", type="enum", default="idea"),
                        FieldDefinition(name="description", type="string", required=False),
                    ],
                    searchable_fields=["name", "description"],
                    sortable_fields=["stage"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="entrepreneurship_summary_card",
                    name="Ventures Summary",
                    description="Active ventures, ideas, and milestones",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_ventures_summary",
                )
            ],
            dashboard_cards=[
                DashboardCardDefinition(
                    id="ventures_overview",
                    name="Ventures Overview",
                    widget_id="entrepreneurship_summary_card",
                    default_position=CardPosition(row=1, column=2, width=2, height=1),
                )
            ],
            quick_actions=[
                QuickActionDefinition(id="create_venture", label="New Venture", action="create_venture", icon="rocket_launch"),
                QuickActionDefinition(id="add_idea", label="Add Idea", action="add_idea", icon="lightbulb"),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="strategy_session",
                    name="Strategy Session",
                    description="Business planning and review block",
                    duration_minutes=60,
                    reminder_minutes=[15, 5],
                    feedback_type="strategy_feedback",
                )
            ],
        )

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "create_venture":
            venture = {"id": len(self._ventures) + 1, **data}
            self._ventures.append(venture)
            return {"success": True, "venture": venture}
        if action == "add_idea":
            idea = {"id": len(self._ideas) + 1, **data}
            self._ideas.append(idea)
            return {"success": True, "idea": idea}
        if action == "set_milestone":
            milestone = {"id": len(self._milestones) + 1, "completed": False, **data}
            self._milestones.append(milestone)
            return {"success": True, "milestone": milestone}
        if action == "list_ventures":
            return {"ventures": self._ventures}
        if action == "get_ventures_summary":
            active_milestones = sum(1 for m in self._milestones if not m.get("completed", False))
            return {
                "venture_count": len(self._ventures),
                "idea_count": len(self._ideas),
                "active_milestones": active_milestones,
            }
        return {"error": f"Unknown action: {action}"}

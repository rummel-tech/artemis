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


class FitnessModule(BaseModule):
    name = "fitness"

    def __init__(self) -> None:
        self._workouts: list[dict[str, Any]] = []
        self._goals: list[dict[str, Any]] = []

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="fitness",
            version="1.0.0",
            description="Workout logging and fitness goal tracking",
            icon="fitness_center",
            color="#4caf50",
            entities=[
                EntitySchema(
                    name="WorkoutSession",
                    fields=[
                        FieldDefinition(name="type", type="string", required=True),
                        FieldDefinition(name="duration_minutes", type="integer", required=True),
                        FieldDefinition(name="date", type="date", required=True),
                        FieldDefinition(name="notes", type="string", required=False),
                    ],
                    searchable_fields=["type"],
                    sortable_fields=["date", "duration_minutes"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="fitness_summary_card",
                    name="Fitness Summary",
                    description="Weekly workout stats and goals",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_fitness_summary",
                )
            ],
            dashboard_cards=[
                DashboardCardDefinition(
                    id="fitness_overview",
                    name="Fitness Overview",
                    widget_id="fitness_summary_card",
                    default_position=CardPosition(row=0, column=2, width=2, height=1),
                )
            ],
            quick_actions=[
                QuickActionDefinition(id="log_workout", label="Log Workout", action="log_workout", icon="fitness_center"),
                QuickActionDefinition(id="set_goal", label="Set Goal", action="set_goal", icon="flag"),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="workout_session",
                    name="Workout Session",
                    description="Scheduled training block",
                    duration_minutes=60,
                    reminder_minutes=[15, 5],
                    feedback_type="workout_feedback",
                )
            ],
            provides_data=[
                DataProviderDefinition(
                    id="calories_burned",
                    name="Calories Burned",
                    description="Daily calories burned via exercise",
                    schema={"date": "date", "calories": "number", "activity_type": "string"},
                    query_action="get_daily_calories",
                )
            ],
        )

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "log_workout":
            workout = {"id": len(self._workouts) + 1, **data}
            self._workouts.append(workout)
            return {"success": True, "workout": workout}
        if action == "set_goal":
            goal = {"id": len(self._goals) + 1, **data}
            self._goals.append(goal)
            return {"success": True, "goal": goal}
        if action == "list_workouts":
            return {"workouts": self._workouts}
        if action == "get_fitness_summary":
            return {
                "total_workouts": len(self._workouts),
                "active_goals": len(self._goals),
                "workouts_this_week": len(self._workouts),
            }
        if action == "get_daily_calories":
            return {"calories": 0, "date": data.get("date", ""), "activity_type": "mixed"}
        return {"error": f"Unknown action: {action}"}

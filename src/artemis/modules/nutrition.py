from typing import Any

from ..core.base_module import BaseModule
from ..core.manifest import (
    ActivityDefinition,
    CardPosition,
    DashboardCardDefinition,
    DataConsumerDefinition,
    EntitySchema,
    FieldDefinition,
    ModuleManifest,
    QuickActionDefinition,
    WidgetCategory,
    WidgetDefinition,
)


class NutritionModule(BaseModule):
    name = "nutrition"

    def __init__(self) -> None:
        self._meals: list[dict[str, Any]] = []
        self._recipes: list[dict[str, Any]] = []
        self._goals: list[dict[str, Any]] = []

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="nutrition",
            version="1.0.0",
            description="Meal planning, nutrition tracking, and recipe management",
            icon="restaurant",
            color="#ff9800",
            entities=[
                EntitySchema(
                    name="Meal",
                    fields=[
                        FieldDefinition(name="name", type="string", required=True),
                        FieldDefinition(name="calories", type="integer", required=False),
                        FieldDefinition(name="date", type="date", required=True),
                        FieldDefinition(name="meal_type", type="enum", default="lunch"),
                    ],
                    searchable_fields=["name"],
                    sortable_fields=["date", "calories"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="nutrition_summary_card",
                    name="Nutrition Summary",
                    description="Daily meals and calorie tracking",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_nutrition_summary",
                )
            ],
            dashboard_cards=[
                DashboardCardDefinition(
                    id="nutrition_overview",
                    name="Nutrition Overview",
                    widget_id="nutrition_summary_card",
                    default_position=CardPosition(row=1, column=0, width=2, height=1),
                )
            ],
            quick_actions=[
                QuickActionDefinition(id="log_meal", label="Log Meal", action="log_meal", icon="restaurant"),
                QuickActionDefinition(id="add_recipe", label="Add Recipe", action="add_recipe", icon="menu_book"),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="meal_prep",
                    name="Meal Prep",
                    description="Weekly meal preparation block",
                    duration_minutes=60,
                    reminder_minutes=[15, 5],
                    feedback_type="meal_prep_feedback",
                )
            ],
            consumes_data=[
                DataConsumerDefinition(
                    id="fitness_calories",
                    provider_module="fitness",
                    provider_id="calories_burned",
                    required=False,
                    use_case="Adjust daily calorie targets based on exercise",
                )
            ],
        )

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "log_meal":
            meal = {"id": len(self._meals) + 1, **data}
            self._meals.append(meal)
            return {"success": True, "meal": meal}
        if action == "add_recipe":
            recipe = {"id": len(self._recipes) + 1, **data}
            self._recipes.append(recipe)
            return {"success": True, "recipe": recipe}
        if action == "set_goal":
            goal = {"id": len(self._goals) + 1, **data}
            self._goals.append(goal)
            return {"success": True, "goal": goal}
        if action == "list_meals":
            return {"meals": self._meals}
        if action == "get_nutrition_summary":
            from datetime import date
            today = date.today().isoformat()
            return {
                "meals_today": sum(1 for m in self._meals if m.get("date", "") == today),
                "recipes_count": len(self._recipes),
                "total_meals": len(self._meals),
            }
        return {"error": f"Unknown action: {action}"}

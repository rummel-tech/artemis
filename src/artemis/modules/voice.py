from datetime import datetime
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

# Ordered list of (keywords, module, action, extra_data).
# The first matching rule wins.
_COMMAND_RULES: list[tuple[tuple[str, ...], str, str, dict[str, Any]]] = [
    # Work
    (("add task", "create task", "new task"), "work", "create_task", {}),
    (("new project", "create project", "add project"), "work", "create_project", {}),
    # Fitness
    (("log workout", "record workout", "log a workout"), "fitness", "log_workout", {}),
    (("set fitness goal", "fitness goal"), "fitness", "set_goal", {}),
    # Nutrition
    (("log meal", "log a meal", "record meal", "ate ", "i ate"), "nutrition", "log_meal", {}),
    (("add recipe", "save recipe", "new recipe"), "nutrition", "add_recipe", {}),
    # Finance
    (("add transaction", "log expense", "i spent", "i paid"), "finance", "add_transaction", {"type": "expense"}),
    (("create budget", "new budget", "add budget"), "finance", "create_budget", {}),
    (("set financial goal", "financial goal"), "finance", "set_goal", {}),
    # Entrepreneurship
    (("new venture", "create venture", "start venture"), "entrepreneurship", "create_venture", {}),
    (("add idea", "new idea", "got an idea", "i have an idea"), "entrepreneurship", "add_idea", {}),
    (("set milestone", "add milestone", "new milestone"), "entrepreneurship", "set_milestone", {}),
    # Assets
    (("add asset", "new asset", "track asset"), "assets", "add_asset", {}),
    (("log maintenance", "maintenance done", "serviced"), "assets", "log_maintenance", {}),
]


class VoiceModule(BaseModule):
    name = "voice"

    def __init__(self) -> None:
        self._command_history: list[dict[str, Any]] = []
        self._command_counter: int = 0

    # ------------------------------------------------------------------
    # Manifest
    # ------------------------------------------------------------------

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="voice",
            version="1.0.0",
            description="Natural-language voice command processing and routing",
            icon="mic",
            color="#607d8b",
            entities=[
                EntitySchema(
                    name="VoiceCommand",
                    fields=[
                        FieldDefinition(name="text", type="string", required=True),
                        FieldDefinition(name="parsed_module", type="string", required=False),
                        FieldDefinition(name="parsed_action", type="string", required=False),
                        FieldDefinition(name="recognized", type="boolean", required=False),
                        FieldDefinition(name="timestamp", type="datetime", required=False),
                    ],
                    searchable_fields=["text", "parsed_module", "parsed_action"],
                    sortable_fields=["timestamp"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="voice_summary_card",
                    name="Voice Commands",
                    description="Recent voice command history and recognition stats",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_voice_summary",
                )
            ],
            dashboard_cards=[
                DashboardCardDefinition(
                    id="voice_overview",
                    name="Voice Overview",
                    widget_id="voice_summary_card",
                    default_position=CardPosition(row=3, column=0, width=2, height=1),
                )
            ],
            quick_actions=[
                QuickActionDefinition(
                    id="voice_command",
                    label="Voice Command",
                    action="process_command",
                    icon="mic",
                ),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="voice_review",
                    name="Voice Command Review",
                    description="Review and confirm pending voice-triggered actions",
                    duration_minutes=5,
                    reminder_minutes=[2],
                    feedback_type="voice_feedback",
                )
            ],
        )

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _parse_command(self, text: str) -> dict[str, Any]:
        """Map free-text input to a module/action routing decision.

        Keywords are matched against whole-word boundaries by padding the
        lowercased text with spaces on both sides before checking each phrase.
        """
        text_lower = text.lower().strip()
        padded = f" {text_lower} "
        for keywords, module, action, extra in _COMMAND_RULES:
            if any(f" {kw} " in padded for kw in keywords):
                data: dict[str, Any] = dict(extra)
                # Extract the portion of the original text that follows the
                # matched keyword as a human-readable value for key fields.
                for kw in keywords:
                    idx = text_lower.find(kw)
                    if idx != -1:
                        remainder = text[idx + len(kw):].strip()
                        if remainder:
                            if action in ("create_task",):
                                data.setdefault("title", remainder)
                            elif action in ("create_project",):
                                data.setdefault("name", remainder)
                            elif action in ("create_venture",):
                                data.setdefault("name", remainder)
                            elif action in ("add_idea", "set_milestone"):
                                data.setdefault("description", remainder)
                            elif action in ("log_workout",):
                                data.setdefault("notes", remainder)
                            elif action in ("log_meal",):
                                data.setdefault("name", remainder)
                            elif action in ("add_recipe",):
                                data.setdefault("name", remainder)
                            elif action in ("add_asset",):
                                data.setdefault("name", remainder)
                            elif action in ("log_maintenance",):
                                data.setdefault("description", remainder)
                        break
                return {"module": module, "action": action, "data": data}
        return {"module": None, "action": None, "data": {}}

    # ------------------------------------------------------------------
    # Actions
    # ------------------------------------------------------------------

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "process_command":
            text = data.get("text", "")
            if not text:
                return {"error": "No command text provided"}
            routing = self._parse_command(text)
            self._command_counter += 1
            entry: dict[str, Any] = {
                "id": self._command_counter,
                "text": text,
                "parsed_module": routing["module"],
                "parsed_action": routing["action"],
                "timestamp": datetime.now().isoformat(),
                "recognized": routing["module"] is not None,
            }
            self._command_history.append(entry)
            return {"command": entry, "routing": routing}

        if action == "get_command_history":
            return {"commands": list(self._command_history)}

        if action == "clear_history":
            self._command_history.clear()
            return {"success": True, "cleared": True}

        if action == "get_voice_summary":
            total = len(self._command_history)
            recognized = sum(1 for c in self._command_history if c.get("recognized", False))
            return {
                "total_commands": total,
                "recognized_commands": recognized,
                "unrecognized_commands": total - recognized,
                "recognition_rate": round(recognized / total, 2) if total else 0.0,
            }

        return {"error": f"Unknown action: {action}"}

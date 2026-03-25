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


class AssetsModule(BaseModule):
    name = "assets"

    def __init__(self) -> None:
        self._assets: list[dict[str, Any]] = []
        self._maintenance_logs: list[dict[str, Any]] = []
        self._documents: list[dict[str, Any]] = []

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="assets",
            version="1.0.0",
            description="Management of physical assets (home, car, motorcycle, etc.)",
            icon="home",
            color="#795548",
            entities=[
                EntitySchema(
                    name="Asset",
                    fields=[
                        FieldDefinition(name="name", type="string", required=True),
                        FieldDefinition(name="type", type="string", required=False),
                        FieldDefinition(name="purchase_date", type="date", required=False),
                        FieldDefinition(name="value", type="number", required=False),
                    ],
                    searchable_fields=["name", "type"],
                    sortable_fields=["purchase_date", "value"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="assets_summary_card",
                    name="Assets Summary",
                    description="Asset inventory and upcoming maintenance",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_assets_summary",
                )
            ],
            dashboard_cards=[
                DashboardCardDefinition(
                    id="assets_overview",
                    name="Assets Overview",
                    widget_id="assets_summary_card",
                    default_position=CardPosition(row=2, column=2, width=2, height=1),
                )
            ],
            quick_actions=[
                QuickActionDefinition(id="add_asset", label="Add Asset", action="add_asset", icon="home"),
                QuickActionDefinition(id="log_maintenance", label="Log Maintenance", action="log_maintenance", icon="build"),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="maintenance_check",
                    name="Maintenance Check",
                    description="Scheduled asset maintenance review",
                    duration_minutes=30,
                    reminder_minutes=[15, 5],
                    feedback_type="maintenance_feedback",
                )
            ],
        )

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "add_asset":
            asset = {"id": len(self._assets) + 1, **data}
            self._assets.append(asset)
            return {"success": True, "asset": asset}
        if action == "log_maintenance":
            log = {"id": len(self._maintenance_logs) + 1, **data}
            self._maintenance_logs.append(log)
            return {"success": True, "maintenance_log": log}
        if action == "add_document":
            doc = {"id": len(self._documents) + 1, **data}
            self._documents.append(doc)
            return {"success": True, "document": doc}
        if action == "list_assets":
            return {"assets": self._assets}
        if action == "get_assets_summary":
            from datetime import date, timedelta
            next_30_days = (date.today() + timedelta(days=30)).isoformat()
            today = date.today().isoformat()
            upcoming = sum(
                1 for m in self._maintenance_logs
                if today <= m.get("due_date", "") <= next_30_days
            )
            return {
                "asset_count": len(self._assets),
                "upcoming_maintenance": upcoming,
                "documents_count": len(self._documents),
            }
        return {"error": f"Unknown action: {action}"}

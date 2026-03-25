from __future__ import annotations

from enum import Enum
from typing import Any

from pydantic import BaseModel


class WidgetCategory(str, Enum):
    dashboard = "dashboard"
    detail = "detail"
    list = "list"
    chart = "chart"
    calendar = "calendar"


class FieldDefinition(BaseModel):
    name: str
    type: str
    required: bool = False
    default: Any = None


class EntitySchema(BaseModel):
    name: str
    fields: list[FieldDefinition]
    primary_key: str = "id"
    searchable_fields: list[str] = []
    sortable_fields: list[str] = []


class WidgetDefinition(BaseModel):
    id: str
    name: str
    description: str
    category: WidgetCategory
    template_type: str
    min_width: int = 1
    min_height: int = 1
    data_action: str
    config_schema: dict[str, Any] | None = None


class CardPosition(BaseModel):
    row: int
    column: int
    width: int
    height: int


class DashboardCardDefinition(BaseModel):
    id: str
    name: str
    widget_id: str
    default_position: CardPosition


class ActionDefinition(BaseModel):
    id: str
    name: str
    description: str = ""


class QuickActionDefinition(BaseModel):
    id: str
    label: str
    action: str
    icon: str | None = None


class ActivityDefinition(BaseModel):
    id: str
    name: str
    description: str = ""
    duration_minutes: int
    is_recurring: bool = False
    recurrence_pattern: str | None = None
    reminder_minutes: list[int] = [15, 5]
    completion_action: str | None = None
    feedback_type: str | None = None
    icon: str | None = None
    color: str | None = None


class NotificationDefinition(BaseModel):
    id: str
    name: str
    description: str = ""
    default_priority: str = "normal"


class DataProviderDefinition(BaseModel):
    id: str
    name: str
    description: str = ""
    schema: dict[str, Any] = {}
    query_action: str


class DataConsumerDefinition(BaseModel):
    id: str
    provider_module: str
    provider_id: str
    required: bool = False
    use_case: str = ""


class MetricDefinition(BaseModel):
    id: str
    name: str
    unit: str = ""
    aggregation: str = "sum"


class ModuleManifest(BaseModel):
    name: str
    version: str
    description: str
    icon: str
    color: str

    entities: list[EntitySchema] = []
    widgets: list[WidgetDefinition] = []
    dashboard_cards: list[DashboardCardDefinition] = []
    actions: list[ActionDefinition] = []
    quick_actions: list[QuickActionDefinition] = []
    schedulable_activities: list[ActivityDefinition] = []
    notification_types: list[NotificationDefinition] = []
    provides_data: list[DataProviderDefinition] = []
    consumes_data: list[DataConsumerDefinition] = []
    metrics: list[MetricDefinition] = []

    has_settings: bool = False
    settings_schema: dict[str, Any] | None = None
    requires_modules: list[str] = []
    supports_export: bool = False
    supports_import: bool = False


class ScheduledActivity(BaseModel):
    id: str
    module_name: str
    activity_type: str
    title: str
    scheduled_time: str
    duration_minutes: int
    status: str = "scheduled"
    data: dict[str, Any] = {}

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


class FinanceModule(BaseModule):
    name = "finance"

    def __init__(self) -> None:
        self._transactions: list[dict[str, Any]] = []
        self._budgets: list[dict[str, Any]] = []
        self._goals: list[dict[str, Any]] = []

    def get_manifest(self) -> ModuleManifest:
        return ModuleManifest(
            name="finance",
            version="1.0.0",
            description="Budget management, transaction tracking, and financial goals",
            icon="account_balance",
            color="#009688",
            entities=[
                EntitySchema(
                    name="Transaction",
                    fields=[
                        FieldDefinition(name="amount", type="number", required=True),
                        FieldDefinition(name="type", type="enum", default="expense"),
                        FieldDefinition(name="category", type="string", required=False),
                        FieldDefinition(name="date", type="date", required=True),
                    ],
                    searchable_fields=["category"],
                    sortable_fields=["date", "amount"],
                )
            ],
            widgets=[
                WidgetDefinition(
                    id="finance_summary_card",
                    name="Finance Summary",
                    description="Monthly spend and budget overview",
                    category=WidgetCategory.dashboard,
                    template_type="summary_card",
                    min_width=2,
                    min_height=1,
                    data_action="get_finance_summary",
                )
            ],
            dashboard_cards=[
                DashboardCardDefinition(
                    id="finance_overview",
                    name="Finance Overview",
                    widget_id="finance_summary_card",
                    default_position=CardPosition(row=2, column=0, width=2, height=1),
                )
            ],
            quick_actions=[
                QuickActionDefinition(id="add_transaction", label="Add Transaction", action="add_transaction", icon="receipt_long"),
                QuickActionDefinition(id="create_budget", label="Create Budget", action="create_budget", icon="savings"),
            ],
            schedulable_activities=[
                ActivityDefinition(
                    id="finance_review",
                    name="Finance Review",
                    description="Weekly budget and spending review",
                    duration_minutes=30,
                    reminder_minutes=[15, 5],
                    feedback_type="finance_feedback",
                )
            ],
        )

    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        if action == "add_transaction":
            transaction = {"id": len(self._transactions) + 1, **data}
            self._transactions.append(transaction)
            return {"success": True, "transaction": transaction}
        if action == "create_budget":
            budget = {"id": len(self._budgets) + 1, **data}
            self._budgets.append(budget)
            return {"success": True, "budget": budget}
        if action == "set_goal":
            goal = {"id": len(self._goals) + 1, **data}
            self._goals.append(goal)
            return {"success": True, "goal": goal}
        if action == "list_transactions":
            return {"transactions": self._transactions}
        if action == "get_finance_summary":
            from datetime import date
            this_month = date.today().strftime("%Y-%m")
            monthly_spend = sum(
                float(t.get("amount", 0))
                for t in self._transactions
                if t.get("date", "")[:7] == this_month and t.get("type") == "expense"
            )
            return {
                "transaction_count": len(self._transactions),
                "monthly_spend": round(monthly_spend, 2),
                "budget_count": len(self._budgets),
            }
        return {"error": f"Unknown action: {action}"}

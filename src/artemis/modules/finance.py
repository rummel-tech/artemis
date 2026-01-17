"""Finance management module for Artemis personal OS."""
from typing import Any, Dict
from artemis.core.module import BaseModule, ModuleConfig, ModuleStatus


class FinanceModule(BaseModule):
    """Module for managing finances, budgets, and financial goals.
    
    Features:
    - Transaction tracking
    - Budget management
    - Financial goal setting
    - Investment tracking
    - Expense categorization
    """
    
    def __init__(self, config: ModuleConfig) -> None:
        """Initialize the finance module."""
        super().__init__(config)
        self.transactions: Dict[str, Any] = {}
        self.budgets: Dict[str, Any] = {}
        self.goals: Dict[str, Any] = {}
        self.investments: Dict[str, Any] = {}
    
    async def initialize(self) -> None:
        """Initialize the finance module."""
        self._initialized = True
    
    async def shutdown(self) -> None:
        """Shutdown the finance module."""
        self._initialized = False
    
    async def get_status(self) -> ModuleStatus:
        """Get the current status of the finance module."""
        return ModuleStatus(
            name=self.name,
            enabled=self.is_enabled,
            healthy=self._initialized,
            message=f"Tracking {len(self.transactions)} transactions and {len(self.budgets)} budgets"
        )
    
    async def handle_action(self, action: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle finance module actions."""
        if action == "add_transaction":
            transaction_id = data.get("id", f"transaction_{len(self.transactions)}")
            self.transactions[transaction_id] = data
            return {"status": "success", "transaction_id": transaction_id}
        
        elif action == "create_budget":
            budget_id = data.get("id", f"budget_{len(self.budgets)}")
            self.budgets[budget_id] = data
            return {"status": "success", "budget_id": budget_id}
        
        elif action == "set_goal":
            goal_id = data.get("id", f"goal_{len(self.goals)}")
            self.goals[goal_id] = data
            return {"status": "success", "goal_id": goal_id}
        
        elif action == "list_transactions":
            return {"transactions": list(self.transactions.values())}
        
        return {"status": "error", "message": f"Unknown action: {action}"}

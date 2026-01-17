"""Nutrition management module for Artemis personal OS."""
from typing import Any, Dict
from uuid import uuid4
from artemis.core.module import BaseModule, ModuleConfig, ModuleStatus


class NutritionModule(BaseModule):
    """Module for managing nutrition, meal planning, and dietary tracking.
    
    Features:
    - Meal logging
    - Nutrition tracking
    - Diet goal management
    - Recipe storage
    """
    
    def __init__(self, config: ModuleConfig) -> None:
        """Initialize the nutrition module."""
        super().__init__(config)
        self.meals: Dict[str, Any] = {}
        self.recipes: Dict[str, Any] = {}
        self.goals: Dict[str, Any] = {}
    
    async def initialize(self) -> None:
        """Initialize the nutrition module."""
        self._initialized = True
    
    async def shutdown(self) -> None:
        """Shutdown the nutrition module."""
        self._initialized = False
    
    async def get_status(self) -> ModuleStatus:
        """Get the current status of the nutrition module."""
        return ModuleStatus(
            name=self.name,
            enabled=self.is_enabled,
            healthy=self._initialized,
            message=f"Tracking {len(self.meals)} meals with {len(self.recipes)} recipes"
        )
    
    async def handle_action(self, action: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle nutrition module actions."""
        if action == "log_meal":
            meal_id = data.get("id", f"meal_{uuid4().hex[:8]}")
            self.meals[meal_id] = data
            return {"status": "success", "meal_id": meal_id}
        
        elif action == "add_recipe":
            recipe_id = data.get("id", f"recipe_{uuid4().hex[:8]}")
            self.recipes[recipe_id] = data
            return {"status": "success", "recipe_id": recipe_id}
        
        elif action == "set_goal":
            goal_id = data.get("id", f"goal_{uuid4().hex[:8]}")
            self.goals[goal_id] = data
            return {"status": "success", "goal_id": goal_id}
        
        elif action == "list_meals":
            return {"meals": list(self.meals.values())}
        
        return {"status": "error", "message": f"Unknown action: {action}"}

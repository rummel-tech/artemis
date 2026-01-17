"""Work management module for Artemis personal OS."""
from typing import Any, Dict
from uuid import uuid4
from artemis.core.module import BaseModule, ModuleConfig, ModuleStatus


class WorkModule(BaseModule):
    """Module for managing work-related tasks, projects, and productivity.
    
    Features:
    - Task management
    - Project tracking
    - Time tracking
    - Goal setting and achievement tracking
    """
    
    def __init__(self, config: ModuleConfig) -> None:
        """Initialize the work module."""
        super().__init__(config)
        self.tasks: Dict[str, Any] = {}
        self.projects: Dict[str, Any] = {}
    
    async def initialize(self) -> None:
        """Initialize the work module."""
        self._initialized = True
    
    async def shutdown(self) -> None:
        """Shutdown the work module."""
        self._initialized = False
    
    async def get_status(self) -> ModuleStatus:
        """Get the current status of the work module."""
        return ModuleStatus(
            name=self.name,
            enabled=self.is_enabled,
            healthy=self._initialized,
            message=f"Managing {len(self.tasks)} tasks and {len(self.projects)} projects"
        )
    
    async def handle_action(self, action: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle work module actions."""
        if action == "create_task":
            task_id = data.get("id", f"task_{uuid4().hex[:8]}")
            self.tasks[task_id] = data
            return {"status": "success", "task_id": task_id}
        
        elif action == "create_project":
            project_id = data.get("id", f"project_{uuid4().hex[:8]}")
            self.projects[project_id] = data
            return {"status": "success", "project_id": project_id}
        
        elif action == "list_tasks":
            return {"tasks": list(self.tasks.values())}
        
        elif action == "list_projects":
            return {"projects": list(self.projects.values())}
        
        return {"status": "error", "message": f"Unknown action: {action}"}

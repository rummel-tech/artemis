"""FastAPI application for Artemis personal OS."""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Any, Dict, List
from artemis.core.registry import registry
from artemis.core.module import ModuleConfig, ModuleStatus
from artemis.modules.work import WorkModule
from artemis.modules.fitness import FitnessModule
from artemis.modules.nutrition import NutritionModule
from artemis.modules.entrepreneurship import EntrepreneurshipModule
from artemis.modules.finance import FinanceModule
from artemis.modules.assets import AssetsModule


app = FastAPI(
    title="Artemis Personal OS API",
    description="API for managing time, energy, and resources across multiple life domains",
    version="0.1.0"
)

# Configure CORS for Flutter web and mobile apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ActionRequest(BaseModel):
    """Request model for module actions."""
    action: str
    data: Dict[str, Any] = {}


@app.on_event("startup")
async def startup_event() -> None:
    """Initialize all modules on startup."""
    # Register all modules
    modules = [
        WorkModule(ModuleConfig(name="work")),
        FitnessModule(ModuleConfig(name="fitness")),
        NutritionModule(ModuleConfig(name="nutrition")),
        EntrepreneurshipModule(ModuleConfig(name="entrepreneurship")),
        FinanceModule(ModuleConfig(name="finance")),
        AssetsModule(ModuleConfig(name="assets")),
    ]
    
    for module in modules:
        registry.register(module)
    
    # Initialize all modules
    await registry.initialize_all()


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Shutdown all modules on application shutdown."""
    await registry.shutdown_all()


@app.get("/")
async def root() -> Dict[str, str]:
    """Root endpoint."""
    return {
        "name": "Artemis Personal OS API",
        "version": "0.1.0",
        "description": "Personal OS for managing work, fitness, nutrition, entrepreneurship, finance, and assets"
    }


@app.get("/health")
async def health_check() -> Dict[str, str]:
    """Health check endpoint."""
    return {"status": "healthy"}


@app.get("/modules", response_model=List[str])
async def list_modules() -> List[str]:
    """List all available modules."""
    return registry.list_modules()


@app.get("/modules/status", response_model=List[ModuleStatus])
async def get_modules_status() -> List[ModuleStatus]:
    """Get status of all modules."""
    return await registry.get_all_status()


@app.get("/modules/{module_name}/status", response_model=ModuleStatus)
async def get_module_status(module_name: str) -> ModuleStatus:
    """Get status of a specific module."""
    module = registry.get(module_name)
    if not module:
        raise HTTPException(status_code=404, detail=f"Module '{module_name}' not found")
    
    return await module.get_status()


@app.post("/modules/{module_name}/action")
async def execute_module_action(
    module_name: str,
    request: ActionRequest
) -> Dict[str, Any]:
    """Execute an action on a specific module."""
    module = registry.get(module_name)
    if not module:
        raise HTTPException(status_code=404, detail=f"Module '{module_name}' not found")
    
    if not module.is_enabled:
        raise HTTPException(status_code=403, detail=f"Module '{module_name}' is not enabled")
    
    return await module.handle_action(request.action, request.data)

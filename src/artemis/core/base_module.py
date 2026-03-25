from abc import ABC, abstractmethod
from typing import Any

from .manifest import ModuleManifest


class BaseModule(ABC):
    name: str = ""

    @abstractmethod
    def get_manifest(self) -> ModuleManifest:
        ...

    async def startup(self) -> None:
        from .discovery import discovery_service
        discovery_service.register(self.get_manifest())

    @abstractmethod
    def execute_action(self, action: str, data: dict[str, Any]) -> dict[str, Any]:
        ...

from .manifest import ModuleManifest, WidgetDefinition, ActivityDefinition, DataProviderDefinition


class DiscoveryService:
    def __init__(self) -> None:
        self._manifests: dict[str, ModuleManifest] = {}
        self._pending: set[str] = set()

    def register(self, manifest: ModuleManifest) -> None:
        self._manifests[manifest.name] = manifest
        self._pending.discard(manifest.name)

    def get_manifest(self, name: str) -> ModuleManifest | None:
        return self._manifests.get(name)

    def get_all_manifests(self) -> list[ModuleManifest]:
        return list(self._manifests.values())

    def get_dashboard_widgets(self) -> list[WidgetDefinition]:
        widgets: list[WidgetDefinition] = []
        for manifest in self._manifests.values():
            widgets.extend(manifest.widgets)
        return widgets

    def get_schedulable_activities(self) -> list[ActivityDefinition]:
        activities: list[ActivityDefinition] = []
        for manifest in self._manifests.values():
            activities.extend(manifest.schedulable_activities)
        return activities

    def get_data_providers(self, consumer_module: str | None = None) -> list[DataProviderDefinition]:
        providers: list[DataProviderDefinition] = []
        for name, manifest in self._manifests.items():
            if consumer_module and name == consumer_module:
                continue
            providers.extend(manifest.provides_data)
        return providers

    def get_module_status(self, name: str) -> str:
        if name in self._manifests:
            return "active"
        if name in self._pending:
            return "pending"
        return "error"


discovery_service = DiscoveryService()

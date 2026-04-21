"""Tests for Artemis manifest-based module system."""

import pytest
from src.artemis.core.manifest import ModuleManifest
from src.artemis.modules import (
    AssetsModule,
    EntrepreneurshipModule,
    FinanceModule,
    FitnessModule,
    NutritionModule,
    VoiceModule,
    WorkModule,
)


# --- Manifest validation helpers ---

def _assert_valid_manifest(manifest: ModuleManifest) -> None:
    assert isinstance(manifest.name, str) and manifest.name
    assert isinstance(manifest.version, str) and manifest.version
    assert isinstance(manifest.description, str) and manifest.description
    assert isinstance(manifest.icon, str) and manifest.icon
    assert isinstance(manifest.color, str) and manifest.color.startswith("#")


# --- Work module ---

def test_work_manifest_valid():
    manifest = WorkModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "work"


def test_work_manifest_has_entities():
    manifest = WorkModule().get_manifest()
    assert len(manifest.entities) >= 1
    assert manifest.entities[0].name == "Task"


def test_work_manifest_has_quick_actions():
    manifest = WorkModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_work_manifest_has_activities():
    manifest = WorkModule().get_manifest()
    assert len(manifest.schedulable_activities) >= 1
    assert manifest.schedulable_activities[0].id == "work_session"


def test_work_manifest_has_dashboard_cards():
    manifest = WorkModule().get_manifest()
    assert len(manifest.dashboard_cards) >= 1


def test_work_create_task():
    module = WorkModule()
    result = module.execute_action("create_task", {"title": "Test task", "priority": "high"})
    assert result["success"] is True
    assert result["task"]["title"] == "Test task"


def test_work_create_project():
    module = WorkModule()
    result = module.execute_action("create_project", {"name": "Project Alpha"})
    assert result["success"] is True


def test_work_list_tasks():
    module = WorkModule()
    module.execute_action("create_task", {"title": "Task 1"})
    result = module.execute_action("list_tasks", {})
    assert len(result["tasks"]) == 1


# --- Fitness module ---

def test_fitness_manifest_valid():
    manifest = FitnessModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "fitness"


def test_fitness_manifest_has_quick_actions():
    manifest = FitnessModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_fitness_manifest_has_activities():
    manifest = FitnessModule().get_manifest()
    assert len(manifest.schedulable_activities) >= 1


def test_fitness_log_workout():
    module = FitnessModule()
    result = module.execute_action("log_workout", {"type": "Running", "duration_minutes": 30})
    assert result["success"] is True
    assert result["workout"]["type"] == "Running"


def test_fitness_set_goal():
    module = FitnessModule()
    result = module.execute_action("set_goal", {"description": "Run 5K"})
    assert result["success"] is True


def test_fitness_summary_action():
    module = FitnessModule()
    result = module.execute_action("get_fitness_summary", {})
    assert "total_workouts" in result
    assert "active_goals" in result


# --- Nutrition module ---

def test_nutrition_manifest_valid():
    manifest = NutritionModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "nutrition"


def test_nutrition_manifest_has_quick_actions():
    manifest = NutritionModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_nutrition_log_meal():
    module = NutritionModule()
    result = module.execute_action("log_meal", {"name": "Breakfast", "calories": 400})
    assert result["success"] is True


def test_nutrition_add_recipe():
    module = NutritionModule()
    result = module.execute_action("add_recipe", {"name": "Omelette"})
    assert result["success"] is True


# --- Entrepreneurship module ---

def test_entrepreneurship_manifest_valid():
    manifest = EntrepreneurshipModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "entrepreneurship"


def test_entrepreneurship_manifest_has_quick_actions():
    manifest = EntrepreneurshipModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_entrepreneurship_create_venture():
    module = EntrepreneurshipModule()
    result = module.execute_action("create_venture", {"name": "My Startup"})
    assert result["success"] is True


def test_entrepreneurship_add_idea():
    module = EntrepreneurshipModule()
    result = module.execute_action("add_idea", {"description": "SaaS for X"})
    assert result["success"] is True


def test_entrepreneurship_set_milestone():
    module = EntrepreneurshipModule()
    result = module.execute_action("set_milestone", {"title": "Launch MVP"})
    assert result["success"] is True
    assert result["milestone"]["completed"] is False


# --- Finance module ---

def test_finance_manifest_valid():
    manifest = FinanceModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "finance"


def test_finance_manifest_has_quick_actions():
    manifest = FinanceModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_finance_add_transaction():
    module = FinanceModule()
    result = module.execute_action("add_transaction", {"amount": 50.0, "type": "expense"})
    assert result["success"] is True


def test_finance_create_budget():
    module = FinanceModule()
    result = module.execute_action("create_budget", {"category": "Food", "limit": 500})
    assert result["success"] is True


# --- Assets module ---

def test_assets_manifest_valid():
    manifest = AssetsModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "assets"


def test_assets_manifest_has_quick_actions():
    manifest = AssetsModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_assets_add_asset():
    module = AssetsModule()
    result = module.execute_action("add_asset", {"name": "Tesla Model 3", "type": "vehicle"})
    assert result["success"] is True


def test_assets_log_maintenance():
    module = AssetsModule()
    result = module.execute_action("log_maintenance", {"description": "Oil change"})
    assert result["success"] is True


def test_assets_asset_count():
    module = AssetsModule()
    module.execute_action("add_asset", {"name": "Home"})
    result = module.execute_action("get_assets_summary", {})
    assert result["asset_count"] == 1


# --- All modules have valid manifests ---

def test_all_modules_have_valid_manifests():
    modules = [
        WorkModule(), FitnessModule(), NutritionModule(),
        EntrepreneurshipModule(), FinanceModule(), AssetsModule(),
        VoiceModule(),
    ]
    for module in modules:
        manifest = module.get_manifest()
        _assert_valid_manifest(manifest)


def test_all_modules_unique_names():
    modules = [
        WorkModule(), FitnessModule(), NutritionModule(),
        EntrepreneurshipModule(), FinanceModule(), AssetsModule(),
        VoiceModule(),
    ]
    names = [m.get_manifest().name for m in modules]
    assert len(names) == len(set(names))


# --- Voice module ---

def test_voice_manifest_valid():
    manifest = VoiceModule().get_manifest()
    _assert_valid_manifest(manifest)
    assert manifest.name == "voice"


def test_voice_manifest_has_widget():
    manifest = VoiceModule().get_manifest()
    assert len(manifest.widgets) >= 1
    assert manifest.widgets[0].id == "voice_summary_card"


def test_voice_manifest_has_dashboard_card():
    manifest = VoiceModule().get_manifest()
    assert len(manifest.dashboard_cards) >= 1


def test_voice_manifest_has_quick_action():
    manifest = VoiceModule().get_manifest()
    assert len(manifest.quick_actions) >= 1


def test_voice_manifest_has_activity():
    manifest = VoiceModule().get_manifest()
    assert len(manifest.schedulable_activities) >= 1
    assert manifest.schedulable_activities[0].id == "voice_review"


def test_voice_process_command_work_task():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "add task review sprint notes"})
    assert result["command"]["recognized"] is True
    assert result["routing"]["module"] == "work"
    assert result["routing"]["action"] == "create_task"
    assert result["routing"]["data"].get("title") == "review sprint notes"


def test_voice_process_command_fitness():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "log workout running 30 minutes"})
    assert result["command"]["recognized"] is True
    assert result["routing"]["module"] == "fitness"
    assert result["routing"]["action"] == "log_workout"


def test_voice_process_command_nutrition():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "log meal breakfast oatmeal"})
    assert result["command"]["recognized"] is True
    assert result["routing"]["module"] == "nutrition"
    assert result["routing"]["action"] == "log_meal"
    assert result["routing"]["data"].get("name") == "breakfast oatmeal"


def test_voice_process_command_finance():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "i spent 50 dollars on groceries"})
    assert result["command"]["recognized"] is True
    assert result["routing"]["module"] == "finance"
    assert result["routing"]["action"] == "add_transaction"
    assert result["routing"]["data"]["type"] == "expense"


def test_voice_process_command_entrepreneurship():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "add idea SaaS for remote teams"})
    assert result["command"]["recognized"] is True
    assert result["routing"]["module"] == "entrepreneurship"
    assert result["routing"]["action"] == "add_idea"


def test_voice_process_command_assets():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "log maintenance oil change done"})
    assert result["command"]["recognized"] is True
    assert result["routing"]["module"] == "assets"
    assert result["routing"]["action"] == "log_maintenance"


def test_voice_process_command_unrecognized():
    module = VoiceModule()
    result = module.execute_action("process_command", {"text": "xyzzy unknown gibberish"})
    assert result["command"]["recognized"] is False
    assert result["routing"]["module"] is None
    assert result["routing"]["action"] is None


def test_voice_process_command_no_text():
    module = VoiceModule()
    result = module.execute_action("process_command", {})
    assert "error" in result


def test_voice_command_history():
    module = VoiceModule()
    module.execute_action("process_command", {"text": "add task meeting prep"})
    module.execute_action("process_command", {"text": "log workout cycling"})
    result = module.execute_action("get_command_history", {})
    assert len(result["commands"]) == 2
    assert result["commands"][0]["text"] == "add task meeting prep"


def test_voice_clear_history():
    module = VoiceModule()
    module.execute_action("process_command", {"text": "add task something"})
    module.execute_action("clear_history", {})
    result = module.execute_action("get_command_history", {})
    assert len(result["commands"]) == 0


def test_voice_id_monotonic_after_clear():
    """Command IDs must keep incrementing even after the history is cleared."""
    module = VoiceModule()
    r1 = module.execute_action("process_command", {"text": "add task first"})
    module.execute_action("clear_history", {})
    r2 = module.execute_action("process_command", {"text": "add task second"})
    assert r2["command"]["id"] > r1["command"]["id"]


def test_voice_summary_stats():
    module = VoiceModule()
    module.execute_action("process_command", {"text": "log workout running"})
    module.execute_action("process_command", {"text": "xyzzy unrecognized"})
    summary = module.execute_action("get_voice_summary", {})
    assert summary["total_commands"] == 2
    assert summary["recognized_commands"] == 1
    assert summary["unrecognized_commands"] == 1
    assert summary["recognition_rate"] == 0.5


def test_voice_summary_empty():
    module = VoiceModule()
    summary = module.execute_action("get_voice_summary", {})
    assert summary["total_commands"] == 0
    assert summary["recognition_rate"] == 0.0


def test_voice_unknown_action():
    module = VoiceModule()
    result = module.execute_action("nonexistent_action", {})
    assert "error" in result

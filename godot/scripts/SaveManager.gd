extends Node

const SAVE_PATH := "user://tiny_tamer_save.json"
var loaded_position := Vector2(220, 220)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(player_position: Vector2 = Vector2.ZERO) -> void:
	var data := {
		"player_position": [player_position.x, player_position.y],
		"caught_critters": GameState.caught_critters,
		"caught_cp": GameState.caught_cp,
		"active_companion": GameState.active_companion,
		"team": GameState.team,
		"meadow_orbs": GameState.meadow_orbs,
		"player_cp": GameState.player_cp,
		"tamer_rank": GameState.tamer_rank,
		"quest_id": QuestManager.active_quest_id,
		"quest_progress": QuestManager.quest_progress,
		"completed_quests": QuestManager.completed_quests,
		"settings": {"sound": SettingsManager.sound_enabled, "touch": SettingsManager.touch_controls_mode}
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var pos = parsed.get("player_position", [220, 220])
	loaded_position = Vector2(pos[0], pos[1])
	GameState.caught_critters = []
	for x in parsed.get("caught_critters", []): GameState.caught_critters.append(str(x))
	GameState.caught_cp = parsed.get("caught_cp", {})
	GameState.active_companion = parsed.get("active_companion", "Spriglet")
	GameState.team = parsed.get("team", [GameState.active_companion])
	GameState.meadow_orbs = int(parsed.get("meadow_orbs", 3))
	GameState.player_cp = int(parsed.get("player_cp", 42))
	GameState.tamer_rank = int(parsed.get("tamer_rank", 1))
	QuestManager.active_quest_id = parsed.get("quest_id", "first_steps")
	QuestManager.quest_progress = parsed.get("quest_progress", {})
	QuestManager.completed_quests = parsed.get("completed_quests", [])
	var st = parsed.get("settings", {})
	SettingsManager.sound_enabled = st.get("sound", true)
	SettingsManager.touch_controls_mode = st.get("touch", "Auto")
	return true

func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

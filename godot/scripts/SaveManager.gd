extends Node

const SAVE_PATH := "user://tiny_tamer_save.json"

var loaded_position := Vector2(230, 250)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(player_pos: Variant = null) -> void:
	if player_pos is Vector2:
		GameState.last_player_position = player_pos
	var data := {
		"last_player_position": {"x": GameState.last_player_position.x, "y": GameState.last_player_position.y},
		"active_quest_id": QuestManager.active_quest_id,
		"completed_quests": QuestManager.completed_quests,
		"quest_progress": QuestManager.quest_progress,
		"caught_critters": GameState.caught_critters,
		"caught_cp": GameState.caught_cp,
		"active_companion": GameState.active_companion,
		"meadow_orbs": GameState.meadow_orbs,
		"tamer_rank": GameState.tamer_rank,
		"player_level": GameState.player_level,
		"player_exp": GameState.player_exp,
		"player_exp_to_next": GameState.player_exp_to_next,
		"player_cp": GameState.player_cp,
		"team": GameState.team,
		"sound_enabled": SettingsManager.sound_enabled,
		"touch_controls_mode": SettingsManager.touch_controls_mode
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game() -> void:
	if not has_save():
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("SaveManager: Cannot open save file for reading")
		return
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) != OK:
		push_warning("SaveManager: Failed to parse save JSON")
		return
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("SaveManager: Save data is not a dictionary")
		return
	if data.has("last_player_position"):
		var pos = data["last_player_position"]
		loaded_position = Vector2(pos.get("x", 230), pos.get("y", 250))
		GameState.last_player_position = loaded_position
	if data.has("active_quest_id"): QuestManager.active_quest_id = data["active_quest_id"]
	if data.has("completed_quests"): QuestManager.completed_quests = data["completed_quests"]
	if data.has("quest_progress"): QuestManager.quest_progress = data["quest_progress"]
	if data.has("caught_critters"):
		var cc: Array[String] = []
		for c in data["caught_critters"]:
			cc.append(str(c))
		GameState.caught_critters = cc
	if data.has("caught_cp"): GameState.caught_cp = data["caught_cp"]
	if data.has("active_companion"): GameState.active_companion = data["active_companion"]
	if data.has("meadow_orbs"): GameState.meadow_orbs = int(data["meadow_orbs"])
	if data.has("tamer_rank"): GameState.tamer_rank = int(data["tamer_rank"])
	if data.has("player_level"): GameState.player_level = int(data["player_level"])
	if data.has("player_exp"): GameState.player_exp = int(data["player_exp"])
	if data.has("player_exp_to_next"): GameState.player_exp_to_next = int(data["player_exp_to_next"])
	if data.has("player_cp"): GameState.player_cp = int(data["player_cp"])
	if data.has("team"):
		var tm: Array = []
		for t in data["team"]:
			tm.append(str(t))
		GameState.team = tm
	if data.has("sound_enabled"):
		SettingsManager.sound_enabled = data["sound_enabled"]
	if data.has("touch_controls_mode"):
		SettingsManager.touch_controls_mode = data["touch_controls_mode"]
	GameState.apply_companion_stats()

func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("tiny_tamer_save.json")

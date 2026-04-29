extends Node

var active_quest_id := "first_steps"
var completed_quests: Array = []
var quest_progress := {}

var quests := {
	"first_steps": {"title":"First Field Note", "objective":"Talk to the Meadow Guide", "target":1, "reward_orbs":2},
	"first_catch": {"title":"First Catch", "objective":"Catch any wild critter", "target":1, "reward_orbs":3},
	"forest_survey": {"title":"Forest Survey", "objective":"Catch 1 Mossbun in Whisper Forest", "target":1, "reward_orbs":3},
	"river_research": {"title":"River Research", "objective":"Catch 1 Aqualit near Bluebell River", "target":1, "reward_orbs":4},
	"cragpeak_trial": {"title":"Cragpeak Trial", "objective":"Reach Cragpeak Cave Gate", "target":1, "reward_orbs":5}
}

func current() -> Dictionary:
	return quests.get(active_quest_id, {})

func progress_text() -> String:
	var q := current()
	if q.is_empty(): return "Wild Routes complete"
	return "%s: %s" % [q.get("title", "Quest"), q.get("objective", "Explore")]

func mark_talked_guide() -> void:
	if active_quest_id == "first_steps":
		_complete_and_advance("first_catch")

func on_capture(name: String, biome: String) -> void:
	if active_quest_id == "first_catch":
		_complete_and_advance("forest_survey")
	elif active_quest_id == "forest_survey" and name == "Mossbun":
		_complete_and_advance("river_research")
	elif active_quest_id == "river_research" and name == "Aqualit":
		_complete_and_advance("cragpeak_trial")

func on_reach_area(area: String) -> void:
	if active_quest_id == "cragpeak_trial" and area == "Cragpeak Cave Gate":
		_complete_and_advance("")

func _complete_and_advance(next_id: String) -> void:
	var old := active_quest_id
	if not completed_quests.has(old): completed_quests.append(old)
	var reward := int(quests.get(old, {}).get("reward_orbs", 1))
	GameState.meadow_orbs += reward
	GameState.tamer_rank = max(GameState.tamer_rank, completed_quests.size() + 1)
	GameState.last_battle_message = "Quest complete: %s (+%d Orbs)" % [quests.get(old, {}).get("title", old), reward]
	active_quest_id = next_id

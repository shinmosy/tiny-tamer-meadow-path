extends Node

var player_max_hp := 34
var player_hp := 34
var player_attack := 7
var player_skill_name := "Leaf Pop"
var player_skill_damage := 12
var player_level := 1
var player_exp := 0
var player_exp_to_next := 20
var player_cp := 48
var tamer_rank := 1
var meadow_orbs := 4
var mobile_move_vector := Vector2.ZERO
var mobile_interact_queued := false

var enemy_name := "Mossbun"
var enemy_type := "Forest"
var enemy_max_hp := 26
var enemy_hp := 26
var enemy_attack := 5
var enemy_skill_name := "Moss Bump"
var enemy_skill_damage := 9
var enemy_sprite := "res://assets/sprites/mossbun.svg"
var enemy_cp := 40
var enemy_biome := "Forest"

var caught_critters: Array[String] = []
var caught_cp := {}
var team: Array = ["Spriglet"]
var active_companion := "Spriglet"
var current_biome := "Meadow"
var last_battle_message := ""

var monsters := {
	"Spriglet": {"type":"Meadow", "biome":"Starter", "role":"Balanced starter", "max_hp":34, "attack":7, "defense":4, "speed":5, "focus":6, "cp_min":45, "cp_max":65, "skill_name":"Leaf Pop", "skill_damage":12, "trait":"Fresh Guard", "sprite":"res://assets/sprites/spriglet.svg", "description":"A brave sprout companion that nudges new tamers toward wild routes."},
	"Bloomrat": {"type":"Bloom", "biome":"Meadow", "role":"Fast attacker", "max_hp":24, "attack":6, "defense":3, "speed":8, "focus":5, "cp_min":35, "cp_max":95, "skill_name":"Bloom Rush", "skill_damage":11, "trait":"Quick feet", "sprite":"res://assets/sprites/bloomrat.svg", "description":"A cheeky flower-tailed critter that darts through bright fields."},
	"Fluffin": {"type":"Meadow", "biome":"Meadow", "role":"Support", "max_hp":28, "attack":4, "defense":5, "speed":4, "focus":7, "cp_min":30, "cp_max":85, "skill_name":"Cotton Cheer", "skill_damage":8, "trait":"Soft landing", "sprite":"res://assets/sprites/fluffin.svg", "description":"A tiny cloud-sheep that calms nervous companions."},
	"Pebblet": {"type":"Stone", "biome":"Meadow", "role":"Beginner tank", "max_hp":32, "attack":5, "defense":7, "speed":3, "focus":3, "cp_min":35, "cp_max":90, "skill_name":"Pebble Tap", "skill_damage":9, "trait":"Sturdy", "sprite":"res://assets/sprites/pebblet.svg", "description":"A small pebble bug that hides beside old route stones."},
	"Mossbun": {"type":"Forest", "biome":"Forest", "role":"Tank healer", "max_hp":30, "attack":5, "defense":7, "speed":4, "focus":6, "cp_min":45, "cp_max":120, "skill_name":"Soft Moss", "skill_damage":10, "trait":"Regrowth", "sprite":"res://assets/sprites/mossbun.svg", "description":"A gentle moss rabbit that naps near roots and old logs."},
	"Twiggle": {"type":"Forest", "biome":"Forest", "role":"Scout", "max_hp":25, "attack":6, "defense":4, "speed":8, "focus":6, "cp_min":40, "cp_max":110, "skill_name":"Twig Jab", "skill_damage":10, "trait":"Ambush", "sprite":"res://assets/sprites/twiggle.svg", "description":"A stick-like forest scout that freezes when spotted."},
	"Gloomcap": {"type":"Forest", "biome":"Forest", "role":"Status", "max_hp":27, "attack":4, "defense":5, "speed":3, "focus":9, "cp_min":45, "cp_max":115, "skill_name":"Sleepy Spores", "skill_damage":8, "trait":"Drowsy spores", "sprite":"res://assets/sprites/gloomcap.svg", "description":"A shy mushroom critter whose spores make routes strangely quiet."},
	"Aqualit": {"type":"Water", "biome":"River", "role":"Capture support", "max_hp":28, "attack":5, "defense":5, "speed":7, "focus":7, "cp_min":50, "cp_max":125, "skill_name":"Soak", "skill_damage":9, "trait":"Capture boost", "sprite":"res://assets/sprites/aqualit.svg", "description":"A playful river critter that leaves blue sparkles in shallow water."},
	"Ripplefin": {"type":"Water", "biome":"River", "role":"Speed", "max_hp":24, "attack":7, "defense":3, "speed":9, "focus":6, "cp_min":50, "cp_max":130, "skill_name":"Bubble Dash", "skill_damage":12, "trait":"Swift swim", "sprite":"res://assets/sprites/ripplefin.svg", "description":"A tiny finned dragon that skips across the river surface."},
	"Lilypadle": {"type":"Water", "biome":"River", "role":"Balanced", "max_hp":30, "attack":5, "defense":6, "speed":5, "focus":6, "cp_min":45, "cp_max":118, "skill_name":"Lily Leap", "skill_damage":10, "trait":"Calm water", "sprite":"res://assets/sprites/lilypadle.svg", "description":"A frog-like critter that rests under lily pads until sunset."},
	"Cragcub": {"type":"Stone", "biome":"Mountain", "role":"Heavy attacker", "max_hp":34, "attack":8, "defense":8, "speed":2, "focus":3, "cp_min":65, "cp_max":150, "skill_name":"Pebble Pounce", "skill_damage":13, "trait":"Rock Guard", "sprite":"res://assets/sprites/cragcub.svg", "description":"A stubborn cub that rolls down warm mountain paths."},
	"Embermite": {"type":"Ember", "biome":"Mountain", "role":"Glass cannon", "max_hp":24, "attack":9, "defense":3, "speed":7, "focus":6, "cp_min":60, "cp_max":145, "skill_name":"Warm Spark", "skill_damage":14, "trait":"Tiny flame", "sprite":"res://assets/sprites/embermite.svg", "description":"A cave bug that glows like a lantern when excited."},
	"Bramblehorn": {"type":"Forest", "biome":"Boss", "role":"Mini boss", "max_hp":62, "attack":9, "defense":8, "speed":3, "focus":7, "cp_min":180, "cp_max":210, "skill_name":"Bramble Charge", "skill_damage":16, "trait":"Guardian", "sprite":"res://assets/sprites/bramblehorn.svg", "description":"The first Wild Route guardian. It tests prepared hearts, not curious feet."}
}

func _ready() -> void:
	apply_companion_stats()

func get_monster_names() -> Array:
	return monsters.keys()

func get_monster_data(name: String) -> Dictionary:
	return monsters.get(name, monsters["Spriglet"])

func choose_random_enemy(biome := "") -> void:
	var target = biome if biome != "" else current_biome
	var pool := []
	for name in monsters.keys():
		var m = monsters[name]
		if m.get("biome") == target:
			pool.append(name)
	if pool.is_empty(): pool = ["Bloomrat"]
	_set_enemy(pool.pick_random())

func choose_boss() -> void:
	_set_enemy("Bramblehorn")

func _set_enemy(name: String) -> void:
	var m = get_monster_data(name)
	enemy_name = name
	enemy_type = m.get("type", "Meadow")
	enemy_biome = m.get("biome", "Meadow")
	enemy_max_hp = int(m.get("max_hp", 25))
	enemy_hp = enemy_max_hp
	enemy_attack = int(m.get("attack", 5))
	enemy_skill_name = m.get("skill_name", "Wild Hit")
	enemy_skill_damage = int(m.get("skill_damage", 8))
	enemy_sprite = m.get("sprite", "res://assets/sprites/mossbun.svg")
	enemy_cp = randi_range(int(m.get("cp_min", 30)), int(m.get("cp_max", 100)))
	current_biome = enemy_biome

func apply_companion_stats() -> void:
	var m = get_monster_data(active_companion)
	player_max_hp = int(m.get("max_hp", 34)) + (player_level - 1) * 2
	player_hp = min(player_hp, player_max_hp)
	if player_hp <= 0: player_hp = player_max_hp
	player_attack = int(m.get("attack", 7))
	player_skill_name = m.get("skill_name", "Leaf Pop")
	player_skill_damage = int(m.get("skill_damage", 10))
	player_cp = max(player_cp, int(caught_cp.get(active_companion, player_cp)))

func set_active_companion(name: String) -> bool:
	if name == "Spriglet" or caught_critters.has(name):
		active_companion = name
		if not team.has(name):
			if team.size() < 3: team.append(name)
			else: team[0] = name
		apply_companion_stats()
		return true
	return false

func add_to_team(name: String) -> void:
	if (name == "Spriglet" or caught_critters.has(name)) and not team.has(name):
		if team.size() < 3: team.append(name)
		else: team[team.size() - 1] = name

func get_enemy_sprite(name: String) -> String:
	return get_monster_data(name).get("sprite", "res://assets/sprites/spriglet.svg")

func register_mobile_move(direction: Vector2) -> void:
	mobile_move_vector = direction

func queue_mobile_interact() -> void:
	mobile_interact_queued = true

func consume_mobile_interact() -> bool:
	if mobile_interact_queued:
		mobile_interact_queued = false
		return true
	return false

func capture_chance() -> float:
	var hp_ratio := float(enemy_hp) / float(max(enemy_max_hp, 1))
	return clamp(0.22 + (1.0 - hp_ratio) * 0.56, 0.18, 0.82)

func try_capture() -> String:
	if meadow_orbs <= 0:
		return "No Meadow Orbs left. Visit camp or finish quests."
	meadow_orbs -= 1
	var chance := capture_chance()
	if randf() <= chance:
		if not caught_critters.has(enemy_name): caught_critters.append(enemy_name)
		caught_cp[enemy_name] = max(enemy_cp, int(caught_cp.get(enemy_name, 0)))
		add_to_team(enemy_name)
		QuestManager.on_capture(enemy_name, enemy_biome)
		return "Gotcha! %s joined your Wild Routes journal." % enemy_name
	return "%s broke free!" % enemy_name

func restock_orbs(amount: int = 1) -> void:
	meadow_orbs += amount

func win_reward() -> String:
	var exp_gain := 8 + enemy_cp / 10
	player_exp += exp_gain
	var leveled := false
	while player_exp >= player_exp_to_next:
		player_exp -= player_exp_to_next
		player_level += 1
		player_exp_to_next += 10
		player_cp += 8
		leveled = true
	apply_companion_stats()
	restock_orbs(1)
	if leveled:
		return "%s grew stronger! Rank %d route EXP gained." % [active_companion, tamer_rank]
	return "%s gained %d EXP. +1 Meadow Orb." % [active_companion, exp_gain]

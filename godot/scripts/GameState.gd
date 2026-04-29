extends Node

var player_name := "Spriglet"
var player_max_hp := 32
var player_hp := 32
var player_attack := 7
var player_skill_name := "Leaf Pop"
var player_skill_damage := 12
var player_cp := 125
var player_exp := 0
var player_exp_to_next := 20
var meadow_orbs := 3
var caught_critters: Array[String] = []
var caught_cp := {}
var active_companion := "Spriglet"
var current_biome := "Meadow"
var last_battle_message := ""
var sound_enabled := true
var mobile_move_vector := Vector2.ZERO
var mobile_interact_queued := false

var enemies := [
	{"name": "Mossbun", "biome": "Forest", "max_hp": 26, "attack": 5, "skill_name": "Moss Bump", "skill_damage": 9, "sprite": "res://assets/sprites/mossbun.svg"},
	{"name": "Bloomrat", "biome": "Meadow", "max_hp": 30, "attack": 6, "skill_name": "Petal Nip", "skill_damage": 10, "sprite": "res://assets/sprites/bloomrat.svg"},
	{"name": "Cragcub", "biome": "Mountain", "max_hp": 34, "attack": 7, "skill_name": "Pebble Pounce", "skill_damage": 12, "sprite": "res://assets/sprites/cragcub.svg"},
	{"name": "Aqualit", "biome": "River", "max_hp": 28, "attack": 6, "skill_name": "Bubble Dash", "skill_damage": 11, "sprite": "res://assets/sprites/aqualit.svg"}
]
var enemy_name := "Mossbun"
var enemy_cp := 45
var enemy_max_hp := 26
var enemy_hp := 26
var enemy_attack := 5
var enemy_skill_name := "Moss Bump"
var enemy_skill_damage := 9
var enemy_sprite := "res://assets/sprites/mossbun.svg"

var last_player_position := Vector2(410, 300)

func choose_random_enemy(biome := "") -> void:
	var pool := []
	var target_biome = biome if biome != "" else current_biome
	for enemy in enemies:
		if enemy.get("biome", "Meadow") == target_biome:
			pool.append(enemy)
	if pool.is_empty():
		pool = enemies
	var picked = pool.pick_random()
	enemy_name = picked["name"]
	enemy_max_hp = picked["max_hp"]
	enemy_attack = picked["attack"]
	enemy_skill_name = picked["skill_name"]
	enemy_skill_damage = picked["skill_damage"]
	enemy_sprite = picked["sprite"]
	enemy_cp = randi() % 140 + 45
	enemy_hp = enemy_max_hp

func reset_battle() -> void:
	player_hp = player_max_hp
	enemy_hp = enemy_max_hp

func reset_enemy() -> void:
	enemy_hp = enemy_max_hp

func heal_player(amount: int) -> void:
	player_hp = min(player_max_hp, player_hp + amount)

func damage_player(amount: int) -> void:
	player_hp = max(0, player_hp - amount)

func damage_enemy(amount: int) -> void:
	enemy_hp = max(0, enemy_hp - amount)

func gain_exp(amount: int) -> String:
	player_exp += amount
	var message := "Spriglet gained %d EXP!" % amount
	if player_exp >= player_exp_to_next:
		player_exp -= player_exp_to_next
		player_cp += 25
		player_exp_to_next += 12
		player_max_hp += 4
		player_attack += 1
		player_skill_damage += 2
		player_hp = player_max_hp
		message += " Power up! Spriglet is now CP %d." % player_cp
	return message

func try_capture() -> String:
	if meadow_orbs <= 0:
		return "No Meadow Orbs left!"
	meadow_orbs -= 1
	var hp_ratio := float(enemy_hp) / float(enemy_max_hp)
	var chance := 0.35
	if hp_ratio <= 0.25:
		chance = 0.82
	elif hp_ratio <= 0.5:
		chance = 0.62
	elif hp_ratio <= 0.75:
		chance = 0.48
	if randf() <= chance:
		if not caught_critters.has(enemy_name):
			caught_critters.append(enemy_name)
		caught_cp[enemy_name] = max(enemy_cp, caught_cp.get(enemy_name, 0))
		return "Gotcha! %s joined your meadow team." % enemy_name
	return "%s broke free!" % enemy_name

func get_enemy_sprite(name: String) -> String:
	for enemy in enemies:
		if enemy["name"] == name:
			return enemy["sprite"]
	return "res://assets/sprites/mossbun.svg"

func get_caught_cp(name: String) -> int:
	return caught_cp.get(name, 0)

func set_active_companion(name: String) -> bool:
	if name == "Spriglet" or caught_critters.has(name):
		active_companion = name
		player_name = name
		var cp_bonus = int(get_caught_cp(name) / 18) if name != "Spriglet" else 0
		player_cp = max(125, 125 + cp_bonus)
		player_attack = 7 + int(cp_bonus / 12)
		player_skill_damage = 12 + int(cp_bonus / 10)
		last_battle_message = "%s is now your active companion." % name
		return true
	return false

func restock_orbs(amount: int = 1) -> void:
	meadow_orbs = min(9, meadow_orbs + amount)

func queue_mobile_interact() -> void:
	mobile_interact_queued = true

func consume_mobile_interact() -> bool:
	if mobile_interact_queued:
		mobile_interact_queued = false
		return true
	return false

func toggle_sound() -> void:
	sound_enabled = !sound_enabled

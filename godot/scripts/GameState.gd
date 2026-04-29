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
	"Spriglet": {"type":"Meadow", "biome":"Starter", "role":"Starter companion", "max_hp":36, "attack":7, "defense":5, "speed":6, "focus":6, "cp_min":45, "cp_max":70, "skill_name":"Leaf Pop", "skill_damage":12, "trait":"Fresh Guard", "sprite":"res://assets/sprites/spriglet.svg", "description":"Your loyal starter and field partner for the Wild Routes."},
	"Surobite": {"type":"Water", "biome":"River", "role":"Heavy attacker", "max_hp":46, "attack":10, "defense":6, "speed":5, "focus":4, "cp_min":120, "cp_max":240, "skill_name":"Riptide Chomp", "skill_damage":16, "trait":"Rough current", "sprite":"res://assets/sprites/surobite.svg", "description":"A bold river predator with shark speed and crocodile strength."},
	"Karangil": {"type":"Water", "biome":"River", "role":"Coral support", "max_hp":32, "attack":6, "defense":5, "speed":7, "focus":8, "cp_min":65, "cp_max":155, "skill_name":"Coral Bubble", "skill_damage":11, "trait":"Reef shimmer", "sprite":"res://assets/sprites/karangil.svg", "description":"A tiny coral fish that glows when clean water flows through the route."},
	"Banyant": {"type":"Forest", "biome":"Forest", "role":"Rooted tank", "max_hp":44, "attack":7, "defense":9, "speed":3, "focus":6, "cp_min":95, "cp_max":205, "skill_name":"Root Guard", "skill_damage":10, "trait":"Canopy shell", "sprite":"res://assets/sprites/banyant.svg", "description":"A banyan-backed ant that protects forest paths with living roots."},
	"Audiowing": {"type":"Sound", "biome":"Forest", "role":"Status speed", "max_hp":30, "attack":8, "defense":4, "speed":10, "focus":8, "cp_min":85, "cp_max":185, "skill_name":"Echo Pulse", "skill_damage":13, "trait":"Resonance", "sprite":"res://assets/sprites/audiowing.svg", "description":"A bat-like critter that rides vibrations and confuses foes with sharp echo bursts."},
	"Mechacrab": {"type":"Tech", "biome":"Meadow", "role":"Defensive shell", "max_hp":40, "attack":7, "defense":9, "speed":3, "focus":5, "cp_min":80, "cp_max":180, "skill_name":"Keyclack Guard", "skill_damage":12, "trait":"Click armor", "sprite":"res://assets/sprites/mechacrab.svg", "description":"A clicking keyboard crab that hides under keys and snaps when disturbed."},
	"Nyanvolt": {"type":"Electric", "biome":"Meadow", "role":"Fast striker", "max_hp":34, "attack":10, "defense":4, "speed":11, "focus":6, "cp_min":95, "cp_max":210, "skill_name":"Static Pounce", "skill_damage":15, "trait":"Charged fur", "sprite":"res://assets/sprites/nyanvolt.svg", "description":"A fluffy storm cat that charges its fur before leaping at impossible speed."},
	"Wokano": {"type":"Fire", "biome":"Mountain", "role":"Burst attacker", "max_hp":36, "attack":10, "defense":5, "speed":6, "focus":8, "cp_min":100, "cp_max":220, "skill_name":"Wok Flame", "skill_damage":16, "trait":"Spice flare", "sprite":"res://assets/sprites/wokano.svg", "description":"A spicy flame spirit wearing a metal wok as armor."},
	"Kopimon": {"type":"Ghost", "biome":"Meadow", "role":"Debuff caster", "max_hp":33, "attack":7, "defense":4, "speed":6, "focus":10, "cp_min":70, "cp_max":170, "skill_name":"Caffeine Hex", "skill_damage":12, "trait":"Late brew", "sprite":"res://assets/sprites/kopimon.svg", "description":"A mischievous coffee ghost that keeps sleepy tamers awake during night surveys."},
	"Voxolem": {"type":"Stone", "biome":"Mountain", "role":"Voxel tank", "max_hp":52, "attack":8, "defense":10, "speed":2, "focus":4, "cp_min":110, "cp_max":230, "skill_name":"Block Slam", "skill_damage":14, "trait":"Rebuild", "sprite":"res://assets/sprites/voxolem.svg", "description":"A cube-built golem that rearranges its blocks to guard mountain trails."},
	"Glowsprite": {"type":"Light", "biome":"Forest", "role":"Healer support", "max_hp":31, "attack":6, "defense":4, "speed":8, "focus":10, "cp_min":75, "cp_max":165, "skill_name":"Glow Mend", "skill_damage":10, "trait":"Route lantern", "sprite":"res://assets/sprites/glowsprite.svg", "description":"A tiny route fairy that leaves sparkles over safe paths."},
	"Umbrata": {"type":"Shadow", "biome":"Mountain", "role":"Debuff attacker", "max_hp":38, "attack":9, "defense":5, "speed":7, "focus":8, "cp_min":105, "cp_max":225, "skill_name":"Night Grin", "skill_damage":15, "trait":"Vanishing shade", "sprite":"res://assets/sprites/umbrata.svg", "description":"A shadowy cave trickster with a bright grin and a habit of vanishing between rocks."},
	"Awanis": {"type":"Air", "biome":"River", "role":"Evasion speed", "max_hp":32, "attack":8, "defense":4, "speed":10, "focus":7, "cp_min":80, "cp_max":175, "skill_name":"Cloud Dash", "skill_damage":13, "trait":"Tailwind", "sprite":"res://assets/sprites/awanis.svg", "description":"A cloud-bodied pigeon that drifts over bridges and warns travelers of changing winds."}
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
	_set_enemy("Surobite")

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

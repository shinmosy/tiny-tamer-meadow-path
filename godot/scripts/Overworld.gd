extends Node2D

const WORLD_SIZE := Vector2(1600, 1100)
var player: CharacterBody2D
var npc: Node2D
var rng := RandomNumberGenerator.new()
var encounter_cooldown := 0.0
var dialogue_box: Panel
var dialogue_visible := false
var menu_panel: Panel
var menu_visible := false
var biome_label: Label
var biome_regions := {
	"Meadow": Rect2(120, 220, 460, 360),
	"Forest": Rect2(70, 620, 560, 360),
	"River": Rect2(640, 120, 330, 760),
	"Mountain": Rect2(1030, 160, 450, 620)
}

func _ready() -> void:
	rng.randomize()
	_build_map()
	_build_dialogue()
	_build_touch_controls()
	_build_game_menu()

func _process(delta: float) -> void:
	encounter_cooldown = max(0.0, encounter_cooldown - delta)
	_update_biome()
	if Input.is_action_just_pressed("interact") or GameState.consume_mobile_interact():
		_try_dialogue()
	_check_random_encounter(delta)

func _build_map() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#86d67a")
	bg.size = WORLD_SIZE
	add_child(bg)
	_add_zone("Meadow", biome_regions["Meadow"], Color("#8ee077"))
	_add_zone("Forest", biome_regions["Forest"], Color("#3aa85a"))
	_add_zone("River", biome_regions["River"], Color("#57c6ee"))
	_add_zone("Mountain", biome_regions["Mountain"], Color("#c0b284"))

	# Main adventure paths
	for rect in [Rect2(0, 500, 1600, 86), Rect2(560, 0, 82, 1100), Rect2(970, 220, 88, 620), Rect2(210, 850, 1020, 70)]:
		var p := ColorRect.new(); p.color = Color("#d6a766"); p.position = rect.position; p.size = rect.size; add_child(p)

	# River strips and bridges
	for rect in [Rect2(705, 80, 105, 800), Rect2(815, 240, 75, 620)]:
		var water := ColorRect.new(); water.color = Color("#35aee7"); water.position = rect.position; water.size = rect.size; add_child(water)
	for rect in [Rect2(670, 510, 260, 54), Rect2(702, 845, 220, 46)]:
		var bridge := ColorRect.new(); bridge.color = Color("#a87642"); bridge.position = rect.position; bridge.size = rect.size; add_child(bridge)

	# Forest trees
	for p in [Vector2(115,655),Vector2(185,715),Vector2(270,650),Vector2(355,735),Vector2(475,670),Vector2(570,760),Vector2(160,890),Vector2(310,930),Vector2(520,915),Vector2(80,820)]:
		_add_obstacle_sprite("res://assets/sprites/tree.svg", p, Vector2(0.9,0.9), Vector2(36,34), Vector2(0,24))
	# Meadow flowers/grass
	for p in [Vector2(170,290),Vector2(260,365),Vector2(350,290),Vector2(470,420),Vector2(545,285),Vector2(205,515),Vector2(430,535)]:
		_add_sprite("res://assets/sprites/flower.svg", p, Vector2(0.65,0.65))
	for x in range(150, 570, 70):
		for y in range(250, 560, 70):
			_add_sprite("res://assets/sprites/grass_patch.svg", Vector2(x,y), Vector2(0.62,0.62))
	# Mountains and rocks
	for p in [Vector2(1115,220),Vector2(1310,250),Vector2(1430,360),Vector2(1210,560),Vector2(1360,690)]:
		_add_obstacle_sprite("res://assets/sprites/mountain.svg", p, Vector2(0.8,0.8), Vector2(74,42), Vector2(0,35))
	for p in [Vector2(1045,430),Vector2(1190,745),Vector2(1470,720),Vector2(1325,485)]:
		_add_obstacle_sprite("res://assets/sprites/rock.svg", p, Vector2(0.82,0.82), Vector2(46,30), Vector2(0,6))
	_add_obstacle_sprite("res://assets/sprites/cave.svg", Vector2(1460,190), Vector2(0.9,0.9), Vector2(88,42), Vector2(0,38))

	# Labels
	_add_world_label("Meadow Fields", Vector2(210,210), 26)
	_add_world_label("Whisper Forest", Vector2(180,620), 26)
	_add_world_label("Bluebell River", Vector2(675,95), 24)
	_add_world_label("Cragpeak Trail", Vector2(1135,150), 26)

	npc = Node2D.new(); npc.position = Vector2(455, 500)
	var npc_sprite := Sprite2D.new(); npc_sprite.texture = load("res://assets/sprites/npc.svg"); npc_sprite.scale = Vector2(0.62,0.62); npc.add_child(npc_sprite); add_child(npc)

	var player_scene := load("res://scenes/Player.tscn")
	player = player_scene.instantiate(); player.position = GameState.last_player_position; add_child(player)
	var cam := Camera2D.new(); cam.enabled = true; cam.limit_left = 0; cam.limit_top = 0; cam.limit_right = int(WORLD_SIZE.x); cam.limit_bottom = int(WORLD_SIZE.y); cam.zoom = Vector2(1,1); player.add_child(cam)

	var hud := CanvasLayer.new(); hud.layer = 5; add_child(hud)
	var controls := Label.new(); controls.text = "Move: WASD/Arrows | E/Space: Interact"; controls.position = Vector2(18, 16); controls.add_theme_font_size_override("font_size", 18); hud.add_child(controls)
	biome_label = Label.new(); biome_label.position = Vector2(18, 42); biome_label.add_theme_font_size_override("font_size", 18); hud.add_child(biome_label)
	var status := Label.new(); status.text = "%s CP %d | Orbs %d | Caught %d" % [GameState.active_companion, GameState.player_cp, GameState.meadow_orbs, GameState.caught_critters.size()]; status.position = Vector2(18, 68); status.add_theme_font_size_override("font_size", 18); hud.add_child(status)
	if GameState.last_battle_message != "":
		var toast := Label.new(); toast.text = GameState.last_battle_message; toast.position = Vector2(18, 94); toast.size = Vector2(620,44); toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; toast.add_theme_font_size_override("font_size", 17); hud.add_child(toast)

func _add_zone(label: String, rect: Rect2, color: Color) -> void:
	var z := ColorRect.new(); z.color = color; z.position = rect.position; z.size = rect.size; add_child(z)

func _add_world_label(text: String, pos: Vector2, size: int) -> void:
	var label := Label.new(); label.text = text; label.position = pos; label.add_theme_font_size_override("font_size", size); label.add_theme_color_override("font_color", Color("#214026")); add_child(label)

func _add_sprite(texture_path: String, pos: Vector2, scale_value: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new(); sprite.texture = load(texture_path); sprite.position = pos; sprite.scale = scale_value; add_child(sprite); return sprite

func _add_obstacle_sprite(texture_path: String, pos: Vector2, scale_value: Vector2, collision_size: Vector2, collision_offset: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new(); body.position = pos
	var sprite := Sprite2D.new(); sprite.texture = load(texture_path); sprite.scale = scale_value; body.add_child(sprite)
	var shape := CollisionShape2D.new(); var rect := RectangleShape2D.new(); rect.size = collision_size; shape.shape = rect; shape.position = collision_offset; body.add_child(shape)
	add_child(body); return body

func _build_dialogue() -> void:
	dialogue_box = Panel.new(); dialogue_box.position = Vector2(80, 380); dialogue_box.size = Vector2(800,120); dialogue_box.visible = false; add_child(dialogue_box)
	var portrait := TextureRect.new(); portrait.texture = load("res://assets/sprites/npc.svg"); portrait.position = Vector2(18,12); portrait.size = Vector2(82,96); portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; dialogue_box.add_child(portrait)
	var name_label := Label.new(); name_label.text = "Meadow Guide"; name_label.position = Vector2(120,12); name_label.add_theme_font_size_override("font_size",20); dialogue_box.add_child(name_label)
	var label := Label.new(); label.name = "Text"; label.position = Vector2(120,42); label.size = Vector2(650,62); label.text = "This path now connects Meadow, Forest, River, and Mountain biomes. Each biome hides different critters."; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.add_theme_font_size_override("font_size",22); dialogue_box.add_child(label)

func _update_biome() -> void:
	for biome in biome_regions.keys():
		if biome_regions[biome].has_point(player.position):
			GameState.current_biome = biome
			break
	if biome_label:
		biome_label.text = "Biome: %s" % GameState.current_biome

func _try_dialogue() -> void:
	if player.position.distance_to(npc.position) < 85:
		AudioManager.play_click(); dialogue_visible = !dialogue_visible; dialogue_box.visible = dialogue_visible
	else:
		dialogue_visible = false; dialogue_box.visible = false

func _check_random_encounter(delta: float) -> void:
	if encounter_cooldown > 0.0 or dialogue_visible or menu_visible: return
	var region: Rect2 = biome_regions.get(GameState.current_biome, Rect2())
	if region.has_point(player.position) and player.velocity.length() > 1.0:
		if rng.randf() < 0.45 * delta:
			encounter_cooldown = 3.0; AudioManager.play_encounter(); get_parent().go_to_battle(GameState.current_biome)

func _is_mobile_device() -> bool:
	return DisplayServer.is_touchscreen_available() or OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios")

func _touch_button(text: String, pos: Vector2, dir: Vector2, layer: CanvasLayer) -> Button:
	var b := Button.new(); b.text = text; b.position = pos; b.size = Vector2(54,54); b.add_theme_font_size_override("font_size",22)
	b.button_down.connect(func(): GameState.mobile_move_vector = dir)
	b.button_up.connect(func(): GameState.mobile_move_vector = Vector2.ZERO)
	layer.add_child(b); return b

func _build_touch_controls() -> void:
	if not _is_mobile_device():
		return
	var layer := CanvasLayer.new(); layer.layer = 10; add_child(layer)
	_touch_button("▲", Vector2(90,360), Vector2.UP, layer); _touch_button("◀", Vector2(34,414), Vector2.LEFT, layer); _touch_button("▶", Vector2(146,414), Vector2.RIGHT, layer); _touch_button("▼", Vector2(90,468), Vector2.DOWN, layer)
	var action := Button.new(); action.text = "A"; action.position = Vector2(825,430); action.size = Vector2(74,74); action.add_theme_font_size_override("font_size",28); action.pressed.connect(func(): AudioManager.play_click(); GameState.queue_mobile_interact()); layer.add_child(action)

func _menu_button(text: String) -> Button:
	var b := Button.new(); b.text = text; b.custom_minimum_size = Vector2(220,46); b.add_theme_font_size_override("font_size",19); return b

func _build_game_menu() -> void:
	var layer := CanvasLayer.new(); layer.layer = 9; add_child(layer)
	var open := Button.new(); open.text = "Menu"; open.position = Vector2(825,20); open.size = Vector2(92,42); open.pressed.connect(func(): AudioManager.play_click(); menu_visible = !menu_visible; menu_panel.visible = menu_visible; GameState.mobile_move_vector = Vector2.ZERO); layer.add_child(open)
	menu_panel = Panel.new(); menu_panel.position = Vector2(330,105); menu_panel.size = Vector2(300,315); menu_panel.visible = false; layer.add_child(menu_panel)
	var box := VBoxContainer.new(); box.position = Vector2(38,26); box.size = Vector2(224,260); box.add_theme_constant_override("separation",10); menu_panel.add_child(box)
	var title := Label.new(); title.text = "Game Menu"; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",28); box.add_child(title)
	var dex := _menu_button("Meadow Dex"); dex.pressed.connect(func(): AudioManager.play_click(); get_parent().go_to_dex()); box.add_child(dex)
	var opt := _menu_button("Options"); opt.pressed.connect(func(): AudioManager.play_click(); get_parent().go_to_options()); box.add_child(opt)
	var title_btn := _menu_button("Back to Title"); title_btn.pressed.connect(func(): AudioManager.play_click(); get_parent().go_to_title()); box.add_child(title_btn)
	var resume := _menu_button("Resume"); resume.pressed.connect(func(): AudioManager.play_click(); menu_visible = false; menu_panel.visible = false); box.add_child(resume)

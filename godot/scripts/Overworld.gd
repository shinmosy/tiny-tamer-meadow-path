extends Node2D

const WORLD_SIZE := Vector2(2500, 1500)
const PLAYER_SCENE := preload("res://scenes/Player.tscn")

var player: CharacterBody2D
var rng := RandomNumberGenerator.new()
var encounter_cooldown := 0.0
var dialogue_visible := false
var menu_visible := false
var menu_panel: Panel
var dialogue_panel: Panel
var dialogue_portrait: TextureRect
var dialogue_name: Label
var dialogue_text: Label
var hud_quest: Label
var hud_status: Label
var biome_badge: Label
var toast_label: Label
var npcs := []
var encounter_zones := []
var tall_grass_zones := []

func _ready() -> void:
	rng.randomize()
	_build_world()
	_spawn_player()
	_build_npcs()
	_build_hud()
	_build_dialogue()
	_build_touch_controls()
	_build_game_menu()
	_update_hud()
	if GameState.last_battle_message != "":
		_show_toast(GameState.last_battle_message)
		GameState.last_battle_message = ""

func _process(delta: float) -> void:
	if encounter_cooldown > 0.0:
		encounter_cooldown -= delta
	_update_biome()
	_update_hud()
	if Input.is_action_just_pressed("interact") or GameState.consume_mobile_interact():
		_try_interact()
	_check_random_encounter(delta)

func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.position = SaveManager.loaded_position if SaveManager.has_save() else Vector2(230, 250)
	add_child(player)
	var cam := Camera2D.new()
	cam.enabled = true
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 5.0
	cam.limit_left = 0; cam.limit_top = 0; cam.limit_right = int(WORLD_SIZE.x); cam.limit_bottom = int(WORLD_SIZE.y)
	player.add_child(cam)

func _build_world() -> void:
	var base := ColorRect.new(); base.color = Color("#a9d98a"); base.position = Vector2.ZERO; base.size = WORLD_SIZE; add_child(base)
	_draw_region(Rect2(80, 80, 520, 440), Color("#b9e89a"), "Meadow Camp", Vector2(170, 125))
	_draw_region(Rect2(520, 210, 420, 360), Color("#bde486"), "Bloomtrail Path", Vector2(620, 255))
	_draw_region(Rect2(870, 120, 420, 520), Color("#7fbd67"), "Whisperwood Gate", Vector2(930, 165))
	_draw_region(Rect2(1160, 160, 520, 640), Color("#5f9d57"), "Whisper Forest", Vector2(1260, 210))
	_draw_region(Rect2(1480, 710, 680, 380), Color("#8bc7d9"), "Bluebell River Crossing", Vector2(1580, 770))
	_draw_region(Rect2(1880, 210, 500, 500), Color("#b7a37c"), "Cragpeak Foothill", Vector2(1960, 265))
	_draw_region(Rect2(2210, 550, 250, 230), Color("#897a68"), "Cragpeak Cave Gate", Vector2(2240, 600))
	_draw_path([Vector2(260,300), Vector2(560,340), Vector2(760,390), Vector2(980,360), Vector2(1260,420), Vector2(1480,660), Vector2(1720,870), Vector2(1990,650), Vector2(2290,660)])
	_draw_river()
	_draw_landmarks()
	_build_encounter_zones()

func _draw_region(rect: Rect2, color: Color, title: String, label_pos: Vector2) -> void:
	var r := ColorRect.new(); r.color = color; r.position = rect.position; r.size = rect.size; add_child(r)
	var l := Label.new(); l.text = title; l.position = label_pos; l.size = Vector2(330, 28); l.add_theme_font_size_override("font_size", 22); l.add_theme_color_override("font_color", Color("#203528")); add_child(l)

func _draw_path(points: Array) -> void:
	for i in range(points.size() - 1):
		var a: Vector2 = points[i]; var b: Vector2 = points[i + 1]
		var seg := ColorRect.new(); seg.color = Color("#d8ad66"); var mid=(a+b)/2; var len=a.distance_to(b)
		seg.position = mid - Vector2(len/2, 24); seg.size = Vector2(len, 48); seg.rotation = (b-a).angle(); add_child(seg)

func _draw_river() -> void:
	for i in range(7):
		var water := ColorRect.new(); water.color = Color("#55aee0", 0.88); water.position = Vector2(1510 + i * 86, 650 + sin(i) * 35); water.size = Vector2(74, 500); water.rotation = 0.13; add_child(water)
	var bridge := ColorRect.new(); bridge.color = Color("#9b6c3d"); bridge.position = Vector2(1700, 795); bridge.size = Vector2(245, 70); add_child(bridge)
	for i in range(5):
		var plank := ColorRect.new(); plank.color = Color("#c48b55"); plank.position = Vector2(1710+i*45, 800); plank.size = Vector2(22, 60); add_child(plank)

func _sprite(path: String, pos: Vector2, size: Vector2) -> TextureRect:
	var s := TextureRect.new(); s.texture = load(path); s.position = pos; s.size = size; s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; add_child(s); return s

func _draw_landmarks() -> void:
	# Camp
	for p in [Vector2(140,360), Vector2(210,380), Vector2(330,150), Vector2(450,420)]: _sprite("res://assets/sprites/flower.svg", p, Vector2(50,50))
	var tent := ColorRect.new(); tent.color = Color("#f2cf77"); tent.position = Vector2(185,175); tent.size = Vector2(130,85); add_child(tent)
	var sign := Label.new(); sign.text = "Camp"; sign.position = Vector2(205, 195); sign.add_theme_font_size_override("font_size", 24); sign.add_theme_color_override("font_color", UITheme.INK); add_child(sign)
	# Route ornaments
	for p in [Vector2(610,250), Vector2(690,455), Vector2(810,330), Vector2(920,480)]: _sprite("res://assets/sprites/grass_patch.svg", p, Vector2(95,75))
	# Forest gates and dense trees
	for p in [Vector2(880,230), Vector2(1030,230), Vector2(1160,270), Vector2(1280,260), Vector2(1410,300), Vector2(1540,360), Vector2(1220,560), Vector2(1460,610)]: _sprite("res://assets/sprites/tree.svg", p, Vector2(120,140))
	for p in [Vector2(1340,500), Vector2(1560,520), Vector2(1190,700)]: _sprite("res://assets/sprites/gloomcap.svg", p, Vector2(54,54))
	# River reeds/lily hints
	for p in [Vector2(1590,840), Vector2(1760,940), Vector2(1930,805)]: _sprite("res://assets/sprites/lilypadle.svg", p, Vector2(48,48))
	# Mountain/cave
	for p in [Vector2(1930,355), Vector2(2070,410), Vector2(2180,300), Vector2(1970,560)]: _sprite("res://assets/sprites/mountain.svg", p, Vector2(140,120))
	_sprite("res://assets/sprites/cave.svg", Vector2(2240,635), Vector2(170,120))

func _build_encounter_zones() -> void:
	encounter_zones = [
		{"name":"Meadow", "rect":Rect2(560,245,360,310), "chance":0.55},
		{"name":"Forest", "rect":Rect2(1120,260,520,500), "chance":0.85},
		{"name":"River", "rect":Rect2(1520,720,600,330), "chance":0.72},
		{"name":"Mountain", "rect":Rect2(1880,300,480,390), "chance":0.78}
	]
	for z in encounter_zones:
		var rect: Rect2 = z["rect"]
		var grass := ColorRect.new(); grass.color = Color("#477e45", 0.28); grass.position = rect.position; grass.size = rect.size; add_child(grass)

func _npc(name: String, role: String, pos: Vector2, color: Color) -> Dictionary:
	var body := Node2D.new(); body.position = pos; add_child(body)
	var sprite := TextureRect.new(); sprite.texture = load("res://assets/sprites/npc.svg"); sprite.position=Vector2(-32,-55); sprite.size=Vector2(64,74); sprite.modulate=color; sprite.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; body.add_child(sprite)
	var tag := Label.new(); tag.text = name; tag.position = Vector2(-80, 24); tag.size=Vector2(160,22); tag.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; tag.add_theme_font_size_override("font_size",14); tag.add_theme_color_override("font_color", UITheme.INK); body.add_child(tag)
	return {"name":name, "role":role, "node":body, "color":color}

func _build_npcs() -> void:
	npcs = [
		_npc("Meadow Guide", "guide", Vector2(330,285), Color("#b6f0ad")),
		_npc("Camp Keeper", "keeper", Vector2(210,365), Color("#ffd184")),
		_npc("Forest Scout", "forest", Vector2(1035,355), Color("#7fd487")),
		_npc("River Researcher", "river", Vector2(1690,750), Color("#85caff")),
		_npc("Cragpeak Ranger", "ranger", Vector2(2215,610), Color("#d6a66d"))
	]

func _build_hud() -> void:
	var layer := CanvasLayer.new(); layer.layer = 8; add_child(layer)
	var panel := Panel.new(); panel.position=Vector2(18,16); panel.size=Vector2(410,112); panel.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#fff3d7", .93), Color("#2f5d35"), 16)); layer.add_child(panel)
	biome_badge = Label.new(); biome_badge.position=Vector2(20,12); biome_badge.size=Vector2(370,24); biome_badge.add_theme_font_size_override("font_size",18); biome_badge.add_theme_color_override("font_color", UITheme.INK); panel.add_child(biome_badge)
	hud_status = Label.new(); hud_status.position=Vector2(20,40); hud_status.size=Vector2(370,24); hud_status.add_theme_font_size_override("font_size",16); hud_status.add_theme_color_override("font_color", Color("#456145")); panel.add_child(hud_status)
	hud_quest = Label.new(); hud_quest.position=Vector2(20,66); hud_quest.size=Vector2(370,38); hud_quest.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; hud_quest.add_theme_font_size_override("font_size",14); hud_quest.add_theme_color_override("font_color", Color("#5e4728")); panel.add_child(hud_quest)
	toast_label = Label.new(); toast_label.position=Vector2(260, 470); toast_label.size=Vector2(440, 36); toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; toast_label.add_theme_font_size_override("font_size",18); toast_label.add_theme_color_override("font_color", Color("#fff5d8")); layer.add_child(toast_label)

func _update_hud() -> void:
	biome_badge.text = "Route: %s" % GameState.current_biome
	hud_status.text = "%s CP %d | Orbs x%d | Rank %d" % [GameState.active_companion, GameState.player_cp, GameState.meadow_orbs, GameState.tamer_rank]
	hud_quest.text = QuestManager.progress_text()

func _update_biome() -> void:
	var p := player.position
	var current := "Meadow"
	if Rect2(1120,260,520,500).has_point(p): current = "Forest"
	elif Rect2(1520,700,650,380).has_point(p): current = "River"
	elif Rect2(1880,260,540,520).has_point(p): current = "Mountain"
	elif Rect2(2210,550,250,230).has_point(p): current = "Cragpeak Cave Gate"
	GameState.current_biome = current
	if current == "Cragpeak Cave Gate": QuestManager.on_reach_area(current)

func _build_dialogue() -> void:
	var layer := CanvasLayer.new(); layer.layer = 11; add_child(layer)
	dialogue_panel = Panel.new(); dialogue_panel.position=Vector2(70,348); dialogue_panel.size=Vector2(820,150); dialogue_panel.visible=false; dialogue_panel.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#fff0cf", .98), Color("#2f5d35"), 18)); layer.add_child(dialogue_panel)
	dialogue_portrait = TextureRect.new(); dialogue_portrait.position=Vector2(18,18); dialogue_portrait.size=Vector2(96,96); dialogue_portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; dialogue_panel.add_child(dialogue_portrait)
	dialogue_name = Label.new(); dialogue_name.position=Vector2(130,18); dialogue_name.size=Vector2(640,26); dialogue_name.add_theme_font_size_override("font_size",22); dialogue_name.add_theme_color_override("font_color", UITheme.INK); dialogue_panel.add_child(dialogue_name)
	dialogue_text = Label.new(); dialogue_text.position=Vector2(130,52); dialogue_text.size=Vector2(650,75); dialogue_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; dialogue_text.add_theme_font_size_override("font_size",18); dialogue_text.add_theme_color_override("font_color", Color("#4b422f")); dialogue_panel.add_child(dialogue_text)

func _try_interact() -> void:
	if dialogue_visible:
		dialogue_panel.visible=false; dialogue_visible=false; SaveManager.save_game(player.position); return
	for npc in npcs:
		if player.position.distance_to(npc["node"].position) < 150:
			_show_npc_dialogue(npc); return
	_show_toast("No one nearby. Follow the route markers.")

func _show_npc_dialogue(npc: Dictionary) -> void:
	AudioManager.play_click(); dialogue_visible=true; dialogue_panel.visible=true
	dialogue_portrait.texture = load("res://assets/sprites/npc.svg"); dialogue_portrait.modulate = npc["color"]
	dialogue_name.text = npc["name"]
	var role = npc["role"]
	if role == "guide":
		QuestManager.mark_talked_guide()
		dialogue_text.text = "Your field journal starts here. Catch one wild critter on Bloomtrail, then return stronger. The Wild Routes remember prepared tamers."
	elif role == "keeper":
		GameState.player_hp = GameState.player_max_hp; GameState.meadow_orbs += 1
		dialogue_text.text = "Rest by camp. I patched up your companion and packed one extra Meadow Orb."
	elif role == "forest":
		dialogue_text.text = "Mossbun hides where the grass turns dark. If your quest says Forest Survey, search Whisper Forest beyond the gate."
	elif role == "river":
		dialogue_text.text = "Aqualit leaves bubbles near Bluebell River. Weaken it first, then throw calmly."
	else:
		dialogue_text.text = "Cragpeak Cave is a trial gate. Finish your route notes before challenging what waits inside."
	SaveManager.save_game(player.position)

func _check_random_encounter(delta: float) -> void:
	if encounter_cooldown > 0.0 or dialogue_visible or menu_visible: return
	if player.velocity.length() < 1.0: return
	for z in encounter_zones:
		if z["rect"].has_point(player.position) and rng.randf() < 0.006 * float(z["chance"]):
			encounter_cooldown=3.0; AudioManager.play_encounter(); SaveManager.save_game(player.position); get_parent().go_to_battle(z["name"]); return

func _show_toast(text: String) -> void:
	toast_label.text = text
	var tw := create_tween(); toast_label.modulate.a = 1; tw.tween_property(toast_label, "modulate:a", 0.0, 3.0)

func _build_touch_controls() -> void:
	if not SettingsManager.should_show_touch_controls(): return
	var layer := CanvasLayer.new(); layer.layer=10; add_child(layer)
	for spec in [["▲",Vector2(90,360),Vector2.UP],["◀",Vector2(34,414),Vector2.LEFT],["▶",Vector2(146,414),Vector2.RIGHT],["▼",Vector2(90,468),Vector2.DOWN]]:
		var b := Button.new(); b.text=spec[0]; b.position=spec[1]; b.size=Vector2(54,54); b.button_down.connect(func(d=spec[2]): GameState.mobile_move_vector=d); b.button_up.connect(func(): GameState.mobile_move_vector=Vector2.ZERO); layer.add_child(b)
	var a := Button.new(); a.text="A"; a.position=Vector2(825,430); a.size=Vector2(74,74); a.pressed.connect(func(): GameState.queue_mobile_interact()); layer.add_child(a)

func _menu_button(text: String) -> Button:
	var b:=Button.new(); b.text=text; b.custom_minimum_size=Vector2(220,42); b.add_theme_font_size_override("font_size",18); return b

func _build_game_menu() -> void:
	var layer := CanvasLayer.new(); layer.layer=9; add_child(layer)
	var open := Button.new(); open.text="Menu"; open.position=Vector2(835,18); open.size=Vector2(90,42); open.pressed.connect(func(): menu_visible=!menu_visible; menu_panel.visible=menu_visible; GameState.mobile_move_vector=Vector2.ZERO); layer.add_child(open)
	menu_panel = Panel.new(); menu_panel.position=Vector2(330,82); menu_panel.size=Vector2(300,375); menu_panel.visible=false; menu_panel.add_theme_stylebox_override("panel", UITheme.panel_style()); layer.add_child(menu_panel)
	var box := VBoxContainer.new(); box.position=Vector2(40,28); box.size=Vector2(220,320); box.add_theme_constant_override("separation",8); menu_panel.add_child(box)
	var resume=_menu_button("Resume"); resume.pressed.connect(func(): menu_visible=false; menu_panel.visible=false); box.add_child(resume)
	var dex=_menu_button("Meadow Dex"); dex.pressed.connect(func(): SaveManager.save_game(player.position); get_parent().go_to_dex()); box.add_child(dex)
	var save=_menu_button("Save Game"); save.pressed.connect(func(): SaveManager.save_game(player.position); _show_toast("Game saved.")); box.add_child(save)
	var opt=_menu_button("Options"); opt.pressed.connect(func(): SaveManager.save_game(player.position); get_parent().go_to_options()); box.add_child(opt)
	var title=_menu_button("Return to Title"); title.pressed.connect(func(): SaveManager.save_game(player.position); get_parent().go_to_title()); box.add_child(title)

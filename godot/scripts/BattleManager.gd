extends Control

var player_mon: TextureRect
var enemy_mon: TextureRect
var player_card: Panel
var enemy_card: Panel
var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_info: Label
var enemy_info: Label
var battle_log: Label
var command_box: VBoxContainer
var submenu_box: VBoxContainer
var action_locked := false
var player_status := "Ready"
var enemy_status := "Ready"

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	GameState.apply_companion_stats()
	_build_battle()
	_update_cards("A wild %s appeared!" % GameState.enemy_name)

func _bg_color() -> Color:
	match GameState.enemy_biome:
		"Forest": return Color("#426f45")
		"River": return Color("#4d9cc8")
		"Mountain": return Color("#9b8060")
		"Boss": return Color("#55405a")
		_: return Color("#8bcf7b")

func _build_battle() -> void:
	var bg := ColorRect.new(); bg.color = _bg_color(); bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var horizon := ColorRect.new(); horizon.color = Color("#fff0b8", 0.18); horizon.position=Vector2(0,0); horizon.size=Vector2(960,245); add_child(horizon)
	var ground1 := ColorRect.new(); ground1.color = Color("#203528", 0.12); ground1.position=Vector2(115,370); ground1.size=Vector2(245,42); add_child(ground1)
	var ground2 := ColorRect.new(); ground2.color = Color("#203528", 0.12); ground2.position=Vector2(635,184); ground2.size=Vector2(230,40); add_child(ground2)

	enemy_card = _status_card(Vector2(30,28), true); add_child(enemy_card)
	player_card = _status_card(Vector2(590,315), false); add_child(player_card)

	player_mon = TextureRect.new(); player_mon.texture = load(GameState.get_enemy_sprite(GameState.active_companion)); player_mon.position=Vector2(120,245); player_mon.size=Vector2(190,190); player_mon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; add_child(player_mon)
	enemy_mon = TextureRect.new(); enemy_mon.texture = load(GameState.enemy_sprite); enemy_mon.position=Vector2(635,65); enemy_mon.size=Vector2(175,175); enemy_mon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; add_child(enemy_mon)
	_start_idle(player_mon, 7, 1.2); _start_idle(enemy_mon, -6, 1.15)

	var log_panel := Panel.new(); log_panel.position=Vector2(28,410); log_panel.size=Vector2(555,108); log_panel.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#fff1cf", .96), Color("#2f5d35"), 16)); add_child(log_panel)
	battle_log = Label.new(); battle_log.position=Vector2(18,16); battle_log.size=Vector2(518,76); battle_log.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; battle_log.add_theme_font_size_override("font_size",19); battle_log.add_theme_color_override("font_color", UITheme.INK); log_panel.add_child(battle_log)

	var menu_panel := Panel.new(); menu_panel.position=Vector2(610,410); menu_panel.size=Vector2(320,108); menu_panel.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#fff6da", .96), Color("#2f5d35"), 16)); add_child(menu_panel)
	command_box = VBoxContainer.new(); command_box.position=Vector2(18,12); command_box.size=Vector2(135,86); command_box.add_theme_constant_override("separation", 6); menu_panel.add_child(command_box)
	submenu_box = VBoxContainer.new(); submenu_box.position=Vector2(165,12); submenu_box.size=Vector2(135,86); submenu_box.add_theme_constant_override("separation", 6); menu_panel.add_child(submenu_box)
	_show_commands()

func _status_card(pos: Vector2, enemy: bool) -> Panel:
	var p := Panel.new(); p.position=pos; p.size=Vector2(335,90); p.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#fff2cf", .95), Color("#24452d"), 16))
	var info := Label.new(); info.position=Vector2(16,10); info.size=Vector2(300,26); info.add_theme_font_size_override("font_size",18); info.add_theme_color_override("font_color", UITheme.INK); p.add_child(info)
	var bar := ProgressBar.new(); bar.position=Vector2(16,42); bar.size=Vector2(300,18); bar.show_percentage=false; p.add_child(bar)
	var status := Label.new(); status.name="Status"; status.position=Vector2(16,63); status.size=Vector2(300,20); status.add_theme_font_size_override("font_size",13); status.add_theme_color_override("font_color", Color("#57614d")); p.add_child(status)
	if enemy:
		enemy_info=info; enemy_hp_bar=bar
	else:
		player_info=info; player_hp_bar=bar
	return p

func _button(text: String, cb: Callable) -> Button:
	var b:=Button.new(); b.text=text; b.custom_minimum_size=Vector2(130,26); b.add_theme_font_size_override("font_size",14); b.add_theme_color_override("font_color", UITheme.INK); b.add_theme_stylebox_override("normal", UITheme.button_style(Color("#f3d58a"), Color("#2f5d35"))); b.pressed.connect(cb); return b

func _clear_box(box: VBoxContainer) -> void:
	for c in box.get_children(): c.queue_free()

func _show_commands() -> void:
	_clear_box(command_box); _clear_box(submenu_box)
	command_box.add_child(_button("Fight", _show_fight))
	command_box.add_child(_button("Team", _show_team))
	command_box.add_child(_button("Bag", _show_bag))
	submenu_box.add_child(_button("Capture", _on_capture))
	submenu_box.add_child(_button("Run", _on_run))

func _show_fight() -> void:
	_clear_box(submenu_box)
	submenu_box.add_child(_button("Tackle", func(): _player_move("Tackle", GameState.player_attack, "Meadow", "basic")))
	submenu_box.add_child(_button(GameState.player_skill_name, func(): _player_move(GameState.player_skill_name, GameState.player_skill_damage, GameState.get_monster_data(GameState.active_companion).get("type","Meadow"), "skill")))
	submenu_box.add_child(_button("Guard", _guard))
	submenu_box.add_child(_button("Back", _show_commands))

func _show_team() -> void:
	_clear_box(submenu_box)
	for name in GameState.team:
		submenu_box.add_child(_button(name, func(n=name): _switch_to(n)))
	submenu_box.add_child(_button("Back", _show_commands))

func _show_bag() -> void:
	_clear_box(submenu_box)
	submenu_box.add_child(_button("Heal Berry", _use_heal))
	submenu_box.add_child(_button("Guard Bark", _guard))
	submenu_box.add_child(_button("Back", _show_commands))
	battle_log.text = "Bag: Heal Berry restores 15 HP. Guard Bark reduces next hit."

func _switch_to(name: String) -> void:
	if action_locked: return
	if GameState.set_active_companion(name):
		player_mon.texture = load(GameState.get_enemy_sprite(GameState.active_companion))
		_update_cards("Go, %s!" % name)
		_enemy_turn()

func _use_heal() -> void:
	if action_locked: return
	GameState.player_hp = min(GameState.player_max_hp, GameState.player_hp + 15)
	AudioManager.play_heal(); _update_cards("%s used Heal Berry. +15 HP." % GameState.active_companion)
	_enemy_turn()

func _guard() -> void:
	if action_locked: return
	player_status = "Guarded"
	_update_cards("%s braced behind a field guard." % GameState.active_companion)
	_enemy_turn()

func _type_multiplier(move_type: String, target_type: String) -> float:
	var strong := {"Meadow":"Water", "Water":"Fire", "Fire":"Forest", "Forest":"Electric", "Electric":"Air", "Air":"Sound", "Sound":"Ghost", "Ghost":"Light", "Light":"Shadow", "Shadow":"Tech", "Tech":"Stone", "Stone":"Water"}
	if strong.get(move_type, "") == target_type: return 1.25
	if strong.get(target_type, "") == move_type: return 0.8
	return 1.0

func _effect_text(mult: float) -> String:
	if mult > 1.0: return " Super effective!"
	if mult < 1.0: return " Not very effective..."
	return ""

func _player_move(move_name: String, power: int, move_type: String, kind: String) -> void:
	if action_locked: return
	action_locked = true
	var mult := _type_multiplier(move_type, GameState.enemy_type)
	var dmg: int = max(1, int(power * mult) + randi_range(-1, 2))
	GameState.enemy_hp = max(0, GameState.enemy_hp - dmg)
	AudioManager.play_hit(); _lunge(player_mon, Vector2(35,-18)); _shake(enemy_mon)
	_update_cards("%s used %s. %d damage.%s" % [GameState.active_companion, move_name, dmg, _effect_text(mult)])
	await get_tree().create_timer(0.65).timeout
	if GameState.enemy_hp <= 0:
		_win_battle(); return
	action_locked = false
	_enemy_turn()

func _enemy_turn() -> void:
	action_locked = true
	await get_tree().create_timer(0.55).timeout
	var enemy_type := GameState.enemy_type
	var player_type: String = str(GameState.get_monster_data(GameState.active_companion).get("type", "Meadow"))
	var use_skill := GameState.enemy_hp < GameState.enemy_max_hp * 0.45 or randf() < 0.55
	var power := GameState.enemy_skill_damage if use_skill else GameState.enemy_attack
	var move := GameState.enemy_skill_name if use_skill else "Wild Tackle"
	var mult := _type_multiplier(enemy_type, player_type)
	var dmg: int = max(1, int(power * mult) + randi_range(-1, 2))
	if player_status == "Guarded":
		dmg = int(max(1, dmg * 0.55)); player_status = "Ready"
	GameState.player_hp = max(0, GameState.player_hp - dmg)
	AudioManager.play_hit(); _lunge(enemy_mon, Vector2(-35,18)); _shake(player_mon)
	_update_cards("%s used %s. %d damage.%s" % [GameState.enemy_name, move, dmg, _effect_text(mult)])
	await get_tree().create_timer(0.65).timeout
	if GameState.player_hp <= 0:
		_defeat(); return
	action_locked = false
	_show_commands()

func _on_capture() -> void:
	if action_locked: return
	action_locked = true
	AudioManager.play_throw(); _flash(Color("#fff6a8", .36))
	var result := GameState.try_capture()
	_update_cards(result)
	await get_tree().create_timer(1.0).timeout
	if result.begins_with("Gotcha"):
		GameState.last_battle_message = result
		SaveManager.save_game()
		get_parent().go_to_overworld(true)
	else:
		action_locked = false
		_enemy_turn()

func _on_run() -> void:
	GameState.last_battle_message = "You returned to the route safely."
	SaveManager.save_game()
	get_parent().go_to_overworld(true)

func _win_battle() -> void:
	var msg := GameState.win_reward()
	GameState.last_battle_message = "%s defeated! %s" % [GameState.enemy_name, msg]
	_update_cards(GameState.last_battle_message)
	SaveManager.save_game()
	await get_tree().create_timer(1.0).timeout
	get_parent().go_to_overworld(true)

func _defeat() -> void:
	GameState.player_hp = GameState.player_max_hp
	GameState.last_battle_message = "%s fainted. Camp Keeper helped you recover." % GameState.active_companion
	SaveManager.save_game()
	await get_tree().create_timer(1.0).timeout
	get_parent().go_to_overworld(true)

func _update_cards(text: String) -> void:
	battle_log.text = text
	player_info.text = "%s CP %d  %s" % [GameState.active_companion, GameState.player_cp, GameState.get_monster_data(GameState.active_companion).get("type","Meadow")]
	enemy_info.text = "%s CP %d  %s" % [GameState.enemy_name, GameState.enemy_cp, GameState.enemy_type]
	player_hp_bar.max_value = GameState.player_max_hp; player_hp_bar.value = GameState.player_hp
	enemy_hp_bar.max_value = GameState.enemy_max_hp; enemy_hp_bar.value = GameState.enemy_hp
	player_card.get_node("Status").text = "HP %d/%d | %s" % [GameState.player_hp, GameState.player_max_hp, player_status]
	enemy_card.get_node("Status").text = "HP %d/%d | %s biome" % [GameState.enemy_hp, GameState.enemy_max_hp, GameState.enemy_biome]

func _start_idle(target: Control, amount: float, duration: float) -> void:
	var start_y := target.position.y
	var t := create_tween().set_loops()
	t.tween_property(target, "position:y", start_y + amount, duration).set_trans(Tween.TRANS_SINE)
	t.tween_property(target, "position:y", start_y, duration).set_trans(Tween.TRANS_SINE)

func _lunge(target: Control, offset: Vector2) -> void:
	var start := target.position
	var t := create_tween(); t.tween_property(target, "position", start + offset, 0.12); t.tween_property(target, "position", start, 0.16)

func _shake(target: Control) -> void:
	var start := target.position
	var t := create_tween()
	for i in range(4): t.tween_property(target, "position:x", start.x + (6 if i % 2 == 0 else -6), 0.045)
	t.tween_property(target, "position", start, 0.05)

func _flash(color: Color) -> void:
	var r := ColorRect.new(); r.color = color; r.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(r)
	var t := create_tween(); t.tween_property(r, "color:a", 0.0, 0.35); t.finished.connect(func(): r.queue_free())

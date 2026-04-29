extends Control

var log_label: Label
var player_hp_label: Label
var enemy_hp_label: Label
var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_mon: TextureRect
var enemy_mon: TextureRect
var flash_overlay: ColorRect
var buttons: Array[Button] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_update_labels("A wild %s appeared!" % GameState.enemy_name)


func _create_stylebox(bg_color: Color, radius: int = 12) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.shadow_color = Color(0, 0, 0, 0.15)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(0, 2)
	return sb

func _style_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", _create_stylebox(Color("#ffffff")))
	btn.add_theme_stylebox_override("hover", _create_stylebox(Color("#f4f4f4")))
	btn.add_theme_stylebox_override("pressed", _create_stylebox(Color("#e0e0e0")))
	btn.add_theme_stylebox_override("disabled", _create_stylebox(Color("#cccccc")))
	btn.add_theme_color_override("font_color", Color("#333333"))
	btn.add_theme_color_override("font_hover_color", Color("#111111"))
	btn.add_theme_color_override("font_pressed_color", Color("#000000"))
	btn.add_theme_color_override("font_disabled_color", Color("#888888"))
	btn.add_theme_font_size_override("font_size", 18)

func _style_hp_bar(bar: ProgressBar, fill_color: Color) -> void:
	bar.add_theme_stylebox_override("background", _create_stylebox(Color("#444444", 0.6), 8))
	bar.add_theme_stylebox_override("fill", _create_stylebox(fill_color, 8))

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#bde7ff")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var ground_left := ColorRect.new()
	ground_left.color = Color("#7ccf70")
	ground_left.position = Vector2(105, 332)
	ground_left.size = Vector2(240, 38)
	add_child(ground_left)

	var ground_right := ColorRect.new()
	ground_right.color = Color("#7ccf70")
	ground_right.position = Vector2(642, 222)
	ground_right.size = Vector2(240, 38)
	add_child(ground_right)

	player_mon = TextureRect.new()
	var companion_sprite := "res://assets/sprites/spriglet.svg" if GameState.active_companion == "Spriglet" else GameState.get_enemy_sprite(GameState.active_companion)
	player_mon.texture = load(companion_sprite)
	player_mon.position = Vector2(120, 210)
	player_mon.size = Vector2(190, 155)
	player_mon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(player_mon)

	enemy_mon = TextureRect.new()
	enemy_mon.texture = load(GameState.enemy_sprite)
	enemy_mon.position = Vector2(660, 92)
	enemy_mon.size = Vector2(180, 150)
	enemy_mon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(enemy_mon)
	_start_idle_motion(player_mon, 7, 1.3)
	_start_idle_motion(enemy_mon, -6, 1.1)

	var player_name := Label.new()
	player_name.text = "%s CP %d  |  Orbs: %d" % [GameState.active_companion, GameState.player_cp, GameState.meadow_orbs]
	player_name.position = Vector2(115, 230)
	player_name.add_theme_font_size_override("font_size", 24)
	add_child(player_name)

	player_hp_label = Label.new()
	player_hp_label.position = Vector2(145, 360)
	player_hp_label.add_theme_font_size_override("font_size", 22)
	add_child(player_hp_label)

	player_hp_bar = ProgressBar.new()
	player_hp_bar.position = Vector2(145, 388)
	player_hp_bar.size = Vector2(185, 18)
	player_hp_bar.max_value = GameState.player_max_hp
	player_hp_bar.show_percentage = false
	_style_hp_bar(player_hp_bar, Color("#34c759"))
	add_child(player_hp_bar)

	var enemy_name := Label.new()
	enemy_name.text = "%s CP %d" % [GameState.enemy_name, GameState.enemy_cp]
	enemy_name.position = Vector2(685, 105)
	enemy_name.add_theme_font_size_override("font_size", 24)
	add_child(enemy_name)

	enemy_hp_label = Label.new()
	enemy_hp_label.position = Vector2(685, 235)
	enemy_hp_label.add_theme_font_size_override("font_size", 22)
	add_child(enemy_hp_label)

	enemy_hp_bar = ProgressBar.new()
	enemy_hp_bar.position = Vector2(685, 263)
	enemy_hp_bar.size = Vector2(185, 18)
	enemy_hp_bar.max_value = GameState.enemy_max_hp
	enemy_hp_bar.show_percentage = false
	_style_hp_bar(enemy_hp_bar, Color("#ff3b30"))
	add_child(enemy_hp_bar)

	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", _create_stylebox(Color("#ffffff", 0.95), 16))
	panel.position = Vector2(55, 405)
	panel.size = Vector2(850, 105)
	add_child(panel)

	log_label = Label.new()
	log_label.position = Vector2(80, 420)
	log_label.size = Vector2(470, 72)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_font_size_override("font_size", 20)
	log_label.add_theme_color_override("font_color", Color("#222222"))
	add_child(log_label)

	var actions := GridContainer.new()
	actions.columns = 2
	actions.position = Vector2(610, 412)
	actions.size = Vector2(270, 90)
	add_child(actions)

	for action in ["Attack", "Skill", "Heal", "Capture", "Run"]:
		var btn := Button.new()
		btn.text = action
		btn.custom_minimum_size = Vector2(120, 34)
		_style_button(btn)
		btn.pressed.connect(_on_action.bind(action))
		buttons.append(btn)
		actions.add_child(btn)

	flash_overlay = ColorRect.new()
	flash_overlay.color = Color(1, 1, 1, 0)
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash_overlay)

func _on_action(action: String) -> void:
	_set_buttons_disabled(true)
	match action:
		"Attack":
			AudioManager.play_click()
			await _lunge(player_mon, Vector2(28, -10))
			AudioManager.play_hit()
			GameState.damage_enemy(GameState.player_attack)
			_spawn_float_text("-%d" % GameState.player_attack, enemy_mon.global_position + Vector2(90, 20), Color("#ff4d4d"))
			_shake(enemy_mon)
			_update_labels("%s used Tackle" % GameState.active_companion + " for %d damage!" % GameState.player_attack)
			await _after_player_action()
		"Skill":
			AudioManager.play_click()
			AudioManager.play_skill()
			await _flash(Color(0.65, 1.0, 0.55, 0.32))
			AudioManager.play_hit()
			GameState.damage_enemy(GameState.player_skill_damage)
			_spawn_float_text("-%d" % GameState.player_skill_damage, enemy_mon.global_position + Vector2(90, 20), Color("#42c968"))
			_shake(enemy_mon)
			_update_labels("%s used %s for %d damage!" % [GameState.active_companion, GameState.player_skill_name, GameState.player_skill_damage])
			await _after_player_action()
		"Heal":
			AudioManager.play_click()
			AudioManager.play_heal()
			GameState.heal_player(10)
			_spawn_float_text("+10", player_mon.global_position + Vector2(90, 20), Color("#40c96b"))
			_update_labels("%s recovered 10 HP!" % GameState.active_companion)
			await _after_player_action()
		"Capture":
			AudioManager.play_click()
			if GameState.meadow_orbs <= 0:
				_update_labels("No Meadow Orbs left!")
				await get_tree().create_timer(1.0).timeout
				_set_buttons_disabled(false)
				return
			var result := GameState.try_capture()
			_update_labels("You threw a Meadow Orb!\nOrbs left: %d" % GameState.meadow_orbs)
			var captured = result.begins_with("Gotcha")
			await _play_capture_anim(captured)
			if captured:
				AudioManager.play_capture()
				GameState.last_battle_message = result
				await get_tree().create_timer(1.0).timeout
				get_parent().go_to_overworld()
			else:
				_update_labels(result)
				await get_tree().create_timer(1.0).timeout
				await _after_player_action(false)
		"Run":
			AudioManager.play_click()
			_update_labels("You safely ran back to Meadow Path.")
			await get_tree().create_timer(0.7).timeout
			get_parent().go_to_overworld()

func _after_player_action(check_win: bool = true) -> void:
	_update_hp_only()
	if check_win and GameState.enemy_hp <= 0:
		var exp_message := GameState.gain_exp(12)
		GameState.restock_orbs(1)
		GameState.last_battle_message = "%s fainted! %s +1 Meadow Orb." % [GameState.enemy_name, exp_message]
		_update_labels(GameState.last_battle_message)
		await get_tree().create_timer(1.2).timeout
		get_parent().go_to_overworld()
		return
	await get_tree().create_timer(0.55).timeout
	await _lunge(enemy_mon, Vector2(-24, 12))
	AudioManager.play_hit()
	GameState.damage_player(GameState.enemy_attack)
	_spawn_float_text("-%d" % GameState.enemy_attack, player_mon.global_position + Vector2(90, 20), Color("#ff4d4d"))
	_shake(player_mon)
	_update_labels("%s used %s for %d damage!" % [GameState.enemy_name, GameState.enemy_skill_name, GameState.enemy_attack])
	_update_hp_only()
	if GameState.player_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		_update_labels("%s fainted. You rushed back and recovered." % GameState.active_companion)
		GameState.reset_battle()
		await get_tree().create_timer(1.0).timeout
		get_parent().go_to_overworld()
		return
	_set_buttons_disabled(false)

func _start_idle_motion(target: Control, amount: float, duration: float) -> void:
	var start_y := target.position.y
	var tween := create_tween().set_loops()
	tween.tween_property(target, "position:y", start_y + amount, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, "position:y", start_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _lunge(target: Control, offset: Vector2) -> void:
	var start := target.position
	var tween := create_tween()
	tween.tween_property(target, "position", start + offset, 0.08).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(target, "position", start, 0.12).set_trans(Tween.TRANS_BACK)
	await tween.finished

func _shake(target: Control) -> void:
	var start := target.position
	var tween := create_tween()
	for offset in [Vector2(8, 0), Vector2(-8, 0), Vector2(5, 0), Vector2(-5, 0), Vector2.ZERO]:
		tween.tween_property(target, "position", start + offset, 0.035)

func _flash(color: Color) -> void:
	flash_overlay.color = color
	var tween := create_tween()
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.22)
	await tween.finished

func _spawn_float_text(text: String, pos: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position", pos + Vector2(0, -42), 0.55)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.55)
	tween.finished.connect(label.queue_free)

func _update_labels(message: String) -> void:
	log_label.text = message
	_update_hp_only()

func _update_hp_only() -> void:
	player_hp_label.text = "HP: %d / %d" % [GameState.player_hp, GameState.player_max_hp]
	enemy_hp_label.text = "HP: %d / %d" % [GameState.enemy_hp, GameState.enemy_max_hp]
	player_hp_bar.value = GameState.player_hp
	enemy_hp_bar.value = GameState.enemy_hp

func _set_buttons_disabled(value: bool) -> void:
	for btn in buttons:
		btn.disabled = value

func _play_capture_anim(success: bool) -> void:
	AudioManager.play_throw()
	var orb := TextureRect.new()
	orb.texture = load("res://assets/sprites/orb.svg")
	orb.size = Vector2(40, 40)
	orb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	orb.position = player_mon.position + Vector2(50, 50)
	orb.pivot_offset = Vector2(20, 20)
	add_child(orb)

	var target_pos = enemy_mon.position + Vector2(70, 50)
	var t1 := create_tween().set_parallel(true)
	t1.tween_property(orb, "position:x", target_pos.x, 0.6).set_trans(Tween.TRANS_LINEAR)
	t1.tween_property(orb, "position:y", target_pos.y - 100, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t1.tween_property(orb, "rotation_degrees", 360.0, 0.6)
	await get_tree().create_timer(0.3).timeout
	var t2 := create_tween()
	t2.tween_property(orb, "position:y", target_pos.y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await t2.finished

	AudioManager.play_skill()
	var t3 := create_tween()
	t3.tween_property(enemy_mon, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await t3.finished
	enemy_mon.visible = false

	var ground_y = enemy_mon.position.y + 110
	var t4 := create_tween()
	t4.tween_property(orb, "position:y", ground_y, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await t4.finished

	var shakes = 3 if success else randi() % 3 + 1
	for i in range(shakes):
		await get_tree().create_timer(0.7).timeout
		var t5 := create_tween()
		t5.tween_property(orb, "rotation_degrees", 25.0, 0.08)
		t5.tween_property(orb, "rotation_degrees", -25.0, 0.16)
		t5.tween_property(orb, "rotation_degrees", 0.0, 0.08)
		AudioManager.play_click()
		await t5.finished

	await get_tree().create_timer(0.6).timeout

	if not success:
		orb.queue_free()
		enemy_mon.visible = true
		AudioManager.play_hit()
		var t6 := create_tween()
		t6.tween_property(enemy_mon, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await t6.finished
	else:
		_flash(Color(1.0, 0.9, 0.35, 0.4))
		_spawn_float_text("Gotcha!", orb.global_position + Vector2(20, -30), Color("#ffd84d"))

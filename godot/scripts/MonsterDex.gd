extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _create_stylebox(bg_color: Color, radius: int = 18) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.shadow_color = Color(0, 0, 0, 0.18)
	sb.shadow_size = 5
	sb.shadow_offset = Vector2(0, 3)
	return sb

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#dff7ff")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "Meadow Dex"
	title.position = Vector2(330, 28)
	title.size = Vector2(300, 58)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color("#1f3b57"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Captured critters and team progress"
	subtitle.position = Vector2(270, 82)
	subtitle.size = Vector2(420, 28)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("#46637a"))
	add_child(subtitle)

	var back := Button.new()
	back.text = "Back"
	back.position = Vector2(35, 35)
	back.size = Vector2(105, 42)
	back.add_theme_stylebox_override("normal", _create_stylebox(Color("#ffffff"), 14))
	back.add_theme_stylebox_override("hover", _create_stylebox(Color("#f5f5f5"), 14))
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_on_back)
	add_child(back)

	var panel := Panel.new()
	panel.position = Vector2(95, 132)
	panel.size = Vector2(770, 370)
	panel.add_theme_stylebox_override("panel", _create_stylebox(Color("#ffffff", 0.96), 24))
	add_child(panel)

	var summary := Label.new()
	summary.text = "Caught: %d  |  Orbs: %d  |  Active: %s CP %d" % [GameState.caught_critters.size(), GameState.meadow_orbs, GameState.active_companion, GameState.player_cp]
	summary.position = Vector2(130, 155)
	summary.size = Vector2(700, 32)
	summary.add_theme_font_size_override("font_size", 22)
	summary.add_theme_color_override("font_color", Color("#263238"))
	add_child(summary)

	if GameState.caught_critters.is_empty():
		_add_empty_state()
	else:
		_add_caught_cards()

func _add_empty_state() -> void:
	var label := Label.new()
	label.text = "No critters caught yet.\nGo to Practice Battle or Tall Grass, weaken a monster, then throw a Meadow Orb."
	label.position = Vector2(160, 240)
	label.size = Vector2(640, 110)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color("#607d8b"))
	add_child(label)

func _add_caught_cards() -> void:
	var x := 140
	var y := 215
	for item in GameState.caught_critters:
		var name := str(item)
		var card := Panel.new()
		card.position = Vector2(x, y)
		card.size = Vector2(210, 205)
		card.add_theme_stylebox_override("panel", _create_stylebox(Color("#f7fbff"), 18))
		add_child(card)

		var sprite := TextureRect.new()
		sprite.texture = load(GameState.get_enemy_sprite(name))
		sprite.position = Vector2(x + 42, y + 12)
		sprite.size = Vector2(126, 100)
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(sprite)

		var name_label := Label.new()
		name_label.text = name
		name_label.position = Vector2(x + 15, y + 114)
		name_label.size = Vector2(180, 28)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.add_theme_color_override("font_color", Color("#263238"))
		add_child(name_label)

		var cp_label := Label.new()
		cp_label.text = "CP %d" % GameState.get_caught_cp(name)
		cp_label.position = Vector2(x + 15, y + 140)
		cp_label.size = Vector2(180, 22)
		cp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cp_label.add_theme_font_size_override("font_size", 17)
		cp_label.add_theme_color_override("font_color", Color("#1976d2"))
		add_child(cp_label)

		var use_btn := Button.new()
		use_btn.text = "Active" if GameState.active_companion == name else "Use"
		use_btn.position = Vector2(x + 58, y + 160)
		use_btn.size = Vector2(94, 30)
		use_btn.add_theme_font_size_override("font_size", 15)
		use_btn.disabled = GameState.active_companion == name
		use_btn.pressed.connect(func():
			AudioManager.play_click()
			GameState.set_active_companion(name)
			get_parent().go_to_dex()
		)
		add_child(use_btn)

		x += 240
		if x > 620:
			x = 140
			y += 190

func _on_back() -> void:
	AudioManager.play_click()
	get_parent().go_to_title()

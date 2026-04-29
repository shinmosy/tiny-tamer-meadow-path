extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_screen()

func _style(bg: String, border: String = "#3f6b45") -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(bg)
	sb.border_color = Color(border)
	sb.border_width_left = 3
	sb.border_width_right = 3
	sb.border_width_top = 3
	sb.border_width_bottom = 5
	sb.corner_radius_top_left = 28
	sb.corner_radius_top_right = 28
	sb.corner_radius_bottom_left = 28
	sb.corner_radius_bottom_right = 28
	sb.shadow_color = Color(0,0,0,0.18)
	sb.shadow_size = 12
	return sb

func _make_button(text: String, color := "#ffffff") -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(250, 46)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color("#203828"))
	b.add_theme_color_override("font_hover_color", Color("#102016"))
	b.add_theme_color_override("font_pressed_color", Color("#102016"))
	b.add_theme_stylebox_override("normal", _style(color, "#2f5d35"))
	b.add_theme_stylebox_override("hover", _style("#e9ffe6", "#2f5d35"))
	b.add_theme_stylebox_override("pressed", _style("#c7f4bd", "#2f5d35"))
	return b

func _build_screen() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#9fe7a5")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var glow := ColorRect.new()
	glow.color = Color(1, 1, 1, 0.16)
	glow.position = Vector2(60, 42)
	glow.size = Vector2(840, 430)
	add_child(glow)

	var deco_left := TextureRect.new()
	deco_left.texture = load("res://assets/sprites/spriglet.svg")
	deco_left.position = Vector2(70, 265)
	deco_left.size = Vector2(240, 190)
	deco_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(deco_left)
	_pulse(deco_left, 8, 1.4)

	var deco_right := TextureRect.new()
	deco_right.texture = load("res://assets/sprites/mossbun.svg")
	deco_right.position = Vector2(650, 260)
	deco_right.size = Vector2(240, 195)
	deco_right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(deco_right)
	_pulse(deco_right, -7, 1.7)

	var card := PanelContainer.new()
	card.position = Vector2(305, 54)
	card.size = Vector2(350, 420)
	card.add_theme_stylebox_override("panel", _style("#f9fff3", "#356b43"))
	add_child(card)

	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 9)
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(panel)

	var title := Label.new()
	title.text = "Tiny Tamer"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#244f2f"))
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Meadow Path"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color("#4f7f4d"))
	panel.add_child(subtitle)

	var hint := Label.new()
	hint.text = "Catch tiny critters. Grow your meadow team."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(280, 44)
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color("#37533d"))
	panel.add_child(hint)

	var start := _make_button("Start Game", "#fffdf0")
	start.pressed.connect(_on_start_pressed)
	panel.add_child(start)
	var practice := _make_button("Practice Battle", "#f0fff8")
	practice.pressed.connect(_on_practice_pressed)
	panel.add_child(practice)
	var dex := _make_button("Meadow Dex", "#f2f7ff")
	dex.pressed.connect(_on_dex_pressed)
	panel.add_child(dex)
	var options := _make_button("Options", "#fff4fb")
	options.pressed.connect(_on_options_pressed)
	panel.add_child(options)

func _pulse(node: Control, amount: float, duration: float) -> void:
	var start_y := node.position.y
	var tw := create_tween().set_loops()
	tw.tween_property(node, "position:y", start_y + amount, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "position:y", start_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_start_pressed() -> void:
	AudioManager.play_click()
	get_parent().go_to_overworld()

func _on_practice_pressed() -> void:
	AudioManager.play_click()
	get_parent().go_to_practice_battle()

func _on_dex_pressed() -> void:
	AudioManager.play_click()
	get_parent().go_to_dex()

func _on_options_pressed() -> void:
	AudioManager.play_click()
	get_parent().go_to_options()

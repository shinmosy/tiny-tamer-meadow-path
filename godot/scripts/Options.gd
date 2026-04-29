extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _style(bg: String) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(bg)
	sb.border_color = Color("#315a39")
	sb.border_width_left = 3
	sb.border_width_right = 3
	sb.border_width_top = 3
	sb.border_width_bottom = 5
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	return sb

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(280, 54)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_stylebox_override("normal", _style("#ffffff"))
	return b

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#b6efb2")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var card := PanelContainer.new()
	card.position = Vector2(285, 72)
	card.size = Vector2(390, 390)
	card.add_theme_stylebox_override("panel", _style("#fafff3"))
	add_child(card)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	card.add_child(box)

	var title := Label.new()
	title.text = "Options"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color("#244f2f"))
	box.add_child(title)

	var sound := _button("Sound: %s" % ["ON" if GameState.sound_enabled else "OFF"])
	sound.pressed.connect(func():
		GameState.toggle_sound()
		AudioManager.play_click()
		sound.text = "Sound: %s" % ["ON" if GameState.sound_enabled else "OFF"]
	)
	box.add_child(sound)

	var info := Label.new()
	info.text = "Mobile controls are enabled in-game. Use the on-screen D-pad and action button."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.custom_minimum_size = Vector2(300, 72)
	info.add_theme_font_size_override("font_size", 17)
	box.add_child(info)

	var back := _button("Back")
	back.pressed.connect(func():
		AudioManager.play_click()
		get_parent().go_to_title()
	)
	box.add_child(back)

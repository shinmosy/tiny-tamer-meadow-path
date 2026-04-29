extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_screen()

func _build_screen() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#bde5a8")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	for i in range(28):
		var leaf := ColorRect.new()
		leaf.color = Color("#fff2a8", 0.45)
		leaf.position = Vector2(randf_range(20, 930), randf_range(30, 500))
		leaf.size = Vector2(randf_range(8, 20), 4)
		leaf.rotation = randf_range(-0.6, 0.6)
		add_child(leaf)
		var tw := create_tween().set_loops()
		tw.tween_property(leaf, "position:y", leaf.position.y + randf_range(8, 18), randf_range(1.4, 2.6)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(leaf, "position:y", leaf.position.y, randf_range(1.4, 2.6)).set_trans(Tween.TRANS_SINE)
	var card := Panel.new()
	card.position = Vector2(250, 48)
	card.size = Vector2(460, 450)
	card.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#fff2cf", .96), Color("#2e5d3b"), 24))
	add_child(card)
	var title := Label.new()
	title.text = "Tiny Tamer"
	title.position = Vector2(0, 30)
	title.size = Vector2(460, 58)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", UITheme.INK)
	card.add_child(title)
	var sub := Label.new()
	sub.text = "Wild Routes Update"
	sub.position = Vector2(0, 92)
	sub.size = Vector2(460, 28)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color("#4b684c"))
	card.add_child(sub)
	var buttons := VBoxContainer.new()
	buttons.position = Vector2(110, 145)
	buttons.size = Vector2(240, 270)
	buttons.add_theme_constant_override("separation", 12)
	card.add_child(buttons)
	if SaveManager.has_save(): buttons.add_child(_button("Continue", _on_continue))
	buttons.add_child(_button("Start Adventure", _on_start))
	buttons.add_child(_button("Meadow Dex", _on_dex))
	buttons.add_child(_button("Options", _on_options))
	buttons.add_child(_button("Credits", _on_credits))
	_add_monster("res://assets/sprites/spriglet.svg", Vector2(85, 360), 95)
	_add_monster("res://assets/sprites/mossbun.svg", Vector2(770, 356), 95)

func _button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(240, 46)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", UITheme.INK)
	b.add_theme_stylebox_override("normal", UITheme.button_style())
	b.pressed.connect(callback)
	return b

func _add_monster(path: String, pos: Vector2, size: int) -> void:
	var t := TextureRect.new()
	t.texture = load(path)
	t.position = pos
	t.size = Vector2(size, size)
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(t)
	var tw := create_tween().set_loops()
	tw.tween_property(t, "position:y", pos.y - 8, 1.2)
	tw.tween_property(t, "position:y", pos.y, 1.2)

func _on_continue() -> void:
	AudioManager.play_click()
	SaveManager.load_game()
	get_parent().go_to_overworld(true)
func _on_start() -> void:
	AudioManager.play_click()
	get_parent().go_to_overworld(false)
func _on_dex() -> void:
	AudioManager.play_click()
	get_parent().go_to_dex()
func _on_options() -> void:
	AudioManager.play_click()
	get_parent().go_to_options()
func _on_credits() -> void:
	var p := AcceptDialog.new(); p.title="Credits"; p.dialog_text="Tiny Tamer: Meadow Path\nGodot 4 Web prototype\nAI-assisted development workflow\nOriginal vector/SFX prototype assets"; add_child(p); p.popup_centered()

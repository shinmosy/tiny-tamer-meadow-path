extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _button(text: String, pos: Vector2, cb: Callable) -> Button:
	var b := Button.new(); b.text=text; b.position=pos; b.size=Vector2(150,34); b.add_theme_font_size_override("font_size",15); b.add_theme_color_override("font_color", UITheme.INK); b.add_theme_stylebox_override("normal", UITheme.button_style()); b.pressed.connect(cb); return b

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color=Color("#051629"); bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var book := Panel.new(); book.position=Vector2(55,35); book.size=Vector2(850,470); book.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#0a2a4f"), Color("#71f7ff"), 20)); add_child(book)
	var glow := ColorRect.new(); glow.color=Color("#71f7ff", 0.35); glow.position=Vector2(0,466); glow.size=Vector2(850,4); book.add_child(glow)
	var title := Label.new(); title.text="CREATURE COLLECTION"; title.position=Vector2(0,20); title.size=Vector2(850,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",34); title.add_theme_color_override("font_color",Color("#ffffff")); book.add_child(title)
	var summary := Label.new(); summary.text="Caught %d / 12   Team: %s   Active: %s" % [GameState.caught_critters.size(), str(GameState.team), GameState.active_companion]; summary.position=Vector2(70,68); summary.size=Vector2(710,28); summary.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; summary.add_theme_font_size_override("font_size",18); summary.add_theme_color_override("font_color",Color("#71f7ff")); book.add_child(summary)
	var names := GameState.get_monster_names()
	names.erase("Bramblehorn")
	for i in range(names.size()):
		var name = names[i]
		var m = GameState.get_monster_data(name)
		var col = i % 4; var row = i / 4
		var card := Panel.new(); card.position=Vector2(35 + col*200, 110 + row*110); card.size=Vector2(180, 96); card.add_theme_stylebox_override("panel", UITheme.panel_style(Color("#113763"), UITheme.type_color(m.get("type","Meadow")), 14)); book.add_child(card)
		var icon := TextureRect.new(); icon.texture=load(m.get("sprite")); icon.position=Vector2(8,10); icon.size=Vector2(64,64); icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; card.add_child(icon)
		var caught: bool = name == "Spriglet" or GameState.caught_critters.has(name)
		var plate := ColorRect.new(); plate.color=Color("#031221"); plate.position=Vector2(70,8); plate.size=Vector2(100,24); card.add_child(plate)
		var label := Label.new(); label.text = name.to_upper() if caught else "???"; label.position=Vector2(74,8); label.size=Vector2(92,24); label.add_theme_font_size_override("font_size",15); label.add_theme_color_override("font_color",Color("#ffffff")); card.add_child(label)
		var meta := Label.new(); meta.text = "%s | CP %s" % [m.get("type"), str(GameState.caught_cp.get(name, m.get("cp_min"))) if caught else "?"]; meta.position=Vector2(76,34); meta.size=Vector2(98,22); meta.add_theme_font_size_override("font_size",13); meta.add_theme_color_override("font_color",Color("#a9c2cf")); card.add_child(meta)
		var role := Label.new(); role.text = m.get("role", ""); role.position=Vector2(76,55); role.size=Vector2(98,18); role.add_theme_font_size_override("font_size",11); role.add_theme_color_override("font_color",Color("#5d8db5")); card.add_child(role)
		if caught:
			var use := Button.new(); use.text = "Active" if GameState.active_companion == name else "Use"; use.position=Vector2(76,72); use.size=Vector2(82,22); use.add_theme_font_size_override("font_size",11); use.pressed.connect(func(n=name): GameState.set_active_companion(n); SaveManager.save_game(); get_tree().reload_current_scene()); card.add_child(use)
	var back := _button("Back", Vector2(350, 425), _back); book.add_child(back)

func _back() -> void:
	AudioManager.play_click(); get_parent().go_to_title()

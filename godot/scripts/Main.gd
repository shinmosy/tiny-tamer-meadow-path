extends Node

var current_scene: Node = null
var fade_layer: CanvasLayer
var fade_rect: ColorRect
var loading_panel: Panel
var loading_label: Label
var encounter_label: Label

func _ready() -> void:
	_build_fade_layer()
	go_to_title()

func _build_fade_layer() -> void:
	fade_layer = CanvasLayer.new()
	fade_layer.layer = 50

	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(960, 540)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade_rect)

	loading_panel = Panel.new()
	loading_panel.position = Vector2(280, 205)
	loading_panel.size = Vector2(400, 130)
	loading_panel.visible = false
	fade_layer.add_child(loading_panel)

	loading_label = Label.new()
	loading_label.text = "Loading..."
	loading_label.position = Vector2(0, 34)
	loading_label.size = Vector2(400, 60)
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.add_theme_font_size_override("font_size", 34)
	loading_label.add_theme_color_override("font_color", Color("#ffffff"))
	loading_panel.add_child(loading_label)

	encounter_label = Label.new()
	encounter_label.text = ""
	encounter_label.position = Vector2(205, 220)
	encounter_label.size = Vector2(550, 92)
	encounter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	encounter_label.add_theme_font_size_override("font_size", 34)
	encounter_label.add_theme_color_override("font_color", Color("#ffffff"))
	encounter_label.visible = false
	fade_layer.add_child(encounter_label)

	add_child(fade_layer)

func switch_to(scene_path: String) -> void:
	if current_scene:
		current_scene.queue_free()
	var packed := load(scene_path)
	current_scene = packed.instantiate()
	add_child(current_scene)

func fade_switch_to(scene_path: String, loading_text := "Loading...") -> void:
	loading_label.text = loading_text
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.92, 0.18)
	await tween.finished
	loading_panel.visible = true
	await get_tree().create_timer(0.22).timeout
	switch_to(scene_path)
	await get_tree().create_timer(0.16).timeout
	loading_panel.visible = false
	var tween_out := create_tween()
	tween_out.tween_property(fade_rect, "color:a", 0.0, 0.24)
	await tween_out.finished

func go_to_title() -> void:
	switch_to("res://scenes/TitleScreen.tscn")

func go_to_options() -> void:
	fade_switch_to("res://scenes/Options.tscn", "Opening options...")

func go_to_dex() -> void:
	fade_switch_to("res://scenes/MonsterDex.tscn", "Opening Meadow Dex...")

func go_to_overworld() -> void:
	fade_switch_to("res://scenes/Overworld.tscn", "Entering Meadow Path...")

func go_to_battle(biome := "") -> void:
	GameState.choose_random_enemy(biome)
	_show_encounter_transition("%s encounter: %s appeared!" % [GameState.current_biome, GameState.enemy_name])

func go_to_practice_battle() -> void:
	GameState.choose_random_enemy()
	AudioManager.play_encounter()
	_show_encounter_transition("Practice battle: %s" % GameState.enemy_name)

func _show_encounter_transition(message: String) -> void:
	encounter_label.text = message
	encounter_label.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.84, 0.16)
	tween.parallel().tween_property(encounter_label, "modulate:a", 1.0, 0.16)
	await tween.finished
	await get_tree().create_timer(0.55).timeout
	encounter_label.visible = false
	encounter_label.modulate.a = 1.0
	fade_switch_to("res://scenes/Battle.tscn", "Preparing battle...")

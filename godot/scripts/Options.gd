extends Control

var sound_label: Label
var touch_label: Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	var bg := ColorRect.new(); bg.color = Color("#22422d"); bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var panel := Panel.new(); panel.position = Vector2(250, 60); panel.size = Vector2(460, 420); panel.add_theme_stylebox_override("panel", UITheme.panel_style()); add_child(panel)
	var title := Label.new(); title.text="Options"; title.position=Vector2(0,30); title.size=Vector2(460,45); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",36); title.add_theme_color_override("font_color",UITheme.INK); panel.add_child(title)
	sound_label = _row(panel, 105, "Sound", _sound_text(), _toggle_sound)
	touch_label = _row(panel, 170, "Touch Controls", SettingsManager.touch_controls_mode, _cycle_touch)
	var hint := Label.new(); hint.text="Touch modes: Auto for phones, Always for testing, Off for desktop capture."; hint.position=Vector2(55,235); hint.size=Vector2(350,55); hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; hint.add_theme_font_size_override("font_size",16); hint.add_theme_color_override("font_color",Color("#54624f")); panel.add_child(hint)
	var back := _button("Back", Vector2(130, 330), _back); panel.add_child(back)

func _row(parent: Control, y: int, name: String, value: String, cb: Callable) -> Label:
	var l := Label.new(); l.text=name; l.position=Vector2(55,y); l.size=Vector2(170,40); l.add_theme_font_size_override("font_size",22); l.add_theme_color_override("font_color",UITheme.INK); parent.add_child(l)
	var b := _button(value, Vector2(240,y-4), cb); parent.add_child(b)
	return b.get_child(0) if b.get_child_count()>0 else l

func _button(text:String,pos:Vector2,cb:Callable)->Button:
	var b:=Button.new(); b.text=text; b.position=pos; b.size=Vector2(190,44); b.add_theme_font_size_override("font_size",18); b.add_theme_color_override("font_color",UITheme.INK); b.add_theme_stylebox_override("normal",UITheme.button_style()); b.pressed.connect(cb); return b
func _sound_text()->String: return "ON" if SettingsManager.sound_enabled else "OFF"
func _toggle_sound()->void: SettingsManager.toggle_sound(); get_tree().reload_current_scene()
func _cycle_touch()->void: SettingsManager.cycle_touch_mode(); get_tree().reload_current_scene()
func _back()->void: AudioManager.play_click(); get_parent().go_to_title()

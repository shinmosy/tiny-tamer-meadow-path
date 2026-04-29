extends Node

var sound_enabled := true
var touch_controls_mode := "Auto" # Auto, Always, Off
var reduce_motion := false

func should_show_touch_controls() -> bool:
	if touch_controls_mode == "Always":
		return true
	if touch_controls_mode == "Off":
		return false
	return DisplayServer.is_touchscreen_available() or OS.has_feature("web_android") or OS.has_feature("web_ios")

func toggle_sound() -> void:
	sound_enabled = not sound_enabled

func cycle_touch_mode() -> void:
	if touch_controls_mode == "Auto":
		touch_controls_mode = "Always"
	elif touch_controls_mode == "Always":
		touch_controls_mode = "Off"
	else:
		touch_controls_mode = "Auto"

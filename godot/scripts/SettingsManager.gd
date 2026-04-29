extends Node

var sound_enabled := true
var touch_controls_mode := "Auto"  # "Auto", "Always", "Off"

# Cycle through Auto -> Always -> Off
func cycle_touch_mode() -> void:
	if touch_controls_mode == "Auto":
		touch_controls_mode = "Always"
	elif touch_controls_mode == "Always":
		touch_controls_mode = "Off"
	else:
		touch_controls_mode = "Auto"

func toggle_sound() -> void:
	sound_enabled = !sound_enabled

func should_show_touch_controls() -> bool:
	if touch_controls_mode == "Always":
		return true
	if touch_controls_mode == "Off":
		return false
	# "Auto" - detect mobile/web
	return OS.has_feature("mobile") or OS.has_feature("web")
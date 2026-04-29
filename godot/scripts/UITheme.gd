extends Node

const INK := Color("#203528")
const PAPER := Color("#fff1cf")
const PAPER_DARK := Color("#f0c879")
const GREEN := Color("#4f8d55")
const GREEN_DARK := Color("#2f5d35")
const AMBER := Color("#d69b3a")
const BLUE := Color("#5da9d6")
const STONE := Color("#7d766b")

func panel_style(bg: Color = PAPER, border: Color = GREEN_DARK, radius: int = 18) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(radius)
	sb.shadow_color = Color(0, 0, 0, 0.18)
	sb.shadow_size = 8
	return sb

func button_style(bg: Color = PAPER_DARK, border: Color = GREEN_DARK) -> StyleBoxFlat:
	var sb := panel_style(bg, border, 14)
	sb.shadow_size = 3
	return sb

func type_color(t: String) -> Color:
	match t:
		"Meadow": return Color("#7cc96f")
		"Forest": return Color("#3f7f4c")
		"Water": return Color("#5aaee8")
		"Stone": return Color("#978974")
		"Bloom": return Color("#df72b5")
		"Ember": return Color("#e0773e")
		_: return Color("#c6b48a")

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

func type_color(type: String) -> Color:
	match type:
		"Meadow": return Color("#33b6ac")
		"Forest": return Color("#4f8d55")
		"Water": return Color("#3a9ad8")
		"Stone": return Color("#8a7c6b")
		"Bloom": return Color("#d86c94")
		"Ember": return Color("#d86b3a")
		"Fire": return Color("#e25822")
		"Electric": return Color("#f2ca35")
		"Air": return Color("#8ec9db")
		"Sound": return Color("#a65cd9")
		"Ghost": return Color("#533c75")
		"Light": return Color("#f9e984")
		"Shadow": return Color("#2c2b3d")
		"Tech": return Color("#5c6875")
		_: return Color("#33b6ac")

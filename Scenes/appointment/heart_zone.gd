extends Control

var beat_phase: float = 0.0
var playing: bool = false

func _draw() -> void:
	var center := size * 0.5
	var inner_r := 34.0
	var outer_r := 58.0
	draw_circle(center, inner_r, Color(0.85, 0.25, 0.25, 0.35))
	draw_arc(center, inner_r, 0.0, TAU, 48, Color(0.7, 0.15, 0.15), 4.0)
	var phase := beat_phase if playing else 0.0
	var indicator := phase * TAU - PI * 0.5
	for i in range(64):
		var a0 := (float(i) / 64.0) * TAU - PI * 0.5
		var a1 := (float(i + 1) / 64.0) * TAU - PI * 0.5
		var seg_phase := fmod((a0 + PI * 0.5) / TAU, 1.0)
		if seg_phase < 0.0:
			seg_phase += 1.0
		var col := Color(0.75, 0.15, 0.15)
		if seg_phase < 0.14 or seg_phase > 0.86:
			col = Color(0.2, 0.75, 0.25)
		elif seg_phase < 0.26 or seg_phase > 0.74:
			col = Color(0.9, 0.75, 0.15)
		draw_arc(center, outer_r, a0, a1, 2, col, 9.0)
	var dot := center + Vector2(cos(indicator), sin(indicator)) * outer_r
	draw_circle(dot, 7.0, Color(1, 1, 1))
	draw_circle(dot, 5.0, _dot_color(phase))

func _dot_color(phase: float) -> Color:
	if phase < 0.14 or phase > 0.86:
		return Color(0.2, 0.75, 0.25)
	if phase < 0.26 or phase > 0.74:
		return Color(0.9, 0.75, 0.15)
	return Color(0.75, 0.15, 0.15)

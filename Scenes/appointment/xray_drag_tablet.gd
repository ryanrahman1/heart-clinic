extends Control

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var can_drag: bool = false

func set_drag_enabled(v: bool) -> void:
	can_drag = v
	if not v:
		dragging = false

func _gui_input(event: InputEvent) -> void:
	if not can_drag:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - event.global_position
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		global_position = event.global_position + drag_offset

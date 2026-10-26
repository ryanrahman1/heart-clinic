extends Control

@onready var chart_texture = $TextureRect

var hover_dist = -100
var default_position: Vector2
var tween: Tween
var is_centered: bool = false

signal chart_opened

func _ready():
	default_position = chart_texture.position
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_global_rect().has_point(get_global_mouse_position()) and not is_centered:
			chart_opened.emit()
			center_chart()
			
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		if is_centered:
			reset_chart()

func _on_mouse_entered():
	if is_centered: return 
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if tween and tween.is_running(): tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	var target_position = default_position - Vector2(hover_dist, 0)
	tween.tween_property(chart_texture, "position", target_position, 0.4)

func _on_mouse_exited():
	if is_centered: return 
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	if tween and tween.is_running(): tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(chart_texture, "position", default_position, 0.3)

func center_chart():
	is_centered = true
	if tween and tween.is_running(): tween.kill()
	
	var screen_center = get_viewport_rect().size / 2
	var target_position = screen_center - (chart_texture.size / 2) - global_position
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(chart_texture, "position", target_position, 0.5)

func reset_chart():
	is_centered = false
	if tween and tween.is_running(): tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(chart_texture, "position", default_position, 0.4)

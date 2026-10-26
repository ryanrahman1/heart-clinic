extends CanvasLayer

@onready var btn = $Button
var tween: Tween


func _ready() -> void:
	offset.y = 1000
	btn.pressed.connect(_on_button_pressed)

func open_settings() -> void:
	if tween and tween.is_running(): tween.kill()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "offset:y", 0, 0.4)

func hide_settings() -> void:
	if tween and tween.is_running(): tween.kill()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "offset:y", 900, 0.4)

func _on_button_pressed():
	if tween and tween.is_running(): tween.kill()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "offset:y", 1000, 0.4)

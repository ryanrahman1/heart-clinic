extends CanvasLayer

@onready var close_btn = $Button
@onready var blurbg = $blurbg
@onready var stetho = $Tools/Stethoscope
@onready var xray = $Tools/Xray

func _ready():
	close_btn.pressed.connect(_on_close_pressed)
	
	blurbg.hide()

func _on_close_pressed():
	hide()

func _on_stethoscope_mouse_entered() -> void:
	blurbg.show()
	xray.hide()
	$Tools/Stethoscope/Stethoscope.show()

func _on_stethoscope_mouse_exited() -> void:
	blurbg.hide()
	xray.show()
	$Tools/Stethoscope/Stethoscope.hide()

func _on_xray_mouse_entered() -> void:
	blurbg.show()
	stetho.hide()
	$Tools/Xray/Xray.show()

func _on_xray_mouse_exited() -> void:
	blurbg.hide()
	stetho.show()
	$Tools/Xray/Xray.hide()

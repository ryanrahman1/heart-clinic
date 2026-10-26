extends Control

@onready var label = $Label


func _ready():
	label.hide()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	label.show()

func _on_mouse_exited():
	label.hide()

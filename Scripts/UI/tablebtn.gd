extends Button


@onready var table_layer: CanvasLayer = $"../../../CanvasLayer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_btn_pressed)


func _btn_pressed():
	table_layer.show()
	

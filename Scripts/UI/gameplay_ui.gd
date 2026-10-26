extends Control

@onready var menu_btn = $MenuButton
@onready var settings_layer = get_node("../../SettingsOverlay")
@onready var root = owner

func _ready():
	var popup = menu_btn.get_popup()
	popup.id_pressed.connect(_on_item_pressed)

func _on_item_pressed(id: int) -> void:
	match id: 
		0:
			root.start_appointment(load("res://Data/Appointments/AdultCheckup01/AdultCheckup01.tres"))
		1:
			settings_layer.open_settings()

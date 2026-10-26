
class_name ExaminationData
extends Resource

@export var examination_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Minigame")
@export var minigame_layer_name: String = "" # canvas layer node name on appointment scene

@export_group("Patient Effects")
@export var comfort_change: float = 0.0
@export var trust_change: float = 0.0

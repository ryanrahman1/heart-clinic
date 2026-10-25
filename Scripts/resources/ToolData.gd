
class_name ToolData
extends Resource

@export var tool_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_multiline var hint: String = ""

@export var sprite: Texture2D

@export_group("Examinations")
@export var examinations: Array[ExaminationData] = []

class_name PatientData
extends Resource

@export var patient_id: String = ""
@export var patient_name: String = ""
@export_range(0, 120) var age: int = 0
@export_multiline var description: String = ""

@export_group("Appearance")
@export var portrait: Texture2D
@export var character_scene: PackedScene

@export_group("Patient Statistics")
@export_range(0.0, 100.0) var initial_comfort: float = 50.0
@export_range(0.0, 100.0) var initial_trust: float = 50.0
@export_range(0.0, 100.0) var knowledge: float = 50.0

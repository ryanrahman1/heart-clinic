class_name ExamSheetData
extends Resource

@export_group("Prescreening")
@export_multiline var reason_for_visit: String = ""
@export var initial_symptoms: Array[String] = []

@export_group("Medical History")
@export var medical_history: Array[String] = []

@export_group("Initial Notes")
@export var initial_notes: Array[String] = []

@export_group("Hints")
@export var hints: Array[String] = []

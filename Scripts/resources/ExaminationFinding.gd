class_name ExaminationFinding
extends Resource

@export var examination: ExaminationData
@export var observation: ObservationData

@export_range(0.0, 1.0, 0.05) var evidence_value: float = 0.0

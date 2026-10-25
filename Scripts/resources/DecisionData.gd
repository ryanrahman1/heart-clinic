class_name DecisionData
extends Resource

@export var decision_id: String = ""
@export_multiline var decision_text: String = ""

@export_group("Evaluation")
@export_range(0.0, 1.0, 0.05) var score: float = 0.0
@export_multiline var explanation: String = ""

@export_group("Follow-up Procedure")
@export var procedure: ProcedureData

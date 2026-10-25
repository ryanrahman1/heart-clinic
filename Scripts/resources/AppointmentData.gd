
class_name AppointmentData
extends Resource

@export_group("Identity")
@export var appointment_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Patient & Scene")
@export var patient: PatientData
@export var appointment_scene: PackedScene
@export var exam_sheet: ExamSheetData

@export_group("Interview")
@export var questions: Array[QuestionData] = []
@export_range(1, 20) var question_pool_size: int = 5
@export_range(0, 10) var max_questions: int = 3

@export_group("Examinations")
@export var available_tools: Array[ToolData] = []
@export_range(0, 10) var max_examinations: int = 2

@export_group("Observations")
@export var examination_findings: Array[ExaminationFinding] = []

@export_group("Decisions")
@export var decisions: Array[DecisionData] = []
@export_range(1, 10) var decision_pool_size: int = 4

@export_group("Scoring")
@export_range(1.0, 100.0) var comfort_target: float = 15.0
@export_range(1.0, 100.0) var trust_target: float = 15.0
@export_range(1.0, 100.0) var evidence_target: float = 15.0
@export_range(0.0, 3.0, 0.05) var child_comfort_multiplier: float = 1.25

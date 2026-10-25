
class_name QuestionData
extends Resource

enum Category {
	RELEVANT,
	SUPPORTIVE,
	IRRELEVANT
}

@export var question_id: String = ""
@export_multiline var question_text: String = ""
@export_multiline var response_text: String = ""
@export var category: Category = Category.RELEVANT

@export_multiline var chart_note: String = ""

@export_group("Patient Effects")
@export var comfort_change: float = 0.0
@export var trust_change: float = 0.0

@export_group("Knowledge Modifiers")
@export_range(-2.0, 2.0, 0.1) var comfort_knowledge_modifier: float = 0.0
@export_range(-2.0, 2.0, 0.1) var trust_knowledge_modifier: float = 0.0

@export_group("Evidence")
@export_range(0.0, 1.0, 0.05) var evidence_value: float = 0.0

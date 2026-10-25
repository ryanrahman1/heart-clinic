
class_name PatientState
extends RefCounted

var comfort: float = 0.0
var trust: float = 0.0
var knowledge: float = 0.0

var initial_comfort: float = 0.0
var initial_trust: float = 0.0

var cumulative_comfort_delta: float = 0.0 # for calc score, adding all them up
var cumulative_trust_delta: float = 0.0 # ^^ 

func initialize(patient: PatientData) -> void:
	initial_comfort = patient.initial_comfort
	initial_trust = patient.initial_trust
	
	# set vars to initials
	comfort = initial_comfort
	trust = initial_trust
	knowledge = patient.knowledge
	
	cumulative_comfort_delta = 0
	cumulative_trust_delta = 0

func calculate_effect(base_change: float, knowledge_effect: float) -> float:
	# delta equals base change plus knowledge over 100 times effect
	return (base_change + ((knowledge / 100) * knowledge_effect))

func apply_effect(comfort_change: float, trust_change: float) -> void:
	#adds deltas to cumulative
	cumulative_comfort_delta += comfort_change
	cumulative_trust_delta += trust_change

	#takes the changes from above and applies to current values
	#clamps it between 0 and 100 aswell
	comfort = clampf(comfort + comfort_change, 0.0, 100.0)
	trust = clampf(trust + trust_change, 0.0, 100.0)

func apply_question(question: QuestionData) -> void:
	# calculate effect for comfort + trust
	var comfort_effect := calculate_effect(question.comfort_change, question.comfort_knowledge_modifier)
	var trust_effect := calculate_effect(question.trust_change, question.trust_knowledge_modifier)
	
	#apply results
	apply_effect(comfort_effect, trust_effect)

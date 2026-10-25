class_name AppointmentManager
extends Node

enum Stage {
	INACTIVE,
	ARRIVAL,
	INTERVIEW,
	EXAMINATION,
	REVIEW,
	DECISION,
	PROCEDURE,
	RESULTS
}

var current_stage: Stage = Stage.INACTIVE

#apt state
var session: AppointmentSession # current session
var scorer: AppointmentScorer = AppointmentScorer.new()
var results: Dictionary

@export var starting_appointment: AppointmentData

signal appointment_started(appointment: AppointmentData) #new sess init
signal stage_changed(stage: Stage) # new state

signal question_asked(question: QuestionData) #valid interview question chosen
signal examination_started(examination: ExaminationData) #exam confirmed, credit gone
signal examination_completed(examination: ExaminationData, observation: ObservationData)

signal decision_selected(decision: DecisionData) #chose decision 
signal procedure_started(procedure: ProcedureData) #opt procdeure stuff
signal procedure_completed(procedure: ProcedureData)

signal patient_state_changed(state: PatientState) #state of patient changed (ui)
signal chart_updated(chart: PatientChart)

signal appointment_completed(results: Dictionary) #done


func start_appointment(data: AppointmentData) -> void: #inits current appt
	session = AppointmentSession.new()
	session.initialize(data)
	results.clear()
	
	current_stage = Stage.ARRIVAL
	appointment_started.emit(data)
	stage_changed.emit(current_stage)

func _set_stage(new_stage: Stage) -> void:
	if new_stage == current_stage: return
	current_stage = new_stage
	stage_changed.emit(new_stage)

func advance_stage() -> void:
	match current_stage:
		Stage.ARRIVAL:
			_set_stage(Stage.INTERVIEW)
		Stage.INTERVIEW:
			_set_stage(Stage.EXAMINATION)
		Stage.EXAMINATION:
			if session.active_examination != null:
				return
			_set_stage(Stage.REVIEW)
		Stage.REVIEW:
			_set_stage(Stage.DECISION)

func ask_question(question: QuestionData) -> bool:
	#handles intevriew selection
	if (current_stage != Stage.INTERVIEW): return false
	
	var res = session.ask_question(question)
	if res == false: return false
	
	question_asked.emit(question)
	patient_state_changed.emit(session.patient_state)
	chart_updated.emit(session.chart)
	
	return true

func start_examination(exam: ExaminationData) -> bool:
	if (current_stage != Stage.EXAMINATION): return false
	
	var res = session.start_examination(exam)
	if res == false: return false
	
	examination_started.emit(exam)
	return true

func complete_examination() -> bool:
	if (current_stage != Stage.EXAMINATION): return false
	var cur_exam = session.active_examination
	
	var res = session.complete_examination()
	if res == false: return false

	var index = session.appointment.examination_findings.find_custom(func(item): return item != null and item.examination == cur_exam)
	if index == -1: push_error("none"); return false
	var obsv: ExaminationFinding = session.appointment.examination_findings[index]
	
	examination_completed.emit(cur_exam, obsv.obervation)
	patient_state_changed.emit(session.patient_state)
	chart_updated.emit(session.chart)
	
	return true

func select_decision(decision: DecisionData) -> bool:
	if (current_stage != Stage.DECISION): return false
	
	var res = session.select_decision(decision)
	if res == false: return false
	
	decision_selected.emit(decision)
	
	if (session.active_procedure != null):
		_set_stage(Stage.PROCEDURE)
		procedure_started.emit(session.active_procedure)
	else:
		finish_appointment()
	
	return true
	
func complete_procedure(score: float) -> bool:
	if (current_stage != Stage.PROCEDURE): return false
	var res = session.complete_procedure(score)
	if res == false: return false
	procedure_completed.emit(session.active_procedure)
	
	finish_appointment()
	return true

func finish_appointment() -> void:
	results = scorer.return_results(session)
	_set_stage(Stage.RESULTS)
	appointment_completed.emit(results)

extends Node2D


# we start an appointment here

@onready var Manager = $AppointmentManager
@onready var patient_container = $World/PatientContainer
@onready var nurse_container = $"World/Mentor Container"
@onready var nurse_dialogue = $"World/Mentor Container/TextureRect"
@onready var nurse_text = $"World/Mentor Container/TextureRect/Label"
@onready var cur_patient = $UI/Label
@onready var stage_label = $UI/Label2
@onready var chart = $UI/GameplayUI/ChartArea

@onready var next_step = $UI/GameplayUI/StartInterview

@onready var question_buttons: Array[Button] = [
	$"UI/GameplayUI/QuestionArea/ColorRect/Q1",
	$"UI/GameplayUI/QuestionArea/ColorRect/Q2",
	$"UI/GameplayUI/QuestionArea/ColorRect/Q3",
	$"UI/GameplayUI/QuestionArea/ColorRect/Q4",
	$"UI/GameplayUI/QuestionArea/ColorRect/Q5"
]
@onready var continue_question = $"UI/GameplayUI/QuestionArea/continuebtn"

@onready var q_container = $UI/GameplayUI/QuestionArea
@onready var q_text = $UI/GameplayUI/QuestionArea/Label

@onready var table_btn = $UI/GameplayUI/Button
@onready var table_layer = $CanvasLayer
@onready var steth_minigame = $StethoscopeMinigame
@onready var xray_minigame = $XrayMinigame
@onready var review_screen = $ReviewScreen
@onready var results_screen = $Results
@onready var gameplay_ui = $UI

var _active_minigame: CanvasLayer

@onready var tool_areas: Array[Control] = [
	$CanvasLayer/Tools/Stethoscope/mousearea,
	$CanvasLayer/Tools/Xray/mousearea
]

@onready var decision_box = $UI/GameplayUI/Decisionbox
@onready var decision_buttons: Array[Button] = [
	$"UI/GameplayUI/Decisionbox/ColorRect/Q1",
	$"UI/GameplayUI/Decisionbox/ColorRect/Q2",
	$"UI/GameplayUI/Decisionbox/ColorRect/Q3",
	$"UI/GameplayUI/Decisionbox/ColorRect/Q4",
]


var can_change_stage: bool = false

func _ready():
	Manager.stage_changed.connect(_on_stage_changed)
	nurse_container.hide()
	chart.chart_opened.connect(_on_chart_opened)
	next_step.pressed.connect(_next_step_pressed)
	next_step.hide()
	q_container.hide()
	continue_question.hide()
	continue_question.pressed.connect(_on_continue_pressed)
	table_btn.pressed.connect(_on_table_opened)
	Manager.examination_started.connect(_on_examination_started)
	Manager.chart_updated.connect(_on_chart_updated)
	Manager.appointment_started.connect(_on_appointment_started)
	steth_minigame.finished.connect(_on_minigame_finished)
	xray_minigame.finished.connect(_on_minigame_finished)
	review_screen.make_decision_pressed.connect(_on_make_decision_pressed)
	Manager.appointment_completed.connect(_on_appointment_completed)
	

func start_appointment(appointment: AppointmentData):
	cur_patient.text = "Current Patient: " + appointment.patient.patient_name
	var patient_scene = appointment.patient.character_scene
	var instance = patient_scene.instantiate()
	patient_container.add_child(instance)
	
	Manager.start_appointment(appointment)

func _on_appointment_started(_appointment: AppointmentData) -> void:
	_refresh_chart_label()

func _on_chart_updated(_chart: PatientChart) -> void:
	_refresh_chart_label()

func _refresh_chart_label() -> void:
	if Manager.session == null or Manager.session.chart == null:
		return
	chart.set_chart_text(Manager.session.chart.get_display_text())

# flow:

#started appointment, then we go to arrival stage; the nurse shows up and says, check your patient chart for details!
# then we check the chart, and click start interview
# now all the questions show up, we can choose to ask
# then once we ask and our chart updates, we can move onto examinations
# etc. 

func start_nurse():
	var nurse_scene: PackedScene = load("res://Scenes/Patients/mentor.tscn")
	var nurse = nurse_scene.instantiate()
	nurse_container.add_child(nurse)
	# set nurse text
	nurse_text.text = "Check your patient chart for
		information about this patient!
		After, start asking questions
		using the button below."
	nurse_container.show()

func start_interview():
	q_container.show()
	q_text.text = "Ask a Question ({remaining} left)".format({"remaining": Manager.session.questions_remaining})
	update_questions()

func _on_chart_opened():
	nurse_container.hide()
	if (Manager.current_stage == AppointmentManager.Stage.ARRIVAL):
		next_step.show()
		can_change_stage = true
	
func _on_table_opened():
	nurse_container.hide()

func _on_stage_changed(stage: AppointmentManager.Stage):
	stage_label.text = "Current Stage: " + AppointmentManager.Stage.keys()[stage].capitalize()
	review_screen.close()
	if stage != AppointmentManager.Stage.RESULTS:
		results_screen.close()
	if (stage == AppointmentManager.Stage.ARRIVAL):
		start_nurse()
	if (stage == AppointmentManager.Stage.INTERVIEW):
		start_interview()
	if (stage == AppointmentManager.Stage.EXAMINATION):
		start_examinations()
	if (stage == AppointmentManager.Stage.REVIEW):
		start_review()
	if (stage == AppointmentManager.Stage.DECISION):
		gameplay_ui.show()
		start_decision()

func _next_step_pressed():
	if (can_change_stage):
		Manager.advance_stage()
		next_step.hide()
		

func update_questions():
	var available_questions = Manager.session.available_questions
	
	for i in range(question_buttons.size()):
		var button = question_buttons[i]
		
		if i < available_questions.size() and available_questions[i] != null:
			var q_data: QuestionData = available_questions[i]
			button.visible = true
			button.text = q_data.question_text
			
			if not button.pressed.is_connected(_on_question_button_pressed):
				button.pressed.connect(_on_question_button_pressed.bind(q_data))
		else:
			# Hide and clear buttons that don't have a matching question
			button.visible = false
			button.text = ""

func _hide_questions():
	for v in question_buttons:
		v.hide()

func _show_questions():
	for i in range(question_buttons.size()):
		var button = question_buttons[i]
		var questions = Manager.session.available_questions
		
		button.visible = (
			i < questions.size()
			and questions[i] != null
			and not Manager.session.asked_question_ids.has(
				questions[i].question_id
			)
		)

func _on_question_button_pressed(q_data: QuestionData):
	Manager.ask_question(q_data)
	_hide_questions()
	q_text.text = Manager.session.appointment.patient.patient_name + ": \n" + q_data.response_text
	continue_question.show()

func _on_continue_pressed():
	if (Manager.session.questions_remaining <= 0): Manager.advance_stage(); q_container.hide()
	continue_question.hide()
	_show_questions()
	q_text.text = "Ask a Question ({remaining} left)".format({"remaining": Manager.session.questions_remaining})


func start_review():
	nurse_container.hide()
	table_layer.hide()
	gameplay_ui.hide()
	review_screen.open(Manager.session.chart)

func _on_make_decision_pressed():
	if (Manager.current_stage == AppointmentManager.Stage.REVIEW):
		Manager.advance_stage()

func start_examinations():
	nurse_text.text = "Choose an exam to 
	perform on the patient!
	You have {remaining} exams left!
	".format({"remaining": Manager.session.examinations_remaining})
	nurse_container.show()
	
	for i in range(tool_areas.size()):
		var tool = tool_areas[i]
		
		if tool.gui_input.is_connected(_on_tool_gui_input):
			tool.gui_input.disconnect(_on_tool_gui_input)
			
		tool.gui_input.connect(_on_tool_gui_input.bind(i))

func _on_tool_gui_input(event: InputEvent, tool_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match tool_index:
			0:
				Manager.start_examination(load("res://Data/Appointments/AdultCheckup01/Examinations/ac01_heart.tres"))
			1:
				Manager.start_examination(load("res://Data/Appointments/AdultCheckup01/Examinations/ac01_chestx.tres"))

func _on_examination_started(exam: ExaminationData) -> void:
	if exam.minigame_layer_name.is_empty():
		return
	table_layer.hide()
	gameplay_ui.hide()
	nurse_container.hide()
	_active_minigame = get_node_or_null(exam.minigame_layer_name) as CanvasLayer
	if _active_minigame == null:
		return
	_active_minigame.begin(self, exam)

func _on_minigame_finished(score: float) -> void:
	var norm = score / 100.0
	Manager.session.patient_state.apply_effect(norm * 1.5, norm * 1.5)
	Manager.complete_examination()
	if _active_minigame != null:
		_active_minigame.hide()
		_active_minigame = null
	gameplay_ui.show()
	if Manager.session.examinations_remaining <= 0:
		Manager.advance_stage()
	else:
		nurse_text.text = "Choose an exam to 
	perform on the patient!
	You have {remaining} exams left!
	".format({"remaining": Manager.session.examinations_remaining})
		nurse_container.show()
	
func start_decision():
	decision_box.show()
	var available_decisions = Manager.session.available_decisions
	
	for i in range(decision_buttons.size()):
		var button = decision_buttons[i]
		
		if i < available_decisions.size() and available_decisions[i] != null:
			var d_data: DecisionData = available_decisions[i]
			button.visible = true
			button.text = d_data.decision_text
			
			if not button.pressed.is_connected(_on_decision_button_pressed):
				button.pressed.connect(_on_decision_button_pressed.bind(d_data))
		else:
			# Hide and clear buttons that don't have a matching question
			button.visible = false
			button.text = ""
		
func _on_decision_button_pressed(d_data: DecisionData):
	Manager.select_decision(d_data)
	decision_box.hide()

func _on_appointment_completed(results: Dictionary) -> void:
	nurse_container.hide()
	table_layer.hide()
	review_screen.close()
	gameplay_ui.hide()
	results_screen.show_results(results)

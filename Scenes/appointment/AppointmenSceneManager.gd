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

@onready var tool_areas: Array[Control] = [
	$CanvasLayer/Tools/Stethoscope/mousearea,
	$CanvasLayer/Tools/Xray/mousearea
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
	

func start_appointment(appointment: AppointmentData):
	cur_patient.text = "Current Patient: " + appointment.patient.patient_name
	var patient_scene = appointment.patient.character_scene
	var instance = patient_scene.instantiate()
	patient_container.add_child(instance)
	
	Manager.start_appointment(appointment)

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
	if (stage == AppointmentManager.Stage.ARRIVAL):
		start_nurse()
	if (stage == AppointmentManager.Stage.INTERVIEW):
		start_interview()
	if (stage == AppointmentManager.Stage.EXAMINATION):
		start_examinations()

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


func start_examinations():
	nurse_text.text = "Choose an exam to 
	perform on the patient!"
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
				Manager.start_examination(load("res://Data/Appointments/AdultCheckup01/Examinations/ac01_chestx.tres"))
			1:
				Manager.start_examination(load("res://Data/Appointments/AdultCheckup01/Examinations/ac01_chestx.tres"))

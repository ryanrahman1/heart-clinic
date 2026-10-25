class_name AppointmentSession
extends RefCounted

#appt
var appointment: AppointmentData
var patient_state: PatientState
var chart: PatientChart

#interview
var available_questions: Array[QuestionData] = []
var asked_question_ids: Array[String] = []
var questions_remaining: int = 0

#exams
var completed_examination_ids: Array[String] = []
var examinations_remaining: int = 0
var active_examination: ExaminationData

#decision
var available_decisions: Array[DecisionData] = []
var selected_decision: DecisionData

#procedure -- for vaccine
var active_procedure: ProcedureData
var procedure_score: float = 0.0
var procedure_completed: bool

func initialize(data: AppointmentData) -> void:
	appointment = data # set data to current appointment
	patient_state = PatientState.new() #create new patientstate
	patient_state.initialize(data.patient) #initialize w data from appointment
	chart = PatientChart.new() #new patienchart
	chart.initialize(data.exam_sheet) #init w data
	
	questions_remaining = data.max_questions #set
	examinations_remaining = data.max_examinations #set
	
	completed_examination_ids.clear()
	asked_question_ids.clear()
	
	active_examination = null
	selected_decision = null
	active_procedure = null
	
	procedure_score = 0
	procedure_completed = false
	
	generate_questions()
	generate_decisions()
	
func generate_questions() -> void:
	var target_size: int = min(appointment.question_pool_size, appointment.questions.size())
	if target_size <= 0:
		available_questions = []
		return

	# group by cat and score
	var categories = {
		QuestionData.Category.RELEVANT: [],
		QuestionData.Category.SUPPORTIVE: [],
		QuestionData.Category.IRRELEVANT: []
	}

	for q in appointment.questions:
		if categories.has(q.category):
			categories[q.category].append(q)

	for cat in categories.keys():
		categories[cat].shuffle()

	var cat_keys = categories.keys()
	@warning_ignore("integer_division")
	var base_count = target_size / 3
	var remainder = target_size % 3

	# distribute remainder and find ideal nums
	var quotas = {}
	for i in range(cat_keys.size()):
		var cat = cat_keys[i]
		quotas[cat] = base_count + (1 if i < remainder else 0)

	available_questions = []
	var shortages = 0

	# take up the quotas at first
	for cat in cat_keys:
		var available_in_cat = categories[cat]
		var take_count = min(quotas[cat], available_in_cat.size())
		
		available_questions.append_array(available_in_cat.slice(0, take_count))
		
		# if its short, track def
		if take_count < quotas[cat]:
			shortages += (quotas[cat] - take_count)
			
		# keep track of the leftovers
		categories[cat] = available_in_cat.slice(take_count)

	# if theres not enough, fill w whatever else
	if shortages > 0:
		var remaining_pool = []
		for cat in cat_keys:
			remaining_pool.append_array(categories[cat])
		remaining_pool.shuffle()
		
		var take_extra = min(shortages, remaining_pool.size())
		available_questions.append_array(remaining_pool.slice(0, take_extra))

	# shuffle at end for randomness
	available_questions.shuffle()

func generate_decisions() -> void:
	if appointment.decisions.is_empty():
		available_decisions = []
		return

	var target_size: int = min(appointment.decision_pool_size, appointment.decisions.size())
	available_decisions = []

	#  find best decision (this what gets u the 5 star)
	var max_score: float = -INF
	for d in appointment.decisions:
		if d and d.score > max_score:
			max_score = d.score

	# get all the ones that have the max to js pick one at random
	var best_decisions: Array[DecisionData] = []
	var other_decisions: Array[DecisionData] = []

	for d in appointment.decisions:
		if not d:
			continue
		if is_equal_approx(d.score, max_score):
			best_decisions.append(d)
		else:
			other_decisions.append(d)

	best_decisions.shuffle()
	other_decisions.shuffle()

	# always include a best decision
	if not best_decisions.is_empty():
		available_decisions.append(best_decisions[0])

	# fill remaning decision pool w the decisions
	var remaining_slots = target_size - available_decisions.size()
	if remaining_slots > 0 and not other_decisions.is_empty():
		var take_count = min(remaining_slots, other_decisions.size())
		for i in range(take_count):
			available_decisions.append(other_decisions[i])
			
	# fallback if there aren't enough, js get more of the best decisions
	if available_decisions.size() < target_size and best_decisions.size() > 1:
		for i in range(1, best_decisions.size()):
			if available_decisions.size() >= target_size:
				break
			var candidate = best_decisions[i]
			if not available_decisions.has(candidate):
				available_decisions.append(candidate)

	# shuffle so that the first isn't always best
	available_decisions.shuffle()

func ask_question(question: QuestionData) -> bool:
	if questions_remaining <= 0: return false # no qs left
	if (!available_questions.has(question)): return false # not available
	if (asked_question_ids.has(question.question_id)): return false #alr asked
	
	asked_question_ids.append(question.question_id)
	questions_remaining -= 1
	
	patient_state.apply_question(question)
	chart.add_interview_note(question.chart_note)
	
	return true

func start_examination(exam: ExaminationData) -> bool:
	if not is_examination_available(exam): return false
	if examinations_remaining <= 0: return false # no exams left
	if active_examination != null: return false
	if completed_examination_ids.has(exam.examination_id): return false
	
	examinations_remaining -= 1
	active_examination = exam
	
	return true

func complete_examination() -> bool: #once minigame is done
	if active_examination == null: return false #obv nothing to complete
	var index = appointment.examination_findings.find_custom(func(item): return item != null and item.examination == active_examination)
	if index == -1: push_error("none"); return false
	var finding: ExaminationFinding = appointment.examination_findings[index]
	
	chart.add_observation(finding.observation)
	patient_state.apply_effect(active_examination.comfort_change, active_examination.trust_change)
	completed_examination_ids.append(active_examination.examination_id)
	active_examination = null
	
	return true
	
func select_decision(decision: DecisionData) -> bool:
	if (selected_decision != null): return false
	if (!available_decisions.has(decision)): return false
	
	selected_decision = decision
	
	if(decision.procedure != null):
		active_procedure = decision.procedure
	
	return true

func complete_procedure(score: float) -> bool:
	if (active_procedure == null): return false
	if (procedure_completed == true): return false
	
	procedure_score = clampf(score, 0.0, 1.0)
	procedure_completed = true
	
	return true

#helpers

func is_examination_available(exam: ExaminationData) -> bool:
	if exam == null:
		return false
		
	var allowed_by_tool := false

	for tool in appointment.available_tools:
		if tool != null and tool.examinations.has(exam):
			allowed_by_tool = true
			break
	
	if not allowed_by_tool:
		return false
		
	for finding in appointment.examination_findings:
		if finding != null and finding.examination == exam:
			return true

	return false

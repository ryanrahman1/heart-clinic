class_name PatientChart
extends RefCounted

var initial_sheet : ExamSheetData # intial sheet data
var interview_notes : Array[String] # notes collected from questions
var examination_findings: Array[ObservationData] # findings from exams

func initialize(sheet: ExamSheetData) -> void:
	initial_sheet = sheet
	interview_notes.clear()
	examination_findings.clear()

func add_interview_note(note: String) -> void:
	if(note.is_empty()): return # check if it exists
	if(interview_notes.has(note)): return # check if its a dupe
	# insert
	interview_notes.append(note)

func add_observation(observation: ObservationData) -> void:
	if(observation == null): return #check if exsts
	if(examination_findings.has(observation)): return #check if dupe
	#insert
	examination_findings.append(observation)

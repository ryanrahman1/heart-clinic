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

func get_display_text() -> String:
	var lines: PackedStringArray = []
	if initial_sheet != null:
		if not initial_sheet.reason_for_visit.is_empty():
			lines.append("[Prescreening: %s]" % initial_sheet.reason_for_visit)
		for symptom in initial_sheet.initial_symptoms:
			if not symptom.is_empty():
				lines.append("- %s" % symptom)
		if initial_sheet.medical_history.size() > 0:
			lines.append("[Medical History:]")
			for entry in initial_sheet.medical_history:
				if not entry.is_empty():
					lines.append("- %s" % entry)
		if initial_sheet.initial_notes.size() > 0:
			lines.append("[Initial Notes:]")
			for note in initial_sheet.initial_notes:
				if not note.is_empty():
					lines.append("- %s" % note)
		if initial_sheet.hints.size() > 0:
			lines.append("[Hints:]")
			for hint in initial_sheet.hints:
				if not hint.is_empty():
					lines.append("- %s" % hint)
	if interview_notes.size() > 0:
		lines.append("[Interview Notes:]")
		for note in interview_notes:
			if not note.is_empty():
				lines.append("- %s" % note)
	if examination_findings.size() > 0:
		lines.append("[Examination Findings:]")
		for obs in examination_findings:
			if obs == null:
				continue
			var entry := obs.display_name
			if not obs.description.is_empty():
				entry += ": " + obs.description.strip_edges()
			lines.append("- %s" % entry)
	return "\n".join(lines)

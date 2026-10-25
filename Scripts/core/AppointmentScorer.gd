class_name AppointmentScorer
extends RefCounted

const CATEGORY_WEIGHT := 25.0 #each of 4 cats contribute up to 25%
const PROCEDURE_WEIGHT := 0.4 #up to 40 percent of decision cat

func calculate_comfort_score(session: AppointmentSession) -> float:
	var comf_delta := session.patient_state.cumulative_comfort_delta
	var comf_target := session.appointment.comfort_target
	
	var cl_val := comf_delta / comf_target # value to clamp, delta
	return clampf(cl_val, 0.0, 1.0)

func calculate_trust_score(session: AppointmentSession) -> float:
	var trust_delta := session.patient_state.cumulative_trust_delta
	var trust_target := session.appointment.trust_target
	
	var cl_val := trust_delta / trust_target
	return clampf(cl_val, 0.0, 1.0)
	
func calculate_evidence_score(session: AppointmentSession) -> float:
	
	var total_evidence_val := 0.0
	
	#first calc interview evidence
	for q in session.available_questions:
		if (session.asked_question_ids.has(q.question_id)):
			total_evidence_val += q.evidence_value
	
	#second calc exam evidence
	for e in session.appointment.examination_findings:
		if e == null or e.examination == null: continue
		if (session.completed_examination_ids.has(e.examination.examination_id)):
			total_evidence_val += e.evidence_value
			
	# now normalize
	var cl_val := total_evidence_val / session.appointment.evidence_target
	return clampf(cl_val, 0.0, 1.0)
	
func calculate_decision_score(session: AppointmentSession) -> float:
	if (!session.selected_decision): return 0.0
	var cl_val := 0.0
	if session.selected_decision.procedure != null:
		cl_val = (0.6*session.selected_decision.score) + (PROCEDURE_WEIGHT*session.procedure_score)
	else:
		cl_val = session.selected_decision.score
	
	return clampf(cl_val, 0.0, 1.0)

func calculate_total(session: AppointmentSession) -> float:
	var c := calculate_comfort_score(session)
	var t := calculate_trust_score(session)
	var e := calculate_evidence_score(session)
	var d := calculate_decision_score(session)
	var cl_val = CATEGORY_WEIGHT * (c + t + e + d)
	
	return clampf(cl_val, 0.0, 100.0)

func calculate_stars(total_score: float) -> int:
	var cl_val = ceili(total_score / 20)
	return clampi(cl_val, 1, 5)
	
func return_results(session: AppointmentSession) -> Dictionary:
	var c := calculate_comfort_score(session)
	var t := calculate_trust_score(session)
	var e := calculate_evidence_score(session)
	var d := calculate_decision_score(session)
	var cl_val := CATEGORY_WEIGHT * (c + t + e + d)
	var total := clampf(cl_val, 0.0, 100.0)
	
	var stars := calculate_stars(total)
	
	var results = {
		"comfort": c,
		"trust": t,
		"evidence": e,
		"decision": d,
		"total": total,
		"stars": stars
	}
	
	return results

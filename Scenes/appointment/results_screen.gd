extends CanvasLayer

@onready var stars_root: TextureRect = $TextureRect
@onready var results_label: Label = $Label

var _star_nodes: Array[TextureRect] = []

func _ready():
	visible = false
	_star_nodes = [
		$TextureRect/star1,
		$TextureRect/star2,
		$TextureRect/star3,
		$TextureRect/star4,
		$TextureRect/star5
	]
	_hide_stars()

func show_results(results: Dictionary) -> void:
	_hide_stars()
	var star_count := clampi(int(results.get("stars", 1)), 1, 5)
	stars_root.show()
	_star_nodes[star_count - 1].show()
	results_label.text = _format_results(results)
	show()

func close() -> void:
	hide()
	_hide_stars()

func _hide_stars() -> void:
	for star in _star_nodes:
		star.hide()

func _format_results(results: Dictionary) -> String:
	var comfort := int(round(float(results.get("comfort", 0.0)) * 100.0))
	var trust := int(round(float(results.get("trust", 0.0)) * 100.0))
	var evidence := int(round(float(results.get("evidence", 0.0)) * 100.0))
	var decision := int(round(float(results.get("decision", 0.0)) * 100.0))
	var total := int(round(float(results.get("total", 0.0))))
	return "Comfort: {c}\nTrust: {t}\nEvidence: {e}\nDecision: {d}\nTotal Score: {tot}".format({
		"c": comfort,
		"t": trust,
		"e": evidence,
		"d": decision,
		"tot": total
	})

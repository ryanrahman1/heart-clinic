extends CanvasLayer

signal make_decision_pressed

const CHART_SCALE := 2.15
const BASE_CHART_SIZE := Vector2(255.0, 364.0)
const BASE_LABEL_POS := Vector2(49.0, 80.0)
const BASE_LABEL_SIZE := Vector2(173.85, 232.0)

@onready var chart_bg: TextureRect = $Screen/ChartHolder/ChartBg
@onready var chart_label: Label = $Screen/ChartHolder/ChartLabel
@onready var chart_holder: Control = $Screen/ChartHolder
@onready var decision_btn: Button = $Screen/MakeDecisionButton

func _ready():
	visible = false
	decision_btn.pressed.connect(_on_decision_btn_pressed)

func _apply_chart_layout() -> void:
	var s := CHART_SCALE
	var chart_size := BASE_CHART_SIZE * s
	var holder_size := chart_holder.size
	if holder_size.x < 1.0:
		holder_size = Vector2(640.0, 720.0)
	var bg_topleft := holder_size * 0.5 - chart_size * 0.5
	chart_bg.position = bg_topleft
	chart_bg.size = chart_size
	chart_bg.z_index = 0
	chart_label.position = bg_topleft + BASE_LABEL_POS * s
	chart_label.size = BASE_LABEL_SIZE * s
	chart_label.custom_maximum_size = Vector2(BASE_LABEL_SIZE.x * s, -1)
	chart_label.z_index = 1

func open(chart: PatientChart) -> void:
	show()
	await get_tree().process_frame
	_apply_chart_layout()
	chart_label.text = chart.get_display_text()

func close() -> void:
	hide()

func _on_decision_btn_pressed() -> void:
	make_decision_pressed.emit()

extends CanvasLayer

signal finished(score: float)

enum Phase { INTRO, PLAYING, RESULTS }

@export var zoom_amount: float = 2.65
@export var chest_offset: Vector2 = Vector2(0, 115)
@export var match_duration: float = 10.0
@export var max_miss_distance: float = 130.0
@export var drag_start_offset: Vector2 = Vector2(240, 170)

@onready var screen: Control = $Screen
@onready var subviewport_container: SubViewportContainer = $Screen/SubViewportContainer
@onready var subviewport: SubViewport = $Screen/SubViewportContainer/SubViewport
@onready var zoom_root: Node2D = $Screen/SubViewportContainer/SubViewport/ZoomRoot
@onready var nurse_box: Control = $Screen/Overlay/NurseBox
@onready var target_tablet: Control = $Screen/Overlay/TargetTablet
@onready var drag_tablet: Control = $Screen/Overlay/DragTablet
@onready var time_label: Label = $Screen/Overlay/TimeLabel
@onready var start_btn: Button = $Screen/Overlay/StartButton
@onready var results_panel: Control = $Screen/Overlay/ResultsPanel
@onready var results_score: Label = $Screen/Overlay/ResultsPanel/ScoreLabel
@onready var continue_btn: Button = $Screen/Overlay/ResultsPanel/ContinueButton

var _phase: Phase = Phase.INTRO
var _time_left: float = 0.0
var _scene_root: Node2D

func _ready():
	visible = false
	start_btn.pressed.connect(_on_start_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	results_panel.hide()

func begin(scene_root: Node2D, _exam: ExaminationData) -> void:
	_scene_root = scene_root
	show()
	await get_tree().process_frame
	_sync_viewport_size()
	_setup_world_view()
	_reset_run()

func _sync_viewport_size() -> void:
	var sz := subviewport_container.size
	if sz.x > 1.0 and sz.y > 1.0:
		subviewport.size = Vector2i(int(sz.x), int(sz.y))

func _setup_world_view() -> void:
	for child in zoom_root.get_children():
		zoom_root.remove_child(child)
		child.free()
	var world = _scene_root.get_node("World")
	var bg_node = world.get_node("TextureRect")
	var pc = world.get_node("PatientContainer") as Node2D
	var bg_copy = bg_node.duplicate()
	zoom_root.add_child(bg_copy)
	if pc.get_child_count() > 0:
		var holder := Node2D.new()
		holder.name = "PatientHolder"
		holder.position = pc.position
		holder.scale = pc.scale
		var patient_copy = pc.get_child(0).duplicate()
		holder.add_child(patient_copy)
		zoom_root.add_child(holder)
	var chest_local: Vector2 = pc.position + chest_offset * pc.scale
	var vp_size := Vector2(subviewport.size)
	zoom_root.scale = Vector2(zoom_amount, zoom_amount)
	zoom_root.position = vp_size * 0.5 - chest_local * zoom_amount
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _reset_run() -> void:
	_phase = Phase.INTRO
	_time_left = match_duration
	time_label.text = "Time: {s}s".format({"s": int(ceil(_time_left))})
	time_label.hide()
	start_btn.show()
	nurse_box.show()
	results_panel.hide()
	drag_tablet.set_drag_enabled(false)
	_reset_drag_tablet()

func _reset_drag_tablet() -> void:
	drag_tablet.global_position = target_tablet.global_position + drag_start_offset

func _on_start_pressed() -> void:
	if _phase != Phase.INTRO:
		return
	_phase = Phase.PLAYING
	start_btn.hide()
	nurse_box.hide()
	drag_tablet.set_drag_enabled(true)
	time_label.show()

func _process(delta: float) -> void:
	if _phase != Phase.PLAYING:
		return
	_time_left -= delta
	time_label.text = "Time: {s}s".format({"s": maxi(0, int(ceil(_time_left)))})
	if _time_left <= 0.0:
		_end_run()

func _placement_score() -> float:
	var target_center := target_tablet.get_global_rect().get_center()
	var drag_center := drag_tablet.get_global_rect().get_center()
	var dist := target_center.distance_to(drag_center)
	return clampf(1.0 - dist / max_miss_distance, 0.0, 1.0) * 100.0

func _end_run() -> void:
	_phase = Phase.RESULTS
	drag_tablet.set_drag_enabled(false)
	var pct := _placement_score()
	results_score.text = "Accuracy: {p}%".format({"p": int(round(pct))})
	results_panel.show()

func _on_continue_pressed() -> void:
	if _phase != Phase.RESULTS:
		return
	var pct := _placement_score()
	hide()
	finished.emit(pct)

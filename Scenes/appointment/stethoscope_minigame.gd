extends CanvasLayer

signal finished(score: float)

enum Phase { INTRO, PLAYING, RESULTS }

@export var zoom_amount: float = 2.65
@export var chest_offset: Vector2 = Vector2(0, 115)
@export var cycle_duration: float = 1.35
@export var cycle_duration_min: float = 0.42
@export var match_duration: float = 15.0

@onready var screen: Control = $Screen
@onready var subviewport_container: SubViewportContainer = $Screen/SubViewportContainer
@onready var subviewport: SubViewport = $Screen/SubViewportContainer/SubViewport
@onready var zoom_root: Node2D = $Screen/SubViewportContainer/SubViewport/ZoomRoot
@onready var heart_zone: Control = $Screen/Overlay/HeartZone
@onready var listen_btn: Button = $Screen/Overlay/HeartZone/ListenButton
@onready var time_label: Label = $Screen/Overlay/TimeLabel
@onready var score_label: Label = $Screen/Overlay/ScoreLabel
@onready var start_btn: Button = $Screen/Overlay/StartButton
@onready var results_panel: Control = $Screen/Overlay/ResultsPanel
@onready var results_score: Label = $Screen/Overlay/ResultsPanel/ScoreLabel
@onready var continue_btn: Button = $Screen/Overlay/ResultsPanel/ContinueButton

var _phase: Phase = Phase.INTRO
var _time_left: float = 0.0
var _beat_phase: float = 0.0
var _points: int = 0
var _scene_root: Node2D

func _ready():
	visible = false
	start_btn.pressed.connect(_on_start_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	listen_btn.pressed.connect(_on_listen_pressed)
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
	_beat_phase = 0.0
	_points = 0
	time_label.text = "Time: {s}s".format({"s": int(ceil(_time_left))})
	score_label.text = "Score: 0"
	start_btn.show()
	results_panel.hide()
	listen_btn.hide()
	heart_zone.playing = false
	heart_zone.beat_phase = 0.0
	heart_zone.queue_redraw()

func _on_start_pressed() -> void:
	if _phase != Phase.INTRO:
		return
	_phase = Phase.PLAYING
	start_btn.hide()
	listen_btn.show()
	heart_zone.playing = true

func _on_listen_pressed() -> void:
	if _phase != Phase.PLAYING:
		return
	var zone := _current_zone()
	if zone == 0:
		_points += 10
	elif zone == 1:
		_points -= 4
	else:
		_points -= 8
	_points = maxi(_points, 0)
	score_label.text = "Score: " + str(_points)
	heart_zone.queue_redraw()

func _process(delta: float) -> void:
	if _phase != Phase.PLAYING:
		return
	_time_left -= delta
	var elapsed := match_duration - _time_left
	var period := lerpf(cycle_duration, cycle_duration_min, elapsed / match_duration)
	_beat_phase = fmod(_beat_phase + delta / period, 1.0)
	time_label.text = "Time: {s}s".format({"s": maxi(0, int(ceil(_time_left)))})
	heart_zone.playing = true
	heart_zone.beat_phase = _beat_phase
	heart_zone.queue_redraw()
	if _time_left <= 0.0:
		_end_run()

func _current_zone() -> int:
	var phase := _beat_phase
	if phase < 0.14 or phase > 0.86:
		return 0
	if phase < 0.26 or phase > 0.74:
		return 1
	return 2

func _end_run() -> void:
	_phase = Phase.RESULTS
	heart_zone.playing = false
	listen_btn.hide()
	var avg_period := (cycle_duration + cycle_duration_min) * 0.5
	var max_pts := (match_duration / avg_period) * 10.0
	var pct := clampf((_points / max_pts) * 100.0, 0.0, 100.0)
	results_score.text = "Score: {pts} ({pct}%)".format({"pts": _points, "pct": int(round(pct))})
	results_panel.show()

func _on_continue_pressed() -> void:
	if _phase != Phase.RESULTS:
		return
	var avg_period := (cycle_duration + cycle_duration_min) * 0.5
	var max_pts := (match_duration / avg_period) * 10.0
	var pct := clampf((_points / max_pts) * 100.0, 0.0, 100.0)
	hide()
	finished.emit(pct)

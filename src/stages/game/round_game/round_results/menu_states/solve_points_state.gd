class_name SolvePointsState
extends StackState

# normal counting speed
const _NORMAL_BETWEEN_TIME = 0.3
# normal anim speed
const _NORMAL_ANIM_SPEED = 1.0

# fast counting speed
const _FAST_BETWEEN_TIME = 0.1
# fast anim speed
const _FAST_ANIM_SPEED = 2.0

# threshold of points until fast animation is enabled
const _SPEED_POINT_THRESHOLD = 10


# timer between each point
@onready var _between_timer: Timer = $BetweenTimer

# counter for how many points were solved
var _points_solved := 0
# time delay between each point
var _timer_time: float

# whether listening for skip
var _listen_skip = true


func _ready() -> void:
	Signals.general_input.connect(_on_general_input)


func _on_general_input(_event):
	if is_active() and _listen_skip:
		_listen_skip = false
		for dyad in fsm().dyad_panels:
			dyad.skip_point_solving()
		_end_point_solving()


func activate() -> void:
	_listen_skip = true
	
	_between_timer.start(_NORMAL_BETWEEN_TIME)


## solve a point for each dyads
func _solve_point() -> void:
	
	# check if too many have been solved, if so, increase speed
	_points_solved += 1
	_timer_time = _NORMAL_BETWEEN_TIME
	var anim_speed = _NORMAL_ANIM_SPEED
	if _points_solved >= _SPEED_POINT_THRESHOLD:
		_timer_time = _FAST_BETWEEN_TIME
		anim_speed = _FAST_ANIM_SPEED
	
	var all_empty = true
	for dyad in fsm().dyad_panels:
		dyad = dyad as DyadResultsPanel
		dyad.set_anim_speed(anim_speed)
		
		# only solve if they are not already empty
		if dyad.get_remaining_points() > 0:
			all_empty = false
			_solve_dyad_point(dyad)
	
	# if all stacks were empty, finish
	if all_empty:
		_on_point_stack_empty()
	else:
		_between_timer.start(_timer_time)


## solve particular point of a single dyad
func _solve_dyad_point(dyad: DyadResultsPanel) -> void:
	
	var any_negative = dyad.solve_single_point(fsm().MATRIX_DATA)
	
	if any_negative:
		$RemPointAudio.play()
	else:
		$AddPointAudio.play()


func _on_point_stack_empty():
	if is_active():
		_end_point_solving()


func _end_point_solving():
	_listen_skip = false
	for dyad in fsm().dyad_panels:
		dyad = dyad as DyadResultsPanel
		var pxs = dyad.get_assigned_players()
		var true_scores: Array[int] = []
		var tmp = pxs.map(func(px): return fsm().round_stats[px].get_score())
		true_scores.assign(tmp)
		dyad.set_scores(true_scores)
	print_debug("finished_pointstack")


func _on_between_timer_timeout() -> void:
	if is_active():
		_solve_point()

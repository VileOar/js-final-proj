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

# counter for how many dyads finished their stacks
var _stacks_finished_counter = 0


func _ready() -> void:
	Signals.general_input.connect(_on_general_input)


func _on_general_input(_event):
	if is_active():
		for dyad in fsm().dyad_panels:
			dyad.skip_point_solving()
		end_point_solving()


func activate() -> void:
	_stacks_finished_counter = 0
	
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
		on_point_stack_empty()
	else:
		_between_timer.start(_timer_time)


## solve particular point of a single dyad
func _solve_dyad_point(dyad: DyadResultsPanel) -> void:
	
	var any_negative = dyad.solve_single_point(fsm().MATRIX_DATA)
	
	if any_negative:
		$RemPointAudio.play()
	else:
		$AddPointAudio.play()


func on_point_stack_empty():
	if is_active():
		_stacks_finished_counter += 1
		if _stacks_finished_counter >= fsm().dyad_panels.size(): # if all dyads finished their pointstacks
			end_point_solving()


func end_point_solving():
	print_debug("finished_pointstack")


func _on_between_timer_timeout() -> void:
	if is_active():
		_solve_point()

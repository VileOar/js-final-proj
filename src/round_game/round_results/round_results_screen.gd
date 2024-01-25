## screen displayed a the end of the round
##
## this script is in charge of solving each point accumulated in the round by this dyad and manage 
## each player's individual scores
extends MarginContainer
class_name RoundResultsScreen

## normal counting speed
const NORMAL_BETWEEN_TIME = 0.3
## normal anim speed
const NORMAL_ANIM_SPEED = 1.0

## fast counting speed
const FAST_BETWEEN_TIME = 0.1
## fast anim speed
const FAST_ANIM_SPEED = 2.0

## threshold of points until fast animation is enabled
const SPEED_POINT_THRESHOLD = 30

## signal emitted when this screen has finished solving points
signal finished_solving

## ref to the first dyad's results, shown in parallel with the other
@onready var _dyad1_results = %Dyad1 as DyadResultsPanel
## ref to the second dyad's results
@onready var _dyad2_results = %Dyad2 as DyadResultsPanel

## timer between each point
@onready var _between_timer = $BetweenTimer as Timer

## whether currently counting points
var _is_solving := false
## how many points counted
var _points_solved = 0
## the point stack for the first dyad
var _point_stack1 := []
## the point stack for the second dyad
var _point_stack2 := []


# Called when the node enters the scene tree for the first time.
func _ready():
	if SharedData.is_4player_mode():
		_dyad2_results.show()
	else:
		_dyad2_results.hide()
	
	_points_solved = 0
	_point_stack1 = []
	_point_stack2 = []


## starts solving each point for each player[br]
## it receives the point stack via a parameter (it does NOT fetch it anywhere)
func start_point_solving(dyad1_point_stack : Array, dyad2_point_stack : Array) -> void:
	_point_stack1 = dyad1_point_stack
	_point_stack2 = dyad2_point_stack
	
	_solve_point()


## solve a point for each dyads
func _solve_point() -> void:
	
	# if point stack is done, finish and stop
	if _point_stack1.is_empty() and (_point_stack2.is_empty() or !SharedData.is_4player_mode()):
		finished_solving.emit()
		return
	
	# increment counter
	_points_solved += 1
	var timer_time = NORMAL_BETWEEN_TIME
	if _points_solved > SPEED_POINT_THRESHOLD:
		timer_time = FAST_BETWEEN_TIME
		_dyad1_results.set_anim_speed(FAST_ANIM_SPEED)
		_dyad2_results.set_anim_speed(FAST_ANIM_SPEED)
	else:
		_dyad1_results.set_anim_speed(NORMAL_ANIM_SPEED)
		_dyad2_results.set_anim_speed(NORMAL_ANIM_SPEED)
	
	var matrix = SharedData.get_payoff_matrix() as PayoffMatrix
	
	# wow, this is spaghetti
	if !_point_stack1.is_empty():
		var point = _point_stack1.pop_back()
		_solve_dyad_point(point, _dyad1_results, 0, 1, matrix)
	# only process the second if four player
	if !_point_stack2.is_empty() and SharedData.is_4player_mode():
		var point = _point_stack2.pop_back()
		_solve_dyad_point(point, _dyad2_results, 2, 3, matrix)
	
	_between_timer.start(timer_time)


## solve particular point of a single dyad
func _solve_dyad_point(point : int, dyad : DyadResultsPanel, p1 : int, p2 : int, matrix : PayoffMatrix) -> void:
	## determine who gets what score based on point
	var payoffs_array = matrix.get_matrix_outcome(point) # get the corresponding payoffs array
	
	SharedData.add_player_score(p1, payoffs_array[0])
	SharedData.add_player_score(p2, payoffs_array[1])
	dyad.solve_single_point(
		point,
		SharedData.get_player_score(p1),
		payoffs_array[0],
		SharedData.get_player_score(p2),
		payoffs_array[1],
		)

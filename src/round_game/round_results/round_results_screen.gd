## screen displayed a the end of the round
##
## this script is in charge of solving each point accumulated in the round by this dyad and manage 
## each player's individual scores
extends MarginContainer
class_name RoundResultsScreen

## emited when the user clicks next round
signal next_round

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

## ref to the first dyad's results, shown in parallel with the other
@onready var _dyad1_results = %Dyad1 as DyadResultsPanel
## ref to the second dyad's results
@onready var _dyad2_results = %Dyad2 as DyadResultsPanel
## ref to the button to advance
@onready var _next_round_btn = %NextRoundBtn as Button

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

## initial score of player 1
var _dyad1_score = [0,0]
## initial score of player 2
var _dyad2_score = [0,0]


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
func start_point_solving(dyad1_point_stack : Array, dyad1_initial_score : Array, dyad2_point_stack : Array, dyad2_initial_score : Array) -> void:
	_dyad1_score = dyad1_initial_score
	_dyad2_score = dyad2_initial_score
	
	_point_stack1 = dyad1_point_stack
	_point_stack2 = dyad2_point_stack
	
	_solve_point()


## ready and stable to progress to next round
func _set_advanceable() -> void:
	_next_round_btn.disabled = false


## solve a point for each dyads
func _solve_point() -> void:
	
	# if point stack is done, finish and stop
	if _point_stack1.is_empty() and (_point_stack2.is_empty() or !SharedData.is_4player_mode()):
		_set_advanceable()
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
		_solve_dyad_point(point, _dyad1_results, _dyad1_score, matrix)
	# only process the second if four player
	if !_point_stack2.is_empty() and SharedData.is_4player_mode():
		var point = _point_stack2.pop_back()
		_solve_dyad_point(point, _dyad2_results, _dyad2_score, matrix)
	
	_between_timer.start(timer_time)


## solve particular point of a single dyad
func _solve_dyad_point(point : int, dyad : DyadResultsPanel, player_scores : Array, matrix : PayoffMatrix) -> void:
	## determine who gets what score based on point
	var payoffs_array = matrix.get_matrix_outcome(point) # get the corresponding payoffs array
	
	# these are NOT the actual data, they matter only to this UI
	player_scores[0] += payoffs_array[0]
	player_scores[1] += payoffs_array[1]
	dyad.solve_single_point(
		point,
		player_scores[0],
		payoffs_array[0],
		player_scores[1],
		payoffs_array[1],
		)


func _on_button_pressed():
	next_round.emit()

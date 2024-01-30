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
@onready var _dyad0_results = %Dyad0 as DyadResultsPanel
## ref to the second dyad's results
@onready var _dyad1_results = %Dyad1 as DyadResultsPanel
## ref to the button to advance
@onready var _next_round_btn = %NextRoundBtn as Button

## timer between each point
@onready var _between_timer = $BetweenTimer as Timer

## how many points counted
var _points_solved = 0
## the point stack for the first dyad
var _point_stack0 := []
## the point stack for the second dyad
var _point_stack1 := []

## the stats for this round[br]
## obtained externally, variable for cache
var _round_stats : Array

## counter for finished animations of dyad displays
var _dyad_animation_counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if SharedData.is_4player_mode():
		_dyad1_results.show()
	else:
		_dyad1_results.hide()
	
	_points_solved = 0
	_point_stack0 = []
	_point_stack1 = []


## starts solving each point for each player[br]
## it receives the point stack via a parameter (it does NOT fetch it anywhere)
func start_point_solving(round_stats : Array) -> void:
	
	_round_stats = round_stats
	
	_dyad0_results.set_scores(0, 0)
	_dyad1_results.set_scores(0, 0)
	
	_dyad_animation_counter = 0
	
	await get_tree().create_timer(1.0).timeout
	
	# calling this starts the sequence
	_solve_point()


## set the point stacks
func set_point_stacks(dyad0_point_stack : Array, dyad1_point_stack : Array) -> void:
	_point_stack0 = dyad0_point_stack
	_point_stack1 = dyad1_point_stack
	
	_dyad0_results.set_point_stack(dyad0_point_stack.size())
	_dyad1_results.set_point_stack(dyad1_point_stack.size())


## ready and stable to progress to next round
func _set_advanceable() -> void:
	_next_round_btn.disabled = false


## solve a point for each dyads
func _solve_point() -> void:
	
	# if point stack is done, finish and stop
	if _point_stack0.is_empty() and (_point_stack1.is_empty() or !SharedData.is_4player_mode()):
		# on end, start animating the stats
		var dyad_score = _round_stats[0].get_score() + _round_stats[1].get_score()
		_dyad0_results.animate_stats(_round_stats[0], _round_stats[1], dyad_score)
		# do the same for the other dyad
		dyad_score = _round_stats[2].get_score() + _round_stats[3].get_score()
		_dyad1_results.animate_stats(_round_stats[2], _round_stats[3], dyad_score)
		return
	
	# increment counter
	_points_solved += 1
	# change speed according to amount solved
	var timer_time = NORMAL_BETWEEN_TIME
	if _points_solved > SPEED_POINT_THRESHOLD:
		timer_time = FAST_BETWEEN_TIME
		_dyad0_results.set_anim_speed(FAST_ANIM_SPEED)
		_dyad1_results.set_anim_speed(FAST_ANIM_SPEED)
	else:
		_dyad0_results.set_anim_speed(NORMAL_ANIM_SPEED)
		_dyad1_results.set_anim_speed(NORMAL_ANIM_SPEED)
	
	# solve points
	
	# get matrix
	var matrix = SharedData.get_payoff_matrix() as PayoffMatrix
	
	# wow, this is spaghetti
	if !_point_stack0.is_empty():
		var point = _point_stack0.pop_back()
		_solve_dyad_point(point, _dyad0_results, matrix)
	# only process the second if four player
	if !_point_stack1.is_empty() and SharedData.is_4player_mode():
		var point = _point_stack1.pop_back()
		_solve_dyad_point(point, _dyad1_results, matrix)
	
	_between_timer.start(timer_time)


## solve particular point of a single dyad
func _solve_dyad_point(point : int, dyad : DyadResultsPanel, matrix : PayoffMatrix) -> void:
	## determine who gets what score based on point
	var payoffs_array = matrix.get_matrix_outcome(point) # get the corresponding payoffs array
	
	dyad.solve_single_point(
		point,
		payoffs_array[0],
		payoffs_array[1],
		)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

func _on_button_pressed():
	next_round.emit()


func _on_dyad_finished_animation() -> void:
	_dyad_animation_counter += 1
	if _dyad_animation_counter >= 2:
		await get_tree().create_timer(1.0).timeout
		var score0 = _round_stats[0].get_score() + _round_stats[1].get_score()
		var score1 = _round_stats[2].get_score() + _round_stats[3].get_score()
		var dyad0_wins = score0 > score1
		if score0 != score1:
			if dyad0_wins:
				_dyad0_results.set_win_lose(true)
				_dyad1_results.set_win_lose(false)
			else:
				_dyad0_results.set_win_lose(false)
				_dyad1_results.set_win_lose(true)
			await get_tree().create_timer(0.8).timeout
			
			if dyad0_wins:
				_dyad1_results.display_penalty()
			else:
				_dyad0_results.display_penalty()
		
		_set_advanceable()

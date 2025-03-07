## the points display for a single dyad of players
##
## responsible for setting the players from this dyad[br]
## must be set (from the outside) the points, player ids and such
extends MarginContainer
class_name DyadResultsPanel

signal finished_animation

@export var _score_number_scene: PackedScene

# -----

# ref to the container where the player labels are stored
@onready var _player_labels_container: HBoxContainer = %PlayerLabels
# ref to the payoff grid
@onready var _payoff_grid: PointOutcomeGrid = %PointOutcomeGrid
# ref to the player score holder
@onready var _player_scores_container: HBoxContainer = %PlayerScores

# ref to the stats list
@onready var _stats_list: StatsList = %StatsList

# ref to point stack
@onready var _point_stack: PointStack = %PointStack

# -----

var _player_ixs: Array[int]

# speed at which to play animations
var _anim_speed := 1.0

# the list of actual player scores
@onready var _player_scores := _player_scores_container.find_children("*", "PlayerScorePanel", false)

# the actual list of matrix outcome masks that represent points
var _outcomes_stack: Array[int]

# whether this dyad won or not
var _win: bool


func setup_panel(player_ix_list: Array[int], matrix_data: PayoffMatrix) -> void:
	_player_ixs = player_ix_list.duplicate()
	_player_ixs.sort()
	for ix in _player_labels_container.get_child_count():
		_player_labels_container.get_child(ix).get_child(0).text = "Player %s" % (player_ix_list[ix] + 1)
	
	_payoff_grid.set_payoffs(matrix_data)


## set the anim speed
func set_anim_speed(speed: float):
	_anim_speed = speed


func get_assigned_players() -> Array[int]:
	return _player_ixs.duplicate()


func get_remaining_points() -> int:
	return _outcomes_stack.size()


# -------------------
# || --- STATS --- ||
# -------------------

## manually set the scores
func set_scores(score_list: Array[int]):
	for ix in _player_scores.size():
		_player_scores[ix].set_score(score_list[ix])
	
	_stats_list.reset()


func set_stats(player_stats: Dictionary[int, PlayerStats], team_score: int):
	player_stats.sort()
	_stats_list.set_stats(player_stats.values(), team_score)


func set_win_lose(win: bool):
	_win = win
	_stats_list.set_win_lose(_win)


## start animating statistics for this dyad
func animate_stats() -> void:
	_stats_list.animate_stats()


func _on_stats_list_finished_animation() -> void:
	print_debug("stats anim finished")
	#finished_animation.emit()


# -------------------------
# || --- POINT STACK --- ||
# -------------------------

## manually set point stack
func set_point_stack(outcomes_stack: Array[int]) -> void:
	_outcomes_stack = outcomes_stack
	_point_stack.set_points(outcomes_stack.size())


## trigger ONCE the animation for solving a point[br]
## this screen doesn't need to know or add the actual score to data, it just needs to know what to diplay
## returns whether any player got negative score
func solve_single_point(matrix_data: PayoffMatrix) -> bool:
	
	var outcome_mask = _outcomes_stack.pop_back()
	var added_player_scores = matrix_data.get_matrix_outcome(outcome_mask)
	var any_negative = added_player_scores.any(func(v): return v < 0)
	
	_payoff_grid.trigger_outcome_anim(outcome_mask, _anim_speed)
	
	# remove one point from stack
	_point_stack.pop_point()
	
	for ix in _player_scores.size():
		# get the panel node
		var p_score = _player_scores[ix] as PlayerScorePanel
		# get the appropriate added player score
		var added_score = added_player_scores[ix]
		
		# spawn score indicator
		p_score.score_effect(_score_number_scene, added_score)
		# set the total scores on the player panels
		p_score.add_score(added_score)
	
	return any_negative


## spawn penalty numbers on this dyad and update display
func solve_penalty_if_loss(penalty_mul: float) -> void:
	if !_win:
		for score in _player_scores:
			score.penalty_effect(_score_number_scene, penalty_mul)
			score.mul_score(penalty_mul)


## skip all animation related to point solving
func skip_point_solving():
	_payoff_grid.stop_outcome_anim()
	_point_stack.clear_points()
	_outcomes_stack.clear()


## skip all animation related to displaying stats
func skip_stats_animation():
	_stats_list.skip_animation()

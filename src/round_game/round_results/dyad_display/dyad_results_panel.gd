## the points display for a single dyad of players
##
## responsible for setting the players from this dyad[br]
## must be set (from the outside) the points, player ids and such
extends MarginContainer
class_name DyadResultsPanel

signal finished_animation

@export var _score_number_scene : PackedScene

# -----

## ref to the payoff grid
@onready var _payoff_grid = %PointOutcomeGrid as PointOutcomeGrid
# refs to player panels
@onready var _p1_panel = %P1Panel as PlayerScorePanel
@onready var _p2_panel = %P2Panel as PlayerScorePanel

## ref to the stats list
@onready var _stats_list: StatsList = %StatsList

## ref to point stack
@onready var _point_stack: PointStack = %PointStack

# -----

## player 1 index of the dyad
@export var _player1_index := -1
## player 2 index of the dyad
@export var _player2_index := -1

## speed at which to play animations
var _anim_speed := 1.0


func _ready():
	_p1_panel.set_player(_player1_index)
	_p2_panel.set_player(_player2_index)
	
	_payoff_grid.set_payoffs(SharedData.get_payoff_matrix())


## set the anim speed
func set_anim_speed(speed : float):
	_anim_speed = speed


# -------------------
# || --- STATS --- ||
# -------------------

## manually set the scores
func set_scores(p1_score : int, p2_score : int):
	_p1_panel.set_score(p1_score)
	_p2_panel.set_score(p2_score)
	
	_stats_list.hide()


## start animating statistics for this dyad
func animate_stats(p1_stats: PlayerStats, p2_stats: PlayerStats, score: int) -> void:
	_stats_list.show()
	_stats_list.animate_stats(p1_stats, p2_stats, score)


func _on_stats_list_finished_animation() -> void:
	finished_animation.emit()


func set_win_lose(win_lose: bool) -> void:
	_stats_list.set_win_lose(win_lose)


# -------------------------
# || --- POINT STACK --- ||
# -------------------------

## manually set point stack
func set_point_stack(points : int) -> void:
	_point_stack.set_points(points)


## trigger ONCE the animation for solving a point[br]
## this screen doesn't need to know or add the actual score to data, it just needs to know what to diplay
func solve_single_point(outcome_mask : int, p1_added_score : int, p2_added_score : int):
	
	_payoff_grid.trigger_outcome_anim(outcome_mask, _anim_speed)
	
	# remove one point from stack
	_point_stack.pop_point()
	
	# spawn score indicator
	_p1_panel.spawn_number(get_parent(), _score_number_scene, p1_added_score)
	_p2_panel.spawn_number(get_parent(), _score_number_scene, p2_added_score)
	
	# set the total scores on the player panels
	_p1_panel.add_score(p1_added_score)
	_p2_panel.add_score(p2_added_score)

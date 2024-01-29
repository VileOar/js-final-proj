## the points display for a single dyad of players
##
## responsible for setting the players from this dyad[br]
## must be set (from the outside) the points, player ids and such
extends MarginContainer
class_name DyadResultsPanel

@export var _score_number_scene : PackedScene

# -----

## ref to the payoff grid
@onready var _payoff_grid = %PointOutcomeGrid as PointOutcomeGrid
## ref to player 1 panel
@onready var _p1_panel = %P1Panel as PlayerScorePanel
@onready var _p2_panel = %P2Panel as PlayerScorePanel

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


## manually set the scores
func set_scores(p1_score : int, p2_score : int):
	_p1_panel.set_score(p1_score)
	_p2_panel.set_score(p2_score)


## trigger ONCE the animation for solving a point[br]
## this screen doesn't need to know or add the actual score to data, it just needs to know what to diplay
func solve_single_point(outcome_mask : int, p1_added_score : int, p2_added_score : int):
	
	_payoff_grid.trigger_outcome_anim(outcome_mask, _anim_speed)
	
	# spawn score indicator
	var score = _score_number_scene.instantiate() as ScoreNumber
	var pos = _p1_panel.get_global_rect().get_center()
	score.start(pos, p1_added_score)
	get_parent().add_child(score)
	score = _score_number_scene.instantiate() as ScoreNumber
	pos = _p2_panel.get_global_rect().get_center()
	score.start(pos, p2_added_score)
	get_parent().add_child(score)
	
	# set the total scores on the player panels
	_p1_panel.add_score(p1_added_score)
	_p2_panel.add_score(p2_added_score)

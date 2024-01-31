## animate and indicate winner
extends MarginContainer
class_name PlayerScoreGraph

signal finished_animation

const INCREMENT_INTERVAL = 0.1
const NORMAL_COLOUR = "ff9166"
const FLASH_COLOUR = "ffe478"

@onready var _outer_panel: ColorRect = %OuterPanel
@onready var _player_label: Label = %PlayerLabel
@onready var _score_label: Label = %ScoreLabel
## timer between increments
@onready var _interval_timer: Timer = $IntervalTimer

## the top score among all players
var _top_score: int
## this player's score
var _my_score : int

## aux_variable vor animation
var _current_displayed: int = 0

func setup(player_id: int, target_score: int, highest_score: int) -> void:
	_top_score = highest_score
	_my_score = target_score
	_player_label.text = "Player %s" % [player_id + 1]


## start the animation sequence
func start_animation() -> void:
	_interval_timer.start(INCREMENT_INTERVAL)


## mark this as winner
func show_winner(show_hide: bool = false) -> void:
	_outer_panel.visible = show_hide


## set flash colour
func set_flash(flash: bool) -> void:
	_outer_panel.color = Color(FLASH_COLOUR if flash else NORMAL_COLOUR)


func _on_interval_timer_timeout() -> void:
	_current_displayed += 1
	if _current_displayed >= _my_score:
		_current_displayed = _my_score
		finished_animation.emit()
	else:
		_interval_timer.start(INCREMENT_INTERVAL)
	
	_score_label.text = str(_current_displayed)

## animate and indicate winner
extends MarginContainer
class_name PlayerEndScore

signal finished_animation

const INCREMENT_INTERVAL = 0.1
const NORMAL_COLOUR = "ff9166"
const FLASH_COLOUR = "ffe478"

@onready var _outer_panel: ColorRect = %OuterPanel
@onready var _player_label: Label = %PlayerLabel
@onready var _score_label: Label = %ScoreLabel

## this player's score
var _my_score : int

## aux_variable vor animation
var _current_displayed: int = 0

func setup(player_id: int, target_score: int) -> void:
	_my_score = target_score
	_player_label.text = "Player %s" % [player_id + 1]


## mark this as winner
func show_winner(show_hide: bool = false) -> void:
	_outer_panel.visible = show_hide


## set flash colour
func set_flash(flash: bool, col: Color) -> void:
	_outer_panel.color = col


func is_point_done() -> bool:
	return _current_displayed == _my_score


func get_current_score() -> int:
	return _current_displayed


func increment_point(skip_to_end: bool = false) -> bool:
	var done = false
	
	if skip_to_end:
		_current_displayed = _my_score
	else:
		_current_displayed += 1
	
	if _current_displayed >= _my_score:
		_current_displayed = _my_score
		done = true
	
	_score_label.text = str(_current_displayed)
	
	return done

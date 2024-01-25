## script containing data for the dyad game as well as references to relevant nodes and functions
##
## this script is not meant to control the logic of the game (that is for the fsm and states)[br]
## this script sets the environment of the game, setting the players in the dyad and serving as 
## provider of the interactions with ui and such
extends Control
class_name DyadGame

## signal reporting dyad is ready
signal stable

## reference to the state machine
@onready var _fsm = $StateMachine as DyadStateMachine

## reference to the Prompt Controller
@onready var _prompt_ui = %PromptUI as PromptUI
## reference to the Dyad Score Controller
@onready var _score_ui = %DyadScoreUI as DyadScoreUI
## reference to the list of PlayerUIs
@onready var _player_ui_list = %PlayerUIs.get_children()

# --- GAME DATA ---

## player 1 index of this dyad
@export var _player1_index := -1
## player 2 index of this dyad
@export var _player2_index := -1

## the stack of points accumulated by the dyad[br]
## each point is represented by a 2-bit number, identifying the binary choice of each player (coop
## or defect)
var _game_points : Array = []


func _ready():
	_fsm.replace_state("StoppedState")


## start-up sequence, does not actually start the dyad
func ready_dyad() -> void:
	# TODO: add some start animation
	stable.emit()
	_player_ui_list[0].set_player(_player1_index)
	_player_ui_list[1].set_player(_player2_index)


## start the state machine
func start_dyad() -> void:
	_fsm.replace_state("PromptState")


## stop the state machine
func stop_dyad() -> void:
	_fsm.replace_state("StoppedState")


# -----------------------------
# || --- PLAYER SETTINGS --- ||
# -----------------------------

## return the players in this dyad
func get_dyad_players() -> Array:
	var players = [_player1_index, _player2_index]
	players.sort()
	return players


# -----------------------
# || --- DYAD DATA --- ||
# -----------------------

## get the point stack
func get_dyad_point_stack()-> Array:
	return _game_points.duplicate()


## add a new point to the stack[br]
## it comes in the form of a 2bit value, as defined in the matrix Outcomes
func add_point(point_mask : int):
	if point_mask in Global.Outcomes.values():
		_game_points.append(point_mask)
		_score_ui.add_points()
	else:
		push_error("Tried to add an invalid matrix outcome")


## reset points
func reset_dyad_points() -> void:
	_game_points.clear()
	_score_ui.reset_points()


# ----------------------
# || --- UI STUFF --- ||
# ----------------------

## show or hide the prompt UI
func show_prompt_ui(show_hide : bool, direction : int) -> void:
	_prompt_ui.set_prompt(direction if show_hide else Global.Directions.NONE)


## show or hide player choices in UI
func show_answers_ui(show_hide : bool, answers : Array) -> void:
	for ix in _player_ui_list.size():
		if show_hide:
			_player_ui_list[ix].show_answer(answers[ix])
		else:
			_player_ui_list[ix].hide_answer()

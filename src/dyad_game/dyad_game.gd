## script containing data for the dyad game as well as references to relevant nodes and functions
##
## this script is not meant to control the logic of the game (that is for the fsm and states)[br]
## this script sets the environment of the game, setting the players in the dyad and serving as 
## provider of the interactions with ui and such
extends Control
class_name DyadGame

## reference to the state machine
@onready var _fsm = $StateMachine as DyadStateMachine

## reference to the Prompt Controller
@onready var _prompt_ui = %PromptUI as PromptUI

## reference to the list of PlayerUIs
@onready var _player_ui_list = %PlayerUIs.get_children()

# --- GAME DATA ---

## the stack of points accumulated by the dyad[br]
## each point is represented by a 2-bit number, identifying the binary choice of each player (coop
## or defect)
var game_points : int = 0


func _ready():
	# TODO: remove this
	start_dyad()


## start the state machine
func start_dyad() -> void:
	_fsm.replace_state("PromptState")


# -----------------------------
# || --- PLAYER SETTINGS --- ||
# -----------------------------


## set both players of the dyad
func set_dyad_players(player1 : int, player2 : int) -> void:
	pass # TODO:


## return the players in this dyad
func get_dyad_players() -> Array:
	return [0,1] # TODO: change


# ----------------------
# || --- UI STUFF --- ||
# ----------------------

## show or hide the prompt UI
func show_prompt_ui(show_hide : bool, direction : int) -> void:
	_prompt_ui.set_prompt(direction if show else Global.Directions.NONE)


## show or hide player choices in UI
func show_answers_ui(show_hide : bool, answers : Array) -> void:
	for ix in _player_ui_list.size():
		if show_hide:
			_player_ui_list[ix].show_answer(answers[ix])
		else:
			_player_ui_list[ix].hide_answer()

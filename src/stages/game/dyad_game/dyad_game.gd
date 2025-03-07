## script containing data for the dyad game as well as references to relevant nodes and functions
##
## this script is not meant to control the logic of the game (that is for the fsm and states)[br]
## this script sets the environment of the game, setting the players in the dyad and serving as 
## provider of the interactions with ui and such
## NOTE: This node assumes 2 players per dyad.
extends Control
class_name DyadGame

## signal reporting dyad is ready
signal stable

# reference to the state machine
@onready var _fsm = $StateMachine as DyadStateMachine
# ref to the ai "folder"[br]
# this is a node that holds ai players if necessary
@onready var _ai = $AI

# reference to the Prompt Controller
@onready var _prompt_ui = %PromptUI as PromptUI
# reference to the Dyad Score Controller
@onready var _point_stack: PointStack = %PointStack
# reference to the list of PlayerUIs
@onready var _player_ui_list = %PlayerUIs.get_children()

# --- GAME DATA ---

## list of player indices in this dyad
@export var _player_index_list: Array[int] = []

## the stack of points accumulated by the dyad[br]
## each point is represented by a 2-bit number, identifying the binary choice of each player (coop
## or defect)
var _game_points: Array = []

# counter for player uis that are in ready position
var _ready_players := 0


func _ready() -> void:
	_fsm.replace_state("StoppedState", [""]) # pass a non existent state to pop_until to pop all


## reset this dyad
func reset_dyad() -> void:
	_ready_players = 0
	_reset_dyad_points()


# ---------------------
# || --- OPENING --- ||
# ---------------------

## setup the dyad with the proper data
func setup_dyad(players_ix_list: Array[int]) -> void:
	_player_index_list = players_ix_list
	for i in _player_index_list.size():
		var px = _player_index_list[i]
		_player_ui_list[i].set_player(px)
		
		# add ai players if required
		if !InputManager.is_human_device(InputManager.get_player_device(px)):
			var ai = AIPlayer.new() as AIPlayer
			ai.set_player(px)
			_ai.call_deferred("add_child", ai)


## startup sequence, does not actually start the dyad
func intro_dyad() -> void:
	_fsm.push_state("IntroState")


## start the state machine
func start_dyad() -> void:
	_fsm.replace_state("PromptState", [""])


# ---------------------
# || --- CLOSURE --- ||
# ---------------------

## stop the state machine
func stop_dyad() -> void:
	_fsm.replace_state("StoppedState", [""])


## NOTE: called by fsm only[br]
## notify for a new prompt for all ai players
func notify_new_prompt(prompt: int) -> void:
	for ai in _ai.get_children():
		ai.on_new_prompt(prompt)


# -----------------------------
# || --- PLAYER SETTINGS --- ||
# -----------------------------

## return the players in this dyad
func get_dyad_players() -> Array:
	var players = _player_index_list.duplicate()
	players.sort()
	return players


# -----------------------
# || --- DYAD DATA --- ||
# -----------------------

## get the point stack
func get_dyad_game_points()-> Array:
	return _game_points.duplicate()


## add a new point to the stack[br]
## it comes in the form of a 2bit value, as defined in the matrix Outcomes
func add_point(point_mask: int) -> void:
	if point_mask in Global.Outcomes.values():
		_game_points.append(point_mask)
		_point_stack.push_point()
	else:
		push_error("Tried to add an invalid matrix outcome.")


## reset points
func _reset_dyad_points() -> void:
	_game_points.clear()
	_point_stack.clear_points()


# ----------------------
# || --- UI STUFF --- ||
# ----------------------

## show or hide the prompt UI
func show_prompt_ui(show_hide: bool, direction: int) -> void:
	_prompt_ui.set_prompt(direction if show_hide else Global.Directions.NONE)


## show or hide player choices in UI
func show_answers_ui(show_hide: bool, answers: Array) -> void:
	for ix in _player_ui_list.size():
		if show_hide:
			_player_ui_list[ix].show_answer(answers[ix])
		else:
			_player_ui_list[ix].hide_answer()


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------


func _on_intro_finished(_num_players) -> void:
	# sanity check that the numbers of players match
	if _num_players != _player_index_list.size():
		push_warning("SANITY FAILED: Number of ready player UIs does not match actual number of players.")
	
	# wait a second after animations finish
	await get_tree().create_timer(1.0).timeout
	
	stable.emit()

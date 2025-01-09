## script containing data for the dyad game as well as references to relevant nodes and functions
##
## this script is not meant to control the logic of the game (that is for the fsm and states)[br]
## this script sets the environment of the game, setting the players in the dyad and serving as 
## provider of the interactions with ui and such
extends Control
class_name DyadGame

## signal reporting dyad is ready
signal stable

# internal signal for when all players are ready
signal _all_players_ready

## reference to the state machine
@onready var _fsm = $StateMachine as DyadStateMachine
## ref to the ai "folder"[br]
## this is a node that holds ai players if necessary
@onready var _ai = $AI

## reference to the Prompt Controller
@onready var _prompt_ui = %PromptUI as PromptUI
## reference to the Dyad Score Controller
@onready var _point_stack: PointStack = %PointStack
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

# counter for player uis that are in ready position
var _ready_players := 0


func _ready():
	_fsm.replace_state("StoppedState")


## reset this dyad
func reset_dyad() -> void:
	_ready_players = 0
	_reset_dyad_points()
	# TODO: remove?
	#for ai in _ai.get_children():
		#ai.queue_free()


# ---------------------
# || --- OPENING --- ||
# ---------------------

## setup the dyad with the proper data
func setup_dyad(p1_index, p2_index) -> void:
	# set the correct player indices and set the graphics correctly
	_player1_index = p1_index
	_player_ui_list[0].set_player(_player1_index)
	_player2_index = p2_index
	_player_ui_list[1].set_player(_player2_index)
	
	# add ai players if required
	if !InputManager.is_human_device(InputManager.get_player_device(_player1_index)):
		var ai = AIPlayer.new() as AIPlayer
		ai.set_player(_player1_index)
		_ai.call_deferred("add_child", ai)
	if !InputManager.is_human_device(InputManager.get_player_device(_player2_index)):
		var ai = AIPlayer.new() as AIPlayer
		ai.set_player(_player2_index)
		_ai.call_deferred("add_child", ai)


## startup sequence, does not actually start the dyad
func ready_dyad() -> void:
	_ready_players = 0
	_player_ui_list[0].play_start_anim()
	_player_ui_list[1].play_start_anim()
	while _ready_players < 2:
		await _all_players_ready
	
	# wait a second after animations finish
	await get_tree().create_timer(1.0).timeout
	
	# loop await while until all ais are ready
	for ai in _ai.get_children():
		while !ai.is_node_ready():
			await ai.ready
	
	stable.emit()


## start the state machine
func start_dyad() -> void:
	_fsm.replace_state("PromptState")
	# TODO: remove, this should be done in round game
	#InputManager.enable(true)


# ---------------------
# || --- CLOSURE --- ||
# ---------------------

## stop the state machine
func stop_dyad() -> void:
	_fsm.replace_state("StoppedState")
	#InputManager.enable(false)


## NOTE: called by fsm only[br]
## notify for a new prompt for all ai players
func notify_new_prompt(prompt : int) -> void:
	for ai in _ai.get_children():
		ai.on_new_prompt(prompt)


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
func get_dyad_game_points()-> Array:
	return _game_points.duplicate()


## add a new point to the stack[br]
## it comes in the form of a 2bit value, as defined in the matrix Outcomes
func add_point(point_mask : int):
	if point_mask in Global.Outcomes.values():
		_game_points.append(point_mask)
		_point_stack.push_point()
	else:
		push_error("Tried to add an invalid matrix outcome")


## reset points
func _reset_dyad_points() -> void:
	_game_points.clear()
	_point_stack.clear_points()


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


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

func _on_player_ready_sequence() -> void:
	_ready_players += 1
	if _ready_players >= 2:
		_all_players_ready.emit()

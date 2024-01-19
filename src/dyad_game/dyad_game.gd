## script containing data for the dyad game as well as references to relevant nodes and functions
extends Control
class_name DyadGame

## the max number of players in the dyad (it's 2 duh)
const MAX_PLAYERS = 2

## reference to the Timer node
@onready var _timer : Timer = %Timer

## reference to the Prompt Controller
@onready var _ui_controller = %UIController as UIController

# --- GAME DATA ---

## dict of players, in which each key is a player identifier and the value is the current choice[br]
## the choice is temporary data
var _players := {}

## the stack of points accumulated by the dyad[br]
## each point is represented by a 2-bit number, identifying the binary choice of each player (coop
## or defect)
var game_points : int = 0

# --- TEMP DATA ---

## the current direction in the prompt
var _prompted_direction := Global.Directions.NONE


# -----------------------------
# || --- PLAYER SETTINGS --- ||
# -----------------------------

## check if player is part of this dyad
func check_player_dyad(player) -> bool:
	return _players.has(player)


## set both players of the dyad
func set_player_dyad(player1 : int, player2 : int) -> void:
	_players.clear()
	_players[player1] = null
	_players[player2] = null


# --------------------------
# || --- INTERACTIONS --- ||
# --------------------------

## set the direction prompt
func get_direction_prompt() -> int:
	return _prompted_direction


## set the direction prompt
func set_direction_prompt(direction : int) -> void:
	if direction >= 0: # failsafe
		_prompted_direction = direction
	_ui_controller.set_prompt(direction)


## add a new player choice to the existing ones
func add_player_choice(p_action : PlayerAction) -> void:
	var player = p_action.player_id()
	if check_player_dyad(player):
		_players[player] = p_action


## return the array of registered player actions
func get_player_actions() -> Array:
	var array = []
	for action in _players.values():
		array.append(action)
	return array


## clear players' choices
func _clear_player_choices() -> void:
	for player in _players.keys:
		_players[player] = Global.Directions.NONE


# -------------------
# || --- TIMER --- ||
# -------------------

## start timer
func start_timer(time) -> void:
	_timer.start(time)


## stop_timer
func stop_timer() -> void:
	_timer.stop()


## connect a node to the timer's signal
func connect_timer(callback : Callable) -> void:
	_timer.timeout.connect(callback)


## disconnect a node from the timer
func disconnect_timer(callback : Callable) -> void:
	_timer.timeout.disconnect(callback)


# ----------------------
# || --- UI STUFF --- ||
# ----------------------

## show or hide player choices in UI
func show_choices_ui(show : bool = true) -> void:
	pass # TODO: complete this


## shortcut to stop everything
func stop_everything() -> void:
	var no_dir = Global.Directions.NONE
	
	stop_timer() # stop the timer completely
	set_direction_prompt(Global.Directions.NONE) # hide the direction prompt
	_clear_player_choices() # clear all player's choices
	show_choices_ui(false)
	
	InputManager.enable(false) # disable player input

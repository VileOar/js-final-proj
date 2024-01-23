## state machine specifically for the dyad game
##
## this class only exists to define common methods and signals for the child states to use[br]
## instead of defining methods and connecting signals from each individual state, they are all here, 
## since states have ref to the machine anyway[br]
## also used to share data between state, but NEVER operate on it, it just stores and provides data
extends StackStateMachine
class_name DyadStateMachine

## the reference to the timer to use
## this timer is only relevant to the states, not the dyadgame script
@export var _timer : Timer

## reference to the dyad game controller
@onready var _dyad_game := get_parent() as DyadGame

## storing the answers[br]
## this should not be processed in any way, that is for the prompt state
var _answers_cache : Array = []


# -------------------------
# || --- PLAYER DATA --- ||
# -------------------------
# these "events" will be managed with explicit function calls
# they probably should be done via signals, but whatever


## get the players in the dyad
func get_dyad_players() -> Array:
	return _dyad_game.get_dyad_players()


## write answers to cache
func write_answers(answers : Array):
	_answers_cache = answers.duplicate()


## return the cache of answers
func get_registered_answers() -> Array:
	return _answers_cache.duplicate()


## resets the registered answers
func reset_answers_cache() -> void:
	_answers_cache.clear()


## adds a new dyad point based on the answers, sorted by player index
func add_dyad_point(point : int) -> void:
	_dyad_game.add_point(point)


# -------------------
# || --- TIMER --- ||
# -------------------

## start of stop the timer, with an optional duration parameter
func start_stop_timer(start : bool, time := -1.0) -> void:
	if Utils.nullcheck(_timer):
		if start:
			_timer.start(time)
		else:
			_timer.stop()
	else:
		push_error("Timer reference is null")


## function to either connect or diconnect to timer
func connect_disconnect_timer(try_connect : bool, callback : Callable) -> int:
	if Utils.nullcheck(_timer):
		if try_connect:
			return _timer.connect("timeout", callback)
		else:
			_timer.disconnect("timeout", callback)
			return OK
	else:
		push_error("Timer reference is null")
		return -1


# ----------------------
# || --- UI STUFF --- ||
# ----------------------

## show or hide the prompt UI
func show_prompt_ui(show : bool, direction : int) -> void:
	_dyad_game.show_prompt_ui(show, direction)


## show or hide player choices in UI
func show_answers_ui(show : bool, answers : Array) -> void:
	_dyad_game.show_answers_ui(show, answers)


## shortcut to stop everything
func stop_everything() -> void:	
	start_stop_timer(false) # stop the timer completely
	show_prompt_ui(false, Global.Directions.NONE)
	show_answers_ui(false, [])
	
	InputManager.enable(false) # disable player input

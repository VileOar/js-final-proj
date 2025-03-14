## state for when time-dependent processing is happening (playing animations, creating nodes, ...)
##
## the enter method starts the anim from beginning, while the exit method stops the anim and makes
## sure everything is 
extends StackState
class_name IntroState

## always emited on exiting this state
signal intro_end(num_players)

# ref to the player uis to start and wait for animation
@onready var _player_uis: HBoxContainer = %PlayerUIs
# ref to the ai "folder"[br]
# this is a node that holds ai players if necessary
@onready var _ai = %AI

# counter for player uis that are in ready position
var _ready_players := 0

var _listen_skip = true


func _ready() -> void:
	for pui in _player_uis.get_children():
		(pui as PlayerUI).ready_sequence.connect(_on_player_ready_sequence)
	
	Signals.general_input.connect(_on_general_input)


func activate():
	_listen_skip = true
	_ready_players = 0
	for pui in _player_uis.get_children():
		pui = pui as PlayerUI
		pui.idle_anim()
		pui.play_start_anim()


func deactivate():
	# loop await while until all ais are ready
	for ai in _ai.get_children():
		while !ai.is_node_ready():
			await ai.ready
	
	intro_end.emit(_ready_players)


# function when a player presses to skip intro animation
func _skip() -> void:
	_ready_players = 0
	for pui in _player_uis.get_children():
		pui.idle_anim() # make sure they are in their final anim state
		_ready_players += 1
	
	pop_state(["StoppedState"])


func _on_general_input(_event):
	if is_active() and _listen_skip:
		_listen_skip = false
		_skip()


func _on_player_ready_sequence() -> void:
	if is_active():
		_ready_players += 1
		if _ready_players >= _player_uis.get_child_count():
			_final_setup()


func _final_setup() -> void:
	_listen_skip = false
	
	# if this is not active after waiting ignore the rest
	if is_active():
		pop_state(["StoppedState"])

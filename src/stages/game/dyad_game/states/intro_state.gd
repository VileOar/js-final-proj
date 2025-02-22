## state for when time-dependent processing is happening (playing animations, creating nodes, ...)
##
## the enter method starts the anim from beginning, while the exit method stops the anim and makes
## sure everything is 
extends StackState
class_name IntroState

## always emited on exiting this state
signal stable(num_players)
# internal signal for when all players are ready
signal _all_players_ready

# ref to the player uis to start and wait for animation
@onready var _player_uis: HBoxContainer = %PlayerUIs

# counter for player uis that are in ready position
var _ready_players := 0


func _ready() -> void:
	for pui in _player_uis.get_children():
		(pui as PlayerUI).ready_sequence.connect(_on_player_ready_sequence)


func enter():
	_ready_players = 0
	for pui in _player_uis.get_children():
		# TODO: call a stop anim on pui
		(pui as PlayerUI).play_start_anim()
	# TODO: copy the sequence from dyad_game


func _on_player_ready_sequence() -> void:
	_ready_players += 1
	if _ready_players >= _player_uis.get_child_count():
		_all_players_ready.emit()

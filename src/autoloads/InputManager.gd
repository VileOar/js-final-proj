## this node is responsible for handling player input
##
## this is strictly for discerning (or disabling) input from the various players
extends Node


## whether this autoload should listen for input (and send signals) or not
var _listening = false

## map of players and input devices: -1 for KBM, 0-7 for gamepads; array indices are the player indices
var _player_devices = []


## enable or disable input listening
func enable(en : bool = true) -> void:
	_listening = en


## whether player input is enabled or not
func is_listening() -> bool:
	return _listening


## map a player to a device
func add_player_device(player : int, device : int):
	while player >= _player_devices.size():
		_player_devices.append(-2) # add null player device if the previous ones had not yet been filled
	_player_devices[player] = device


func _unhandled_input(event):
	if _listening and event.is_action_type():
		var device = -2
		if event is InputEventJoypadButton: # if it came from a connected gamepad, it has a device
			device = (event as InputEventJoypadButton).device
		else: # otherwise, it's interpreted as the KBM
			device = -1
		Signals.input_player_action.emit(_get_player_by_device(device), event)


## return a player by device
func _get_player_by_device(device : int) -> int:
	return _player_devices.find(device)

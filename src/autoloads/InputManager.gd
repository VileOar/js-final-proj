## this node is responsible for handling player input
##
## this is strictly for discerning (or disabling) input from the various players
extends Node


## whether this autoload should listen for input (and send signals) or not
var _listening = false

## map of players and input devices: -1 for KBM, 0-7 for gamepads; array indices are the player indices
var _player_devices = [-2, -2, -2, -2]


## enable or disable input listening
func enable(en : bool = true) -> void:
	_listening = en


## whether player input is enabled or not
func is_listening() -> bool:
	return _listening


## map a player to a device
func add_player_device(player : int, device : int):
	if validate_player(player) and device_free(device):
		_player_devices[player] = device
	else:
		push_error("Tried adding invalid player index or device is already in use")
		get_tree().quit()


## get the device for a player
func get_player_device(player : int):
	return _player_devices[player]


## check if player is a valid index:
func validate_player(player : int) -> bool:
	return player >= 0 and player < _player_devices.size()


## check if device is human controlled or not
func is_human_device(device : int) -> bool:
	return device >= -1 and device < 8 # any other value is to be taken as AI


## check if this device is already registered to a player (if it is within range of valid devices)
func device_free(device : int) -> bool:
	if !is_human_device(device) or _get_player_by_device(device) == -1: # free if actually free or if AI
		return true
	else:
		return false


func _unhandled_input(event):
	if _listening and event.is_action_type() and event.is_pressed():
		var device = -2
		if event is InputEventJoypadButton: # if it came from a connected gamepad, it has a device
			device = (event as InputEventJoypadButton).device
		else: # otherwise, it's interpreted as the KBM
			event.device = -1 # cheating a little
			device = -1
		Signals.input_player_action.emit(_get_player_by_device(device), event)


## return a player by device
func _get_player_by_device(device : int) -> int:
	return _player_devices.find(device)

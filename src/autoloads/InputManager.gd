## this node is responsible for handling player input
##
## this is strictly for discerning (or disabling) input from the various players
extends Node

## the ide value for AI players
const AI_DEVICE = -2

## enum for device type
enum DeviceType {
	AI,
	KBM,
	JOYPAD,
}

# whether this autoload should listen for input (and send signals) or not
var _listening = false

# map of players and input devices: -1 for KBM, 0-7 for gamepads; array indices are the player indices
var _player_devices = []


## enable or disable input listening
func enable(en: bool = true) -> void:
	_listening = en


## whether player input is enabled or not
func is_listening() -> bool:
	return _listening


## map a player to a device
func add_player_device(player: int, device : int):
	if _validate_player(player) and device_free(device):
		while player >= _player_devices.size():
			_player_devices.append(AI_DEVICE)
		_player_devices[player] = device
	else:
		push_error("CRITICAL: Tried adding invalid player index or device is already in use. Quitting game.")
		get_tree().quit()


## get the device for a player
func get_player_device(player: int):
	if 0 <= player and player < _player_devices.size():
		return _player_devices[player]
	return AI_DEVICE


## return the type of device based on its id
func get_device_type(device: int) -> DeviceType:
	if is_human_device(device):
		return DeviceType.KBM if device == -1 else DeviceType.JOYPAD
	else:
		return DeviceType.AI


## check if device is human controlled or not
func is_human_device(device: int) -> bool:
	return device >= -1 and device < 8 # any other value is to be taken as AI


## check if this device is already registered to a player (if it is within range of valid devices)
func device_free(device: int) -> bool:
	if !is_human_device(device) or _get_player_by_device(device) == -1: # free if actually free or if AI
		return true
	else:
		return false


func _input(event) -> void:
	if event.is_pressed():
		# send general event when something is pressed (use case ex: for skipping)
		Signals.general_input.emit(event)
		if _listening and event.is_action_type():
			var device = AI_DEVICE
			if event is InputEventJoypadButton: # if it came from a connected gamepad, it has a device
				device = (event as InputEventJoypadButton).device
			else: # otherwise, it's interpreted as the KBM
				event.device = -1 # cheating a little
				device = -1
			Signals.input_player_action.emit(_get_player_by_device(device), event)


# check if player is a valid index [br]
# this is just to make sure that the player is not negative, as that would be a negative ix in the array
func _validate_player(player: int) -> bool:
	return player >= 0


# return a player by device
func _get_player_by_device(device: int) -> int:
	return _player_devices.find(device)

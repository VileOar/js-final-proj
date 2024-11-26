## class that manages the player select screen
##
## must be able to map players to controllers and set the parameters to start the game, like number
## of players
extends Control
class_name PlayerSelectMenu

## ref to the packed scene of the round game
@export var _round_scene : PackedScene
## ref to the packed scene of title screen
@export var _title_scene : PackedScene

## ref to 2 player btn
@onready var _2player_btn = %TwoPlayerBtn
## ref to 4 player btn
@onready var _4player_btn = %FourPlayerBtn
## button group for the player count buttons
var _player_mode_btn_group : ButtonGroup

## ref to the list of device selectors
@onready var _player_selectors = %PlayerSelectors

## which player is listening for a device
var _listening_player : DeviceSelector = null


func _ready():
	# connect to the input signal
	Signals.input_player_action.connect(_on_signals_input_player_action)
	
	# reset listening player
	_listening_player = null
	
	# setup the button group
	_player_mode_btn_group = ButtonGroup.new()
	_2player_btn.button_group = _player_mode_btn_group
	_4player_btn.button_group = _player_mode_btn_group
	_4player_btn.set_pressed_no_signal(true)
	_player_mode_btn_group.pressed.connect(_on_player_mode_changed)
	
	# setup the device selectors
	for player in _player_selectors.get_child_count():
		var selector = _player_selectors.get_child(player) as DeviceSelector
		
		selector.set_player_id(player)
		selector.set_device(InputManager.get_player_device(player)) # get whatever had been there, default is AI
		selector.toggled_listen.connect(_on_device_selector_toggled_listen.bind(selector))
		
		selector.release_listen()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Signals.input_player_action.disconnect(_on_signals_input_player_action)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

## callback for when one of the player mode buttons is pressed
func _on_player_mode_changed(btn : BaseButton):
	var mode_4p = true
	if btn == _2player_btn:
		mode_4p = false
	SharedData.set_player_mode(mode_4p)
	
	# hide or show last two player selectors
	if mode_4p:
		_player_selectors.get_child(-1).show()
		_player_selectors.get_child(-2).show()
	else:
		_player_selectors.get_child(-1).hide()
		_player_selectors.get_child(-2).hide()


## callback to a request to listen for devices by one of the device selectors
func _on_device_selector_toggled_listen(onoff : bool, selector : DeviceSelector):
	for other in _player_selectors.get_children():
		if !(onoff and other == selector): # only release for others
			other.release_listen()
	
	if onoff:
		InputManager.enable()
		_listening_player = selector
	else:
		InputManager.enable(false)
		_listening_player = null


## callback to input event from manager
func _on_signals_input_player_action(_player : int, event : InputEvent):
	if is_instance_valid(_listening_player) and event.is_pressed():
		if InputManager.device_free(event.device):
			_listening_player.forward_input_event(event)


func _on_button_pressed():
	get_tree().change_scene_to_packed(_round_scene)


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_packed(_title_scene)

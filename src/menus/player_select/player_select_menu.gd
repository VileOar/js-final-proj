## class that manages the player select screen
##
## must be able to map players to controllers and set the parameters to start the game, like number
## of players
extends Control
class_name PlayerSelectMenu

# ref to 2 player btn
@onready var _2player_btn = %TwoPlayerBtn
# ref to 4 player btn
@onready var _4player_btn = %FourPlayerBtn
# button group for the player count buttons
var _player_mode_btn_group: ButtonGroup

# ref to the list of device selectors
@onready var _player_selectors = %PlayerSelectors

@onready var _instructions_holder: Control = %InstructionsHolder


# which player is listening for a device
var _listening_player: DeviceSelector = null
# local variable identifying how many players, later used to initialise the actual game data
# if true, 4 players, 2 if false
var _mode_4p = true


func _ready():
	# connect to the input signal
	Signals.input_player_action.connect(_on_signals_input_player_action)
	
	# reset listening player
	_listening_player = null
	
	# setup the button group for selecting how many players
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


# method to actually go to game scene
func _go_to_game() -> void:
	SceneSwitcher.switch_topscene_id("game_scene")


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

# callback for when one of the player mode buttons is pressed
func _on_player_mode_changed(btn: BaseButton):
	_mode_4p = btn == _4player_btn # check which button was pressed
	
	var players = 4 if _mode_4p else 2 # aux to following loop
	for i in _player_selectors.get_children().size():
		if i < players: # show the selector for the current num of players
			_player_selectors.get_child(i).show()
		else: # hide the others
			_player_selectors.get_child(i).hide()


# callback to a request to listen for devices by one of the device selectors
func _on_device_selector_toggled_listen(onoff: bool, selector: DeviceSelector):
	for other in _player_selectors.get_children():
		if !(onoff and other == selector): # only release for others
			other.release_listen()
	
	if onoff:
		InputManager.enable()
		_listening_player = selector
	else:
		InputManager.enable(false)
		_listening_player = null


# callback to input event from manager
func _on_signals_input_player_action(_player: int, event: InputEvent) -> void:
	if is_instance_valid(_listening_player) and event.is_pressed():
		if InputManager.device_free(event.device):
			_listening_player.forward_input_event(event)


func _on_start_btn_pressed() -> void:
	SharedData.setup_dyads_playerdata(4 if _mode_4p else 2)
	if SharedData.get_settings().show_instructions:
		_instructions_holder.show()
	else:
		_go_to_game()


func _on_back_btn_pressed() -> void:
	SceneSwitcher.switch_topscene_id("title_screen")


func _on_instructions_back_pressed() -> void:
	_instructions_holder.hide()


func _on_instructions_start_pressed() -> void:
	_go_to_game()

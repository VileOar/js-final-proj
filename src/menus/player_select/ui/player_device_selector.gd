## UI widget responsible for mapping a player to a device or AI
##
## should allow to listen for an input from a connected device or set as AI
extends MarginContainer
class_name DeviceSelector

## signal to request that this widget be set to listen to input (or release listening)
signal toggled_listen(onoff)

## ref to player identifier
@onready var _player_label = %PlayerId

## ref to the group of nodes with the device identification
@onready var _device_id: HBoxContainer = %DeviceID
## ref to device identifier text
@onready var _device_ui = %Device
## the device icon node
@onready var _device_icon: Control = %DeviceIcon

## temp text to display when waiting for input
@onready var _input_msg: Label = %InputMsg

## ref to the listen button
@onready var _listen_btn = %ListenButton

## the sprite with the icons
@onready var _device_sprite: Sprite2D = %DeviceSprite
@onready var _player_sprite: Sprite2D = %PlayerSprite

## the player id this widget is mapped to
var _player_id = -1


## set this widget's player
func set_player_id(player: int):
	_player_id = player
	_player_label.text = "Player %s" % [player + 1]
	_player_sprite.texture = Global.get_player_texture(player)


## set the device for this player
func set_device(device: int) -> void:
	InputManager.add_player_device(_player_id, device)
	
	_device_ui.show()
	_device_icon.show()
	
	var device_type = InputManager.get_device_type(device)
	match device_type:
		InputManager.DeviceType.KBM:
			_device_sprite.frame = 1
			_device_ui.hide()
		InputManager.DeviceType.JOYPAD:
			_device_sprite.frame = 0
			_device_ui.text = "%s" % [device]
		InputManager.DeviceType.AI:
			_device_icon.hide()
			_device_ui.text = "CPU"


## cleanup function for when another selector requests listening for a device
func release_listen():
	# untoggle the button without sending the signal
	_listen_btn.set_pressed_no_signal(false)
	# do this here again just to be sure
	_device_id.show()
	_input_msg.hide()


## callback to receive an input event[br]
## this is not necessarily connected to a signal (hence the name)
## it is instead managed by its controller[br]
## in this function, the device that originated this is implicitly free
func forward_input_event(event: InputEvent):
	set_device(event.device)
	
	# at the end, stop listening
	_listen_btn.button_pressed = false


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------


func _on_device_button_toggled(toggled_on):
	toggled_listen.emit(toggled_on)
	if toggled_on:
		_device_id.hide()
		_input_msg.show()
	else:
		_device_id.show()
		_input_msg.hide()


func _on_ai_button_pressed():
	toggled_listen.emit(false)
	set_device(-2)

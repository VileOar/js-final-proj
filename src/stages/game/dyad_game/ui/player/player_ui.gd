## UI node which controls displaying information about a player
##
## responsible for identifying the player, revealing their answers, ...
extends MarginContainer
class_name PlayerUI

## emitted when the startup sequence is complete
signal ready_sequence

var _can_sound : bool

## ref to the player label
@onready var _player_label = %Identifier as Label
## ref to the answer label
@onready var _answer = %Answer as AnimatedAnswer
## player sprite
@onready var _player_sprite: Sprite2D = %Player


## set the player identification
func set_player(player: int):
	_can_sound = player == 0
	_player_label.text = "Player %s" % [player + 1]
	_player_sprite.texture = Global.get_player_texture(player)


## play start animation
func play_start_anim() -> void:
	%AnimCop.play("drink_slam")
	
	await %AnimCop.animation_finished
	
	%AnimCop.play("sit")
	ready_sequence.emit()


## reveal or hide the answer
func show_answer(answer : PlayerAnswer):
	_answer.animate_answer(answer)


## hide the amswer
func hide_answer():
	_answer.hide_answer()


func _play_drink_sound() -> void:
	if _can_sound:
		$DrinkSound.play()


func _play_slam_sound() -> void:
	if _can_sound:
		$SlamSound.play()

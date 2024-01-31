## UI node which controls displaying information about a player
##
## responsible for identifying the player, revealing their answers, ...
extends MarginContainer
class_name PlayerUI

## ref to the player label
@onready var _player_label = %Identifier as Label
## ref to the answer label
@onready var _answer = %Answer as AnimatedAnswer
## player sprite
@onready var _player_sprite: Sprite2D = %Player


## set the player identification
func set_player(player : int):
	_player_label.text = "Player %s" % [player + 1]
	_player_sprite.texture = Global.get_player_texture(player)


## play start animation
func play_start_anim() -> void:
	%AnimCop.play("drink_slam")


## reveal or hide the answer
func show_answer(answer : PlayerAnswer):
	_answer.animate_answer(answer)


## hide the amswer
func hide_answer():
	_answer.hide_answer()


func _on_anim_cop_animation_finished(anim_name: StringName) -> void:
	if anim_name == "drink_slam":
		%AnimCop.play("sit")

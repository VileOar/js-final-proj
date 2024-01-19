## object to define player action
##
## identifies player and their choices (cooperation and the actual direction pressed)
extends RefCounted
class_name PlayerAction

var _player_id : int = -1
var _direction : int = Global.Directions.NONE
var _coop : bool
var _correct : bool # this is always set later when the answer is processed


func _init(player_id : int, direction : int, cooperated : bool):
	_player_id = player_id
	_direction = direction
	_coop = cooperated


func player_id() -> int:
	return _player_id


func direction() -> int:
	return _direction


func cooperated() -> bool:
	return _coop


func set_correct(correct : bool) -> void:
	_correct = correct


func is_correct() -> bool:
	return _correct

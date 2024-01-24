## node for the actual round
##
## this node can have one or two dyads and is responsible for setting them up
## and starting/stopping the games
extends Control
class_name RoundGame

## ref to the 1sec timer
@onready var _timer = $SecondsTimer

## ref to the first dyad
@onready var _dyad0 = %Dyad0 as DyadGame
## ref to the second dyad
@onready var _dyad1 = %Dyad1 as DyadGame

## ref to the timer label
@onready var _timer_label = %TimerLabel

## the actual timer variable[br]
## this acts as a counter that gets decremented every time the timer (1 sec) times out[br]
## makes it easier to update Timer UI
var _time_counter = -1


func _ready():
	if SharedData.is_4player_mode():
		_dyad1.show()
	else:
		_dyad1.hide()
	start_round() # TODO: start with some sort of sequence


## start the round
func start_round() -> void:
	_time_counter = Global.ROUNT_TIME
	
	_dyad0.start_dyad()
	if SharedData.is_4player_mode(): # if 4 players also start the second one
		_dyad1.start_dyad()
	
	_timer.start(1)


func _on_seconds_timer_timeout():
	_time_counter -= 1
	_timer_label.text = str(_time_counter)
	if _time_counter <= 0:
		print("Dyad 0: %s" % [str(_dyad0.get_dyad_point_stack().size())])
		print("Dyad 1: %s" % [str(_dyad1.get_dyad_point_stack().size())])
		get_tree().quit()
	else:
		_timer.start(1)

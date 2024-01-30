## state in the dyad game for when everything is stopped
##
## in this state, nothing should be running and player input is ignored
extends StackState
class_name StoppedState


func enter():
	_fsm.stop_everything()

## state for when all players in the dyad answered correctly
##
## responsible for handling adding points and displaying correct feedback before restarting
extends StackState
class_name RightState


func enter():
	var fsm = _fsm as DyadStateMachine
	fsm.start_stop_timer(false)
	InputManager.enable(false)
	fsm.connect_disconnect_timer(true, _timeout)
	
	fsm.start_stop_timer(true, Global.CORRECT_DELAY)
	
	# TODO: trigger correct effects and set points according to coop from player actions
	print_debug("Right")


func exit():
	_fsm.connect_disconnect_timer(false, _timeout)


## callback to timer to advance to prompt state
func _timeout() -> void:
	replace_state("PromptState")

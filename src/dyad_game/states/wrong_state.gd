## state when one or more players got the answers wrong or didn't answer
##
## this state issues the command to show the answers and has a longer delay
extends StackState
class_name WrongState


func enter():
	var fsm = _fsm as DyadStateMachine
	fsm.start_stop_timer(false)
	InputManager.enable(false)
	fsm.connect_disconnect_timer(true, _timeout)
	
	fsm.start_stop_timer(true, Global.WRONG_DELAY)
	
	fsm.show_answers_ui(true, fsm.get_registered_answers())


func exit():
	_fsm.connect_disconnect_timer(false, _timeout)


## callback to timer to advance to prompt state
func _timeout() -> void:
	replace_state("PromptState")

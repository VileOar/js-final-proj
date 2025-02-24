## state when one or more players got the answers wrong or didn't answer
##
## this state issues the command to show the answers and has a longer delay
extends StackState
class_name WrongState

var _dyad_fsm: DyadStateMachine


func activate():
	_dyad_fsm = fsm() as DyadStateMachine
	_dyad_fsm.start_stop_timer(false)
	_dyad_fsm.connect_disconnect_timer(true, _timeout)
	
	_dyad_fsm.start_stop_timer(true, Global.WRONG_DELAY)
	
	_dyad_fsm.show_answers_ui(true, _dyad_fsm.get_registered_answers())
	$WrongAudio.play()


func deactivate():
	_fsm.connect_disconnect_timer(false, _timeout)


## callback to timer to advance to prompt state
func _timeout() -> void:
	pop_state(["PromptState"])

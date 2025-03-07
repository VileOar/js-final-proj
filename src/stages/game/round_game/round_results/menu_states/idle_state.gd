class_name IdleResultsState
extends StackState


func activate():
	(fsm() as ResultsStateMachine).toggle_buttons(false)

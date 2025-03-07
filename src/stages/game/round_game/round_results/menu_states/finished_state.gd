class_name FinishedResultsState
extends StackState


func activate():
	(fsm() as ResultsStateMachine).toggle_buttons(true)

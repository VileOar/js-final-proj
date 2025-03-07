class_name IdleResultsState
extends StackState


func activate():
	(fsm() as ResultsStateMachine).next_round_btn.disabled = true

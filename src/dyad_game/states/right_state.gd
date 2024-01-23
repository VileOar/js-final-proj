## state for when all players in the dyad answered correctly
##
## responsible for handling adding points and displaying correct feedback before restarting
extends StackState
class_name RightState

## temp ref to the answers
var answers = []


func enter():
	var fsm = _fsm as DyadStateMachine
	fsm.start_stop_timer(false)
	InputManager.enable(false)
	fsm.connect_disconnect_timer(true, _timeout)
	
	fsm.start_stop_timer(true, Global.CORRECT_DELAY)
	
	answers = fsm.get_registered_answers()
	fsm.show_answers_ui(true, answers)


func exit():
	_fsm.connect_disconnect_timer(false, _timeout)
	_fsm.add_dyad_point(_parse_point())
	answers = []


## callback to timer to advance to prompt state
func _timeout() -> void:
	replace_state("PromptState")


## return an n-bit value corresponding to the answers in terms of cooperation, where 0 = coop and
## 1 = defect; answers are sorted by player[br]
## receives an array of PlayerAnswers
func _parse_point() -> int:
	# in here, the answers must be two (i could make this scalable by sorting and looping and adding
	# increasingly shifted bits to make it work with a variable number of players but who even cares
	
	# the indices of the first and second player
	# default is the first index being the lower player (ex: p1,p2; p3,p4
	var p1 = 0
	var p2 = 1
	if answers[0].player_id() > answers[1].player_id():
		p1 = 1
		p2 = 0
	elif answers[0].player_id() == answers[1].player_id():
		# sanity check
		push_error("Fatal Error: two answers cannot belong to the same player. This bug should never happen")
		get_tree().quit()
	var lsb = 0 if answers[p1].cooperated() else 1 # least significant bit
	var msb = 0 if answers[p2].cooperated() else 2 # most significant bit
	
	return lsb | msb

## state for when all players in the dyad answered correctly
##
## responsible for handling adding points and displaying correct feedback before restarting
extends StackState
class_name RightState

## temp ref to the answers
var answers = []

var _dyad_fsm: DyadStateMachine


func activate():
	_dyad_fsm = fsm() as DyadStateMachine
	_dyad_fsm.start_stop_timer(false)
	_dyad_fsm.connect_disconnect_timer(true, _timeout)
	
	_dyad_fsm.start_stop_timer(true, Global.CORRECT_DELAY)
	
	answers = _dyad_fsm.get_registered_answers()
	_dyad_fsm.show_answers_ui(true, answers)
	$CorrectAudio.play()


func deactivate():
	_fsm.connect_disconnect_timer(false, _timeout)
	_fsm.add_dyad_point(_parse_point())
	answers = []


## callback to timer to advance to prompt state
func _timeout() -> void:
	pop_state(["PromptState"])


## return an n-bit value corresponding to the answers in terms of cooperation, where 0 = coop and
## 1 = defect; answers are sorted by player[br]
## receives an array of PlayerAnswers
func _parse_point() -> int:
	
	# the point bitmask, sorted by the order of players
	var point_bitmask = 0
	
	var sanity_players_checked = []
	for ix in answers.size():
		if answers[ix].player_id() in sanity_players_checked:
			# sanity check
			assert(false, "Fatal Error: two answers cannot belong to the same player. This bug should never happen.")
		var bit = 0 if answers[ix].cooperated() else 1
		
		point_bitmask |= bit << ix
	
	return point_bitmask

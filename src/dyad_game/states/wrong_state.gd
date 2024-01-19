## state when one or more players got the answers wrong or didn't answer
##
## this state issues the command to show the answers and has a longer delay
extends BaseDyadGameState
class_name WrongState


func enter():
	dyad_game.stop_timer()
	InputManager.enable(false)
	dyad_game.connect_timer(_timeout)
	
	dyad_game.start_timer(Global.WRONG_DELAY)
	
	dyad_game.show_choices_ui()


func exit():
	dyad_game.disconnect_timer(_timeout)


## callback to timer to advance to prompt state
func _timeout() -> void:
	replace_state("PromptState")

## state for when all players in the dyad answered correctly
##
## responsible for handling adding points and displaying correct feedback before restarting
extends BaseDyadGameState
class_name RightState


func enter():
	dyad_game.stop_timer()
	InputManager.enable(false)
	dyad_game.connect_timer(_timeout)
	
	dyad_game.start_timer(Global.CORRECT_DELAY)
	
	# TODO: trigger correct effects and set points according to coop from player actions
	dyad_game.show_message(true)


func exit():
	dyad_game.disconnect_timer(_timeout)


## callback to timer to advance to prompt state
func _timeout() -> void:
	replace_state("PromptState")

## state in the dyad game for when everything is stopped
##
## in this state, nothing should be running and player input is ignored
extends BaseDyadGameState
class_name StoppedState


func enter():
	dyad_game.stop_everything()

## this autoload is responsible for storing all global signals
##
## it should have no functionality whatsoever<br>
## it just declares the signals that should be accessible by anyone
extends Node


@warning_ignore("unused_signal")
## signal for when a player action is pressed, sent by the InputManager
signal input_player_action(player, input_event)

@warning_ignore("unused_signal")
## signal emitted when a PlayerAnswer is registered, used by other nodes for statistics
signal new_player_answer(answer)

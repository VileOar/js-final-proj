## this autoload is responsible for storing all global signals
##
## it should have no functionality whatsoever<br>
## it just declares the signals that should be accessible by anyone
extends Node

@warning_ignore("unused_signal")
## Signal for general inpu, parsed by the InputManager Node
signal general_input(input_event)

@warning_ignore("unused_signal")
## Signal for when a player action is pressed, sent by the InputManager.
signal input_player_action(player, input_event)

@warning_ignore("unused_signal")
## Signal emitted when a PlayerAnswer is registered, used by other nodes for statistics.
signal new_player_answer(answer)

@warning_ignore("unused_signal")
## Emited to publish the round results, before the round is reset.[br]
## To be caught by the global statistics manager.[br]
## argument should be an array of <Playerstats>.
signal round_published(stats_array)

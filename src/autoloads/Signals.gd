## this autoload is responsible for storing all global signals
##
## it should have no functionality whatsoever<br>
## it just declares the signals that should be accessible by anyone
extends Node


## signal for when a player action is pressed, sent by the InputManager
signal input_player_action(player, input_event)

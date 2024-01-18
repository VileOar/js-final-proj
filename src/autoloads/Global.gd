## the global script where all constant data and configuration parameters are stored
##
## this singleton should NEVER contain mutable data
extends Node


## a global scope RNG
var rng := RandomNumberGenerator.new()


func _ready():
	
	randomize() # randomise the global-scope random functions
	rng.randomize() # randomise the RNG instance

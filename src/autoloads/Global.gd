## the global script where all constant data and configuration parameters are stored
##
## this singleton should NEVER contain mutable data
extends Node


## enum of all directions in game
enum Directions {
	NONE = -1,
	LEFT = 0,
	RIGHT = 1,
	UP = 2,
	DOWN = 3,
}

## enum defining the two possible actions, so as to not use the literals
enum Actions {
	COOP = 0,
	DEFECT = 1,
}

## enum defining the possible outcomes
enum Outcomes {
	CC = 0,
	CD = 1,
	DC = 2,
	DD = 3,
}

## max time for the second player to answer in a dyad
const SECOND_ANSWER_TIMER = 1.5 # in sec
## short delay when both answers right before showing next prompt
const CORRECT_DELAY = 0.5
## longer delay when answers are wrong
const WRONG_DELAY = 2.0

## total time for a round
const ROUND_TIME = 20.0 # TODO: make sure this is set to 30.0

## number of rounds in a game
const NUM_ROUNDS = 5

## round lose penalty multiplier
const LOSE_PENALTY_MULTIPLIER = 0.5

## a global scope RNG
var rng := RandomNumberGenerator.new()

var _player_texture_array : Array = [
	preload("res://assets/gfx/entities/player1.png"),
	preload("res://assets/gfx/entities/player2.png"),
	preload("res://assets/gfx/entities/player3.png"),
	preload("res://assets/gfx/entities/player4.png")
]
func get_player_texture(player) -> Texture:
	return _player_texture_array[player]


func _ready():
	
	randomize() # randomise the global-scope random functions
	rng.randomize() # randomise the RNG instance

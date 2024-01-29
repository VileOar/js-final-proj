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
const ROUND_TIME = 10.0

## number of rounds in a game
const NUM_ROUNDS = 5

## a global scope RNG
var rng := RandomNumberGenerator.new()


func _ready():
	
	randomize() # randomise the global-scope random functions
	rng.randomize() # randomise the RNG instance

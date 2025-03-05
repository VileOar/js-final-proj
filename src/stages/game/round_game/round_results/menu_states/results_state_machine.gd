class_name ResultsStateMachine
extends StackStateMachine

@onready var next_round_btn: Button = %NextRoundBtn

## copy of matrix data
var MATRIX_DATA: PayoffMatrix

## list of dyad_displays
var dyad_panels: Array[DyadResultsPanel]

## loss penalty
var penalty_multiplier: float

## the point stacks
var round_pointstacks: Dictionary[String, Array]

## the stats for this round[br]
## obtained externally, variable for cache
var round_stats: Dictionary[int, PlayerStats]

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

## the type of victory in the end
enum WinType {
	PLAYER, # a player won but not their teammates
	TEAM, # all players in a dyad won
	PERFECT, # all players in a dyad won with the same score
}

## teams are dyads, meaning 2 players
const PLAYERS_PER_TEAM := 2

## max time for the second player to answer in a dyad
const SECOND_ANSWER_TIMER := 1.5 # in sec
## short delay when both answers right before showing next prompt
const CORRECT_DELAY := 0.5
## longer delay when answers are wrong
const WRONG_DELAY := 2.0

## path of save file
const SETTINGS_FILEPATH := "user://settings.ini"

## dictionary of music
var _music_tracks = {
	"title": preload("res://assets/sfx/music/Vibing_Over_Venus.mp3"),
	"game": preload("res://assets/sfx/music/Spy_Glass.mp3"),
	"end": preload("res://assets/sfx/music/Lobby_Time.mp3"),
}

## audio stream player for the music
var _audio_player : AudioStreamPlayer

## a global scope RNG
var rng := RandomNumberGenerator.new()

var _player_texture_array : Array = [
	preload("res://assets/gfx/entities/player1.png"),
	preload("res://assets/gfx/entities/player2.png"),
	preload("res://assets/gfx/entities/player3.png"),
	preload("res://assets/gfx/entities/player4.png")
]
func get_player_texture(player: int) -> Texture:
	return _player_texture_array[player % _player_texture_array.size()]


## play a music track
func play_music_track(track_name: String) -> void:
	if track_name == "":
		_audio_player.stop()
		return
	var track = _music_tracks[track_name]
	if !_audio_player.playing or _audio_player.stream != track:
		_audio_player.stop()
		_audio_player.stream = track
		_audio_player.play()


## convert a tuple of player ids into a team identifier
func get_dyad_id(player_ixs: Array[int]) -> String:
	player_ixs.sort()
	var key = ""
	for i in player_ixs.size():
		key += str(player_ixs[i])
		if i < player_ixs.size(): # if not the last, also add a separator
			key += "-"
	
	return key


func _ready():
	_audio_player = AudioStreamPlayer.new()
	_audio_player.volume_db = 0.0
	add_child(_audio_player)
	
	for sfx in _music_tracks.values():
		sfx.loop = true
	
	randomize() # randomise the global-scope random functions
	rng.randomize() # randomise the RNG instance

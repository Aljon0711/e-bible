extends Node

# Connect your AudioStreamPlayers
@onready var player1 = $AudioPlayer
@onready var player2 = $AudioPlayer2

# Preload your music files
const level_music = preload("res://to-god-be-the-glory-391574.mp3")
const level_music2 = preload("res://mixkit-forest-with-birds-singing-1235.wav")

# Function to play the first track
func play_music1():
	player1.stream = level_music
	player1.volume_db = 0   # 0 means default volume
	player1.play()

# Function to play the second track
func play_music2():
	player2.stream = level_music2
	player2.volume_db = 0
	player2.play()

# Function to play both at the same time
func play_both_music():
	play_music1()
	play_music2()

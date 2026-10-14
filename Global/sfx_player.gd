extends Node

var sfx_volume: float = 1.0

const level_sfx = preload("res://Sounds/button-124476.mp3")

func play_sfx_level():
	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = level_sfx
	player.volume_db = linear_to_db(sfx_volume)

	player.play()

	player.finished.connect(player.queue_free)

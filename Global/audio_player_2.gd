extends AudioStreamPlayer

var music_volume: float = 1.0

const level_music = preload("res://mixkit-forest-with-birds-singing-1235.wav")

func _play_music(music: AudioStream, volume: float = 0.0) -> void:
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(level_music)

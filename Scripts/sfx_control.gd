extends HSlider

# Note: The 'audio_bus_name' should be set to "SFX" or whatever you named your SFX bus in Godot.
@export var audio_bus_name: String 

var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_name == "SFX":
		value = SfxPlayer.sfx_volume
		_apply_volume(value)
	else:
		value = SfxPlayer.sfx_volume
		_apply_volume(value)

func _on_value_changed(value: float) -> void:
	
	if audio_bus_name == "SFX":
		SfxPlayer.sfx_volume = value
	else:
		AudioPlayer.sfx_volume = value

	# Apply actual volume to bus
	_apply_volume(value)

func _apply_volume(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)

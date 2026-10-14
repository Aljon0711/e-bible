# GameData.gd (This runs automatically and persists)
extends Node

var player_name: String = "New Player" # Default name

const SAVE_PATH = "user://game.save"

func _ready() -> void:
	load_game()

## Save the player name to a file.
func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var save_dict = {
			"player_name": player_name,
		}
		var json_string = JSON.stringify(save_dict)
		file.store_line(json_string)
		print("Game name saved.")
	else:
		print("Could not save file.")

## Load the player name from a file.
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Using default name.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		var save_dict = JSON.parse_string(json_string)

		if save_dict is Dictionary:
			# Get the saved name, falling back to the default if not found
			player_name = save_dict.get("player_name", player_name)
			print("Game name loaded.")
		else:
			print("Error parsing save file.")

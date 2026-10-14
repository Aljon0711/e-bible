extends Control

@onready var level_1: Button = %Level1
@onready var level_2: Button = %Level2
@onready var level_3: Button = %Level3

func _ready() -> void:
	if level_1:
		level_1.grab_focus()

func _on_back_pressed() -> void:
	print("Back pressed")
	SfxPlayer.play_sfx_level()
	call_deferred("_return_menu")
	
func _return_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_level_1_pressed() -> void:
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://scenes1/adam_&_eve.tscn")


func _on_level_2_pressed() -> void:
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://tile_map.tscn")


func _on_level_3_pressed() -> void:
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://tiles/Sunnyside_World_ASSET_PACK_V2.1/Level_1.tscn")

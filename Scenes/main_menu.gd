extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings
@onready var exit: Panel = $Exit
@onready var edit_profile: Panel = $Edit_profile
@onready var profile: Panel = $Profile
@onready var name_line_edit: LineEdit = $Edit_profile/NameLineEdit # Update this path based on your scene tree
@onready var current_name_label: Label = $Profile/CurrentNameLabel # Update this path

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _ready() -> void:
	AudioPlayer.play_music_level()
	main_buttons.visible = true
	settings.visible = false
	exit.visible = false
	edit_profile.visible = false
	profile.visible = true
	update_name_ui()
	
func update_name_ui() -> void:
	# 1. Update the label showing the name on the main profile screen
	current_name_label.text = GameData.player_name
	
	# 2. Set the text in the input field to the current name
	name_line_edit.text = GameData.player_name

func _on_start_pressed() -> void:
	print("Start pressed")
	SfxPlayer.play_sfx_level()
	call_deferred("_go_to_level")


func _go_to_level() -> void:
	get_tree().change_scene_to_file("res://Scenes/1st_scene.tscn")


func _on_exit_pressed() -> void:
	print("Exit pressed")
	SfxPlayer.play_sfx_level()
	main_buttons.visible = false
	exit.visible = true


func _on_achievements_pressed() -> void:
	print("Achievements pressed")
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://Scenes/achievements.tscn")

func _on_settings_pressed() -> void:
	print("Settings pressed")
	SfxPlayer.play_sfx_level()
	main_buttons.visible = false
	settings.visible = true


func _on_htp_pressed() -> void:
	print("How to play pressed")
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://Scenes/htp.tscn")


func _on_setting_back_pressed() -> void:
	print("Back pressed")
	SfxPlayer.play_sfx_level()
	_ready()


func _on_true_exit_pressed() -> void:
	SfxPlayer.play_sfx_level()
	get_tree().quit()


func _on_cancel_pressed() -> void:
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_profile_pressed() -> void:
	SfxPlayer.play_sfx_level()
	update_name_ui()
	profile.visible = false
	edit_profile.visible = true


func _on_save_pressed() -> void:
	SfxPlayer.play_sfx_level()
	# 1. Get the new name from the input field
	var new_name = name_line_edit.text.strip_edges()
	# 2. Simple validation: ensure the name isn't empty
	if new_name.length() > 0:
		GameData.player_name = new_name
		# 3. Save the new name persistently
		GameData.save_game()
	else:
		# Optionally show an error if the name is empty
		print("Name cannot be empty!")
	# 4. Update the UI and switch back to the main profile view
	update_name_ui()


func _on_exit_edit_pressed() -> void:
	SfxPlayer.play_sfx_level()
	edit_profile.visible = false
	profile.visible = true

extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	LevelCore.ach_3_earned = true
	LevelCore.ach_6_earned = true
	call_deferred("_go_back")
	
func _go_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/1st_scene.tscn")

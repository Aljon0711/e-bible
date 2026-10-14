extends Area2D

var triggered := false

func _on_triggerin_body_entered(body: Node2D) -> void:
	# Fire only once and only for the player
	if triggered:
		return
	if not body.is_in_group("player"):
		return
	
	triggered = true
	set_deferred("monitoring", false)
	
	# Start the end-of-mission dialogue
	var dialog_scene = Dialogic.start("Mission_3_End")
	get_tree().get_root().add_child(dialog_scene)
	
	# Small delay to ensure Dialogic starts, then wait for it to close
	await get_tree().create_timer(0.05).timeout
	await dialog_scene.tree_exited
	
	# Mark mission 3 complete
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.mission_3_active and not game_manager.mission_3_complete:
		game_manager.complete_mission_3()

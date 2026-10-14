extends Area2D

var triggered := false

func _on_triggerin_body_entered(body: Node2D) -> void:
	# Fire only once
	if triggered:
		return

	# Accept if in player group OR named Player (fallback)
	if not body.is_in_group("player") and body.name != "Player":
		return

	triggered = true
	set_deferred("monitoring", false)
	print("Triggerin: player entered, starting Mission_3_End dialogue")

	# Start the end-of-mission dialogue
	var dialog_scene = Dialogic.start("Mission_3_End")
	get_tree().get_root().add_child(dialog_scene)

	# Small delay to ensure Dialogic starts, then wait for it to close
	await get_tree().create_timer(0.05).timeout
	await dialog_scene.tree_exited

	# Start the quiz
	print("Dialogue finished, starting quiz...")
	var quiz_script = load("res://quiz.gd")
	var quiz = quiz_script.new()
	get_tree().root.add_child(quiz)
	
	# Wait for quiz to complete
	await quiz.tree_exited
	
	# Mark mission 3 complete
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.mission_3_active and not game_manager.mission_3_complete:
		game_manager.complete_mission_3()
		print("MISSION 3 COMPLETED via Triggerin")

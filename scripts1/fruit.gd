extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Ensure that the one entering is the Player
	if body.name == "Player":
		# Check the main script (owner) if Mission 2 has started
		# 'owner' refers to the root node of the main scene (adam_&_eve.gd)
		if owner.mission2_started == true:
			owner.collect_fruit() # Call the function in the main script
			queue_free() # Remove the fruit from the map
		else:
			# If the player hasn't talked to Eve yet, nothing happens
			print("Talk to Eve first before gathering fruits!")

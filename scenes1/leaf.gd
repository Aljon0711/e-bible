extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Tiyakin na Player ang pumasok
	if body.name == "Player":
		# Tiyakin na nagsimula na ang mission sa main script (owner)
		if owner.mission3_started == true:
			owner.collect_leaf() # Tawagin ang function sa main script
			queue_free() # Burahin ang dahon
		else:
			print("Hindi pa nagsisimula ang Mission 3. Kausapin muna si Adam at Eve.")

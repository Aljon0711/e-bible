extends OptionButton

func _on_item_selected(index: int) -> void:
	var options = ["Ultra", "High", "Mid", "Low"]
	var value = options[index]
	print(value)
	match value:
		"Ultra":
			get_tree().root.scaling_3d_scale = 1.5
		"High":
			get_tree().root.scaling_3d_scale = 1.25
		"Mid":
			get_tree().root.scaling_3d_scale = 1.0
		"Low":
			get_tree().root.scaling_3d_scale = 0.75

extends Area2D 

const PLAYER_GROUP_NAME = "player" 

# This function is connected to the 'body_entered' signal in the editor.
func _on_body_entered(body: Node2D): 
	# Check if the body that entered is the Player
	if body.is_in_group(PLAYER_GROUP_NAME): 
		var player_node = body as CharacterBody2D
		collect(player_node)

# PICKUP LOGIC
func collect(player_node: CharacterBody2D):
	print("Fruit collected automatically!")
	
	# Pass the value 1 to increase food inventory by 1
	if player_node.has_method("collect_food"):
		player_node.collect_food(1) 
	
	# Delete the item
	queue_free()

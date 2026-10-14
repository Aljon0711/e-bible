extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var speed = 150
var wood_count = 0
var food_count = 0

# Virtual joystick input (mobile) - set by scene script via signal
var joystick_input: Vector2 = Vector2.ZERO

func set_joystick_input(direction: Vector2) -> void:
	joystick_input = direction


func _ready():
	animated_sprite.play("walk_down")
	animated_sprite.stop()


func _physics_process(delta):
	var input = Vector2.ZERO
	# Prefer virtual joystick (mobile) if it has input; else keyboard/actions (desktop)
	if joystick_input.length_squared() > 0.01:
		input = joystick_input.normalized()
	else:
		input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		if input.length() > 0:
			input = input.normalized()

	velocity = input * speed
	move_and_slide()
	
	if input.length() > 0:
		if abs(input.x) > abs(input.y):
			if input.x > 0: animated_sprite.play("walk_right")
			else: animated_sprite.play("walk_left")
		else:
			if input.y > 0: animated_sprite.play("walk_down")
			else: animated_sprite.play("walk_up")
	else:
		animated_sprite.stop()


# Function to be called by the wood_branch.gd script
func collect_wood(amount: int = 1):
	wood_count += amount
	print("Wood collected! Total: ", wood_count)

	var game_manager = get_node("/root/GameManager")
	# Check against the goal defined in the GameManager
	if wood_count >= game_manager.mission_1_wood_goal and game_manager.mission_1_active:
		game_manager.complete_mission_1()

# Function to be called by food item scripts
func collect_food(amount: int = 1):
	food_count += amount
	print("Food collected! Total: ", food_count)

	var game_manager = get_node("/root/GameManager")
	# Check against the goal defined in the GameManager
	if food_count >= game_manager.mission_2_food_goal and game_manager.mission_2_active:
		game_manager.complete_mission_2()

extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0 # Not currently used

var can_move: bool = true # Controls movement lock (used by dialogue)
var joystick_input: Vector2 = Vector2.ZERO # Stores input from the virtual joystick

@onready var animated_sprite = $AnimatedSprite2D 

var last_direction = Vector2.DOWN 

# =========================================================
# 1. JOYSTICK COMMUNICATION
# This function is the target for the joystick's 'joystick_moved' signal.
# =========================================================
func set_joystick_input(direction: Vector2) -> void:
	joystick_input = direction
	# NOTE: A small debug print is useful here if movement fails:
	# print("PLAYER INPUT RECEIVED: ", joystick_input) 


# =========================================================
# 2. MOVEMENT CONTROL (DIALOGUE/PAUSE)
# =========================================================
func disable_movement():
	can_move = false
	velocity = Vector2.ZERO
	joystick_input = Vector2.ZERO 
	
	if animated_sprite:
		_set_idle_animation(last_direction) 

func enable_movement():
	can_move = true


# =========================================================
# 3. INPUT AND ANIMATION LOGIC (COMBINED)
# =========================================================
func get_combined_movement():
	
	# Read standard keyboard/controller input
	var keyboard_input = Input.get_vector("left", "right", "up", "down")
	
	var input_direction: Vector2
	
	# Prioritize Joystick Input if it's sending a signal (active touch)
	if joystick_input.length_squared() > 0.01: 
		input_direction = joystick_input
	else:
		# Use keyboard input if the joystick is centered
		input_direction = keyboard_input
		
	var animation_name = "idle_down"

	if input_direction != Vector2.ZERO:
		# Apply speed using the combined input
		velocity = input_direction * SPEED
		
		# Animation Logic
		if abs(input_direction.x) > abs(input_direction.y):
			# Horizontal movement dominates
			if input_direction.x > 0:
				animation_name = "walk_right"
				last_direction = Vector2.RIGHT
				animated_sprite.flip_h = false
			else:
				animation_name = "walk_right"
				last_direction = Vector2.LEFT
				animated_sprite.flip_h = true
		else:
			# Vertical movement dominates
			if input_direction.y > 0:
				animation_name = "walk_down"
				last_direction = Vector2.DOWN
				animated_sprite.flip_h = false
			else:
				animation_name = "walk_up"
				last_direction = Vector2.UP
				animated_sprite.flip_h = false
	else:
		# No input: Set velocity to zero and show idle animation
		velocity = Vector2.ZERO
		_set_idle_animation(last_direction)
		return

	animated_sprite.play(animation_name)


func _set_idle_animation(direction: Vector2) -> void:
	if direction == Vector2.RIGHT:
		animated_sprite.play("idle_right")
		animated_sprite.flip_h = false
	elif direction == Vector2.LEFT:
		animated_sprite.play("idle_right")
		animated_sprite.flip_h = true
	elif direction == Vector2.UP:
		animated_sprite.play("idle_up")
		animated_sprite.flip_h = false
	else: # Vector2.DOWN
		animated_sprite.play("idle_down")
		animated_sprite.flip_h = false


# =========================================================
# 4. PHYSICS PROCESS
# =========================================================
func _physics_process(delta: float) -> void:
	if can_move:
		get_combined_movement()
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

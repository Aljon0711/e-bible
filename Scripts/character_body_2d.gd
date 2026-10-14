extends CharacterBody2D

@export var speed = 150

# NEW: Flag to control movement state
var is_movement_locked: bool = false

# NEW: Variable to hold the joystick input vector
var joystick_input: Vector2 = Vector2.ZERO


# NEW: Function to receive the input from the joystick
func set_joystick_input(direction: Vector2) -> void:
	joystick_input = direction
	

# NEW: Functions to be called by the Dialogue Manager
func disable_movement() -> void:
	is_movement_locked = true
	# Reset velocity to 0 immediately when locked to stop any lingering movement/sliding
	velocity = Vector2.ZERO
	# Ensure joystick input is also zeroed out
	joystick_input = Vector2.ZERO

func enable_movement() -> void:
	is_movement_locked = false
	
# REMOVE the old get_input() function entirely, as it's no longer needed.


func _physics_process(delta: float) -> void:
	# Check the movement lock *before* processing input or movement
	if is_movement_locked:
		# Velocity is already zeroed by disable_movement()
		move_and_slide()
		return
		
	# Use the input received from the joystick
	velocity = joystick_input * speed
	move_and_slide()

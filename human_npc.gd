extends CharacterBody2D

# Get references to child nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var action_timer = $actionTimer 
# NOTE: If you add the PickupZone later, add its reference here:
# @onready var pickup_zone = $PickupZone 

# Expose speed and the range for random movement to the Inspector
@export var speed: float = 75.0
@export var move_duration_min: float = 1.0
@export var move_duration_max: float = 4.0

# Define the NPC States and Directions
enum State { IDLE, WALKING, PICKUP }
enum Direction { NORTH, EAST, SOUTH, WEST }

var current_state: State = State.WALKING # Start walking immediately
var current_direction: Direction = Direction.SOUTH # Start facing down

var movement_target: Vector2 = Vector2.ZERO # The spot the NPC is trying to reach


func _ready():
	randomize()
	
	# Connect the Timer signal
	if not action_timer.is_connected("timeout", _on_action_timer_timeout):
		action_timer.connect("timeout", _on_action_timer_timeout)

	# Set the initial wait time and start the timer
	action_timer.wait_time = randf_range(move_duration_min, move_duration_max)
	action_timer.start()
	
	# Immediately trigger the first action decision to set the initial movement target
	_on_action_timer_timeout()


func _physics_process(delta):
	match current_state:
		State.WALKING:
			handle_walking()
		State.PICKUP:
			handle_pickup()
		State.IDLE:
			handle_idle()
	
	move_and_slide()

# --- HANDLER FUNCTIONS ---

func handle_walking():
	# 1. Calculate direction to the target
	var direction_to_target = movement_target - global_position
	
	# 2. Check if target is reached (5 pixels tolerance)
	if direction_to_target.length_squared() < 5 * 5: 
		
		# TRANSITION: Stop walking and move immediately to the PICKUP state
		current_state = State.PICKUP 
		velocity = Vector2.ZERO
		
		# When transitioning to PICKUP, we immediately play the correct animation
		animated_sprite.play("pickup_" + get_direction_string(current_direction))
		
		return
		
	# 3. If not reached, continue walking
	velocity = direction_to_target.normalized() * speed
	
	# 4. Update animation based on movement
	update_animation(direction_to_target)


func handle_idle():
	velocity = Vector2.ZERO
	# IDLE state is maintained here, but the NPC currently bypasses it.


func handle_pickup():
	velocity = Vector2.ZERO # Stop movement during pickup
	
	# Ensure the pickup animation is playing until the timer runs out
	animated_sprite.play("pickup_" + get_direction_string(current_direction))


# --- ANIMATION AND DIRECTION UTILITIES ---

func update_animation(direction: Vector2):
	# This logic translates the movement vector into one of the four cardinal directions
	var direction_abs = direction.abs()
	
	# Prioritize the axis with greater movement
	if direction_abs.x > direction_abs.y:
		# Horizontal
		if direction.x > 0:
			current_direction = Direction.EAST
		else:
			current_direction = Direction.WEST
	else:
		# Vertical
		if direction.y > 0:
			current_direction = Direction.SOUTH
		else:
			current_direction = Direction.NORTH
			
	animated_sprite.play("walk_" + get_direction_string(current_direction))


func get_direction_string(dir: Direction) -> String:
	match dir:
		Direction.NORTH: return "up"
		Direction.EAST: return "right"
		Direction.SOUTH: return "down"
		Direction.WEST: return "left"
	return "down" # Default


# --- ACTION TIMER (NPC's Decision Maker) ---

func _on_action_timer_timeout():
	
	# This timer primarily controls the duration of the PICKUP state and 
	# the initiation of the next WALKING phase.
	
	if current_state == State.PICKUP or current_state == State.IDLE:
		# If we were picking up or idle, the next action must be WALKING.
		current_state = State.WALKING
		
		# 1. Choose a new random Direction
		var rand_dir = randi_range(0, 3) # 0, 1, 2, 3 -> N, E, S, W
		current_direction = Direction.values()[rand_dir]
		
		# 2. Determine a new Movement Target based on the chosen direction
		var move_distance = randf_range(30.0, 150.0) # Move 30 to 150 pixels
		var offset = Vector2.ZERO
		
		match current_direction:
			Direction.NORTH: offset = Vector2(0, -move_distance)
			Direction.EAST: offset = Vector2(move_distance, 0)
			Direction.SOUTH: offset = Vector2(0, move_distance)
			Direction.WEST: offset = Vector2(-move_distance, 0)
		
		movement_target = global_position + offset
	
	# The timer is not reset if the NPC is WALKING, because the WALKING state 
	# ends when the target is reached, not when the timer runs out.
	
	# Reset the timer for the next action duration
	action_timer.wait_time = randf_range(move_duration_min, move_duration_max)
	action_timer.start()

extends CharacterBody2D

# Get references to child nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var change_state_timer = $changestatetimer
@onready var walking_timer = $walkingtimer

# --- Global Variables ---
var eating: bool = false
var walking: bool = true
var x_direction: int = 1    # 1 = right, -1 = left
var y_direction: int = 1    # 1 = down, -1 = up

# @export allows you to set the speed individually in the Inspector for each cow.
# If left at 50.0, it will be randomized in _ready().
@export var speed: float = 50.0 

# @export allows you to set the initial movement axis (1=Horizontal, 2=Vertical).
# This replaces the erroneous @export_enum line.
@export var moving_vertical_or_horizontal: int = 1


func _ready():
	# Start in the walking state and initialize random number generation
	walking = true
	randomize() 
	
	# --- RANDOMIZATION LOGIC FOR DIFFERENT MOVESETS ---
	
	# 1. Randomize Speed if it was left at the default 50.0 
	# This ensures cows move at different speeds unless you explicitly set one in the Inspector.
	if speed == 50.0:
		speed = randf_range(30.0, 75.0)
		
	# 2. Randomize Initial Direction (X/Y)
	if randf_range(0.0, 1.0) > 0.5:
		x_direction = 1 # Right
	else:
		x_direction = -1 # Left
		
	if randf_range(0.0, 1.0) > 0.5:
		y_direction = 1 # Down
	else:
		y_direction = -1 # Up
		
	# 3. Randomize Initial Movement Axis (Horizontal/Vertical)
	# This determines if the cow starts moving horizontally or vertically.
	if moving_vertical_or_horizontal == 1: # Only randomize if the default (1) is used
		if randf_range(0.0, 1.0) > 0.5:
			moving_vertical_or_horizontal = 1 # Horizontal
		else:
			moving_vertical_or_horizontal = 2 # Vertical
	
	# NOTE: Timers are already starting due to Autostart, but these lines
	# ensure they run immediately when the scene is loaded.
	change_state_timer.start() 
	walking_timer.start()


func _physics_process(delta):
	velocity = Vector2.ZERO
	
	# 1. Walking State Logic
	if walking:
		animated_sprite.play("walking") 
		
		if moving_vertical_or_horizontal == 1: # Horizontal Movement
			velocity.x = speed * x_direction
			velocity.y = 0.0
			animated_sprite.flip_h = x_direction == -1

		elif moving_vertical_or_horizontal == 2: # Vertical Movement
			velocity.y = speed * y_direction
			velocity.x = 0.0
			
		move_and_slide() 

	# 2. Eating State Logic
	elif eating:
		animated_sprite.play("eating") 
		velocity = Vector2.ZERO
		
		# Randomly decide the axis for the next movement state (H or V)
		var rand_h_v = randf_range(1, 2)
		if rand_h_v > 1.5:
			moving_vertical_or_horizontal = 1
		else:
			moving_vertical_or_horizontal = 2


# --- Timer Signal Functions ---

func _on_timer_timeout(): # Function for the FIRST timer (changestatetimer)
	var wait_time: float = 0.0
	
	if walking:
		# Change state from Walking to Eating
		eating = true
		walking = false
		wait_time = randf_range(1.0, 5.0)
	else:
		# Change state from Eating to Walking
		walking = true
		eating = false
		wait_time = randf_range(2.0, 6.0)
		
	change_state_timer.wait_time = wait_time
	change_state_timer.start()


func _on_timer_2_timeout(): # Function for the SECOND timer (walkingtimer)
	# 1. Randomize the NEXT travel axis (Horizontal or Vertical)
	if randf_range(1, 2) > 1.5:
		moving_vertical_or_horizontal = 1 # Horizontal
	else:
		moving_vertical_or_horizontal = 2 # Vertical
		
	# 2. Randomize the direction along the chosen axis (Left/Right or Up/Down)
	if moving_vertical_or_horizontal == 1:
		# Randomize Horizontal (X) Direction
		if randf_range(1, 2) > 1.5:
			x_direction = 1
		else:
			x_direction = -1
	else:
		# Randomize Vertical (Y) Direction
		if randf_range(1, 2) > 1.5:
			y_direction = 1
		else:
			y_direction = -1
			
	# 3. Set a new random duration before changing direction again
	walking_timer.wait_time = randf_range(1.0, 4.0)
	walking_timer.start() 

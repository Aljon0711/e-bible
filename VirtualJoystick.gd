extends Control

# --- Configuration ---
@export var dead_zone_radius: float = 20.0 # Area where the stick doesn't move
@export var move_zone_radius: float = 100.0 # Max distance the stick can move
@export var joy_stick_texture: Texture2D # The visible joystick handle texture

# --- Node References ---
# NOTE: Ensure nodes in your scene are named exactly 'Base' and 'Stick'
@onready var base: TextureRect = $Base 
@onready var stick: TextureRect = $Stick 

# --- State Variables ---
var touch_id: int = -1 
var joystick_center: Vector2 
var current_input: Vector2 = Vector2.ZERO: set = _set_current_input

# --- Signals ---
signal joystick_moved(direction: Vector2)

# --- Initialization ---
func _ready():
	# This requires 'joy_stick_texture' to be assigned in the Inspector
	stick.texture = joy_stick_texture
	
	# Center the stick relative to the base's size (initial centering)
	if base and stick:
		stick.position = base.size / 2.0 - stick.size / 2.0
		joystick_center = base.position + base.size / 2.0
	
	current_input = Vector2.ZERO
	
func _set_current_input(new_input: Vector2):
	current_input = new_input
	joystick_moved.emit(current_input)


# Convert to global position so joystick works when this Control is not fullscreen (e.g. in a layer)
func _touch_to_global(pos: Vector2) -> Vector2:
	return get_global_transform_with_canvas() * pos

# --- Input Handling (Touch) ---
func _gui_input(event: InputEvent) -> void:
	
	# 1. Start Touch (Press Down)
	if event is InputEventScreenTouch and event.pressed:
		if touch_id == -1:
			touch_id = event.index
			var touch_global = _touch_to_global(event.position)
			joystick_center = touch_global
			base.global_position = joystick_center - base.size / 2.0
			stick.global_position = joystick_center - stick.size / 2.0
			base.visible = true
			stick.visible = true
			accept_event()
	
	# 2. End Touch (Release)
	elif event is InputEventScreenTouch and not event.pressed and event.index == touch_id:
		reset_joystick()
		accept_event()
		
	# 3. Movement (Drag)
	elif event is InputEventScreenDrag and event.index == touch_id:
		handle_move(_touch_to_global(event.position))
		accept_event()


# --- Core Logic ---
func handle_move(new_position: Vector2) -> void:
	var delta = new_position - joystick_center
	var distance = delta.length()
	
	# Handle the Dead Zone (snaps stick to center)
	if distance < dead_zone_radius:
		stick.global_position = joystick_center - stick.size / 2.0
		_set_current_input(Vector2.ZERO)
		return
		
	# Clamp the position to the move_zone_radius
	var clamped_delta = delta.limit_length(move_zone_radius)
	stick.global_position = joystick_center + clamped_delta - stick.size / 2.0
	
	# Calculate the normalized input vector (-1 to 1)
	var input_vector = clamped_delta / move_zone_radius
	_set_current_input(input_vector)


func reset_joystick() -> void:
	touch_id = -1
	
	# Hide the joystick elements
	base.visible = false
	stick.visible = false
	
	# Reset input to zero
	_set_current_input(Vector2.ZERO)

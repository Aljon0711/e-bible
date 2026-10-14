extends CharacterBody2D


@onready var animated_sprite = $AnimatedSprite2D
var can_move = true # <--- NEW: Ito ang control switch para sa paggalaw
var speed: float = 100.0

# Virtual joystick input (mobile) - set by scene script via signal
var joystick_input: Vector2 = Vector2.ZERO

func set_joystick_input(direction: Vector2) -> void:
	joystick_input = direction

func _ready() -> void:
	# Start idle facing down (first frame of "walk-down")
	animated_sprite.play("walk-down")
	animated_sprite.stop()

# =================================================================
# NEW FUNCTION: TATAWAGIN ITO NG MAP SCRIPT (adam_&_eve.gd) PARA HUMINTO/GUMALAW
# =================================================================
func set_can_move(value: bool):
	can_move = value
	if not can_move:
		# Kapag pinahinto (value=false), kailangan huminto agad
		velocity = Vector2.ZERO
		joystick_input = Vector2.ZERO
		move_and_slide()
		animated_sprite.stop()

func _physics_process(_delta: float) -> void:
	
	# CHECK: Kung can_move ay FALSE, lalampasan ang buong movement block.
	if not can_move:
		return 

	var input_vector = Vector2.ZERO

	# Prefer virtual joystick (mobile) if it has input; else keyboard (desktop)
	if joystick_input.length_squared() > 0.01:
		input_vector = joystick_input.normalized()
	else:
		input_vector.x = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
		input_vector.y = int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
	
	# Animation based on movement direction
	if input_vector.length() > 0:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				animated_sprite.play("walk-right")
			else:
				animated_sprite.play("walk-left")
		else:
			if input_vector.y > 0:
				animated_sprite.play("walk-down")
			else:
				animated_sprite.play("walk-up")
	else:
		animated_sprite.stop()

 

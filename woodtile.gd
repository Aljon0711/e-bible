extends Node

@onready var virtual_joystick = $Player/Camera2D/JoystickLayer/VirtualJoystick
@onready var player = $Player

func _ready():
	if virtual_joystick and player and player.has_method("set_joystick_input"):
		virtual_joystick.joystick_moved.connect(player.set_joystick_input)

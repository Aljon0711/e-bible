extends Node

@onready var story_panel = $Player/Camera2D/StoryLayer/Story
@onready var mission_panel = $Player/Camera2D/MissionUILayer/Mission
@onready var virtual_joystick = $Player/Camera2D/JoystickLayer/VirtualJoystick
@onready var player = $Player

func _ready():
	# Story panel unang lalabas pag start ng scene
	if story_panel:
		story_panel.show()
	if mission_panel:
		mission_panel.show()

	# Connect virtual joystick to player (mobile)
	if virtual_joystick and player and player.has_method("set_joystick_input"):
		virtual_joystick.joystick_moved.connect(player.set_joystick_input)

func _unhandled_input(event):
	# Tap screen to dismiss Story intro panel
	if story_panel and story_panel.visible:
		if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			story_panel.hide()
			get_viewport().set_input_as_handled()

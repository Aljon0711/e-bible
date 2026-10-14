# DialogueUI.gd
extends CanvasLayer

signal dialogue_finished

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/Label

var dialogue_script = []
var current_line_index = 0
var is_typing = false
var is_active = false

var touch_catcher: Control

func _ready():
	touch_catcher = ColorRect.new()
	touch_catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
	touch_catcher.set_anchor(SIDE_LEFT, 0)
	touch_catcher.set_anchor(SIDE_TOP, 0)
	touch_catcher.set_anchor(SIDE_RIGHT, 1)
	touch_catcher.set_anchor(SIDE_BOTTOM, 1)
	touch_catcher.offset_left = 0
	touch_catcher.offset_top = 0
	touch_catcher.offset_right = 0
	touch_catcher.offset_bottom = 0
	touch_catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	touch_catcher.color = Color(0, 0, 0, 0)
	touch_catcher.gui_input.connect(_on_touch_catcher_gui_input)
	add_child(touch_catcher)
	touch_catcher.visible = false

func _on_touch_catcher_gui_input(event: InputEvent):
	if not is_active:
		return
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		if not is_typing:
			show_current_line()
		get_viewport().set_input_as_handled()

func start_dialogue(script: Array):
	if is_active:
		return
	dialogue_script = script
	current_line_index = 0
	is_active = true
	panel.show()
	touch_catcher.visible = true
	show_current_line()

func show_current_line():
	if current_line_index >= dialogue_script.size():
		end_dialogue()
		return
	var line = dialogue_script[current_line_index]
	label.text = line.speaker + ": " + line.text
	current_line_index += 1
	is_typing = false

func _input(event):
	if not is_active:
		return
	var advance = event.is_action_pressed("ui_accept") \
		or (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)
	if advance and not is_typing:
		show_current_line()
		get_viewport().set_input_as_handled()

func end_dialogue():
	is_active = false
	panel.hide()
	if touch_catcher:
		touch_catcher.visible = false
	emit_signal("dialogue_finished")

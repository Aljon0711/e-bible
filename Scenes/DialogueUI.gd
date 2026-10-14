# DialogueUI.gd
extends CanvasLayer

# 1. DEKLARASYON NG SIGNAL: Ito ang pinakamahalaga!
# Ang signal na ito ay ipapadala (emit) sa map script kapag tapos na ang dialogue.
signal dialogue_finished 

# Iba pang Variables
@onready var panel = $PanelContainer
@onready var label = $PanelContainer/Label

var dialogue_script = [] # Dito ise-save ang dialogue data mula sa map
var current_line_index = 0
var is_typing = false
var is_active = false

# Full-screen touch catcher para siguradong tumatanggap ng tap/click (mobile at desktop)
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

# Function na tatawagin ng map script (adam_&_eve.gd)
func start_dialogue(script: Array):
	if is_active:
		return
		
	dialogue_script = script
	current_line_index = 0
	is_active = true
	panel.show()
	touch_catcher.visible = true
	
	# Simulan ang pagpapakita ng unang linya
	show_current_line()

# Function na magpapakita ng kasalukuyang linya
func show_current_line():
	if current_line_index >= dialogue_script.size():
		end_dialogue()
		return

	var line = dialogue_script[current_line_index]
	
	# I-update ang Label sa text (sa simula, pwede lang natin ipakita ang Speaker at Text)
	label.text = line.speaker + ": " + line.text
	# (Dito mo ilalagay ang logic para sa typing effect kung gusto mo)
	
	current_line_index += 1
	is_typing = false
	
	# Tiyakin na pinapayagan lang natin ang user na mag-advance kapag hindi nagta-type

# Function na magpapa-advance sa dialogue o magtatapos (Enter/Space, click, o tap sa screen)
func _input(event):
	if not is_active:
		return
	var advance = event.is_action_pressed("ui_accept") \
		or (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)
	if advance:
		if is_typing:
			pass
		else:
			show_current_line()
			get_viewport().set_input_as_handled()


# Function na magtatapos ng dialogue at magpapadala ng Signal!
func end_dialogue():
	is_active = false
	panel.hide()
	if touch_catcher:
		touch_catcher.visible = false
	
	# 2. I-EMIT ANG SIGNAL: Ito ang magti-trigger ng _on_adam_dialogue_finished sa map
	emit_signal("dialogue_finished")

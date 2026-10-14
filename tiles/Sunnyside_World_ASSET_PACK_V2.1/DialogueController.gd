extends PanelContainer

@onready var dialogue_label: Label = $DialogueLabel
@onready var typing_timer: Timer = $TypingTimer
@onready var continue_button: Button = $Button # New variable for the button
# Assuming CharacterBody2D is a sibling (on the same level) as the CanvasLayer node
@onready var player_node: CharacterBody2D = get_parent().get_parent().get_node("Player")

# The full text you want to display
var full_text: String = """In the land of Israel, a giant named Goliath challenged the
Israelite army every day, shouting for a 
man brave enough to fight him. But fear filled the camp
—no soldier dared to step forward.

Meanwhile, a young shepherd named David arrived
to bring food to his brothers. Hearing Goliath’s insults, 
David’s heart burned with courage. Though small 
and untrained for battle, he believed God would give him strength.

A simple visit to the battlefield would soon 
lead David to stand face-to-face with a giant… 
and change Israel’s fate forever.

Mission find and help David

									 Click the screen to continue"""
# The index of the next character to reveal
var char_index: int = 0
# Speed control: Time in seconds between each letter
const TYPING_SPEED: float = 0.008


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# --- UI LAYOUT ADJUSTMENT ---
	
	# 1. Set the Button's Anchor to BOTTOM-RIGHT
	# This anchors the button's corners to the bottom-right of the PanelContainer.
	# The constants are: ANCHOR_BEGIN = 0.0, ANCHOR_END = 1.0
	continue_button.anchor_left = 1.0  # Anchor the left edge to the right side of the parent
	continue_button.anchor_top = 1.0   # Anchor the top edge to the bottom side of the parent
	continue_button.anchor_right = 100.0 # Anchor the right edge to the right side of the parent
	continue_button.anchor_bottom = 100.0# Anchor the bottom edge to the bottom side of the parent
	
	# 2. Set the Button's Margins
	# Since the anchors are set to 1.0 (the far end), we use negative margins 
	# to move the button *back* and *up* from the corner, providing padding.
	
	# Example: 20 pixels of padding from the right edge
	continue_button.offset_left = -100 # Adjust width of the button
	continue_button.offset_right = -20 # 20 pixels margin from the right edge of the Panel
	
	# Example: 20 pixels of padding from the bottom edge
	continue_button.offset_top = -40  # Adjust height of the button
	continue_button.offset_bottom = -20 # 20 pixels margin from the bottom edge of the Panel
	# --- 1. GAME LOCK ---
	# Disable the player's movement as soon as the panel appears
	if player_node:
		player_node.set_movement_locked(true) # We'll add this function to the player script
		
	# 2. Setup Dialogue
	dialogue_label.text = full_text
	dialogue_label.visible_characters = 0
	
	# 3. Setup Button
	continue_button.visible = false # Hide the button until animation is done
	
	# 4. Setup Timer
	typing_timer.wait_time = TYPING_SPEED
	typing_timer.timeout.connect(on_typing_timer_timeout)
	typing_timer.start()
	
	# 5. Show the panel
	visible = true


# This function runs every time the timer times out (every 0.05 seconds)
func on_typing_timer_timeout() -> void:
	# Check if we have revealed all characters
	if char_index < full_text.length():
		# Increment the visible characters property
		char_index += 1
		dialogue_label.visible_characters = char_index
	else:
		# Stop the timer once the text is fully shown
		typing_timer.stop()
		continue_button.visible = true # Show the button once the text is complete
		print("Animation complete.")


# Optional: Add a function to skip the animation on input (e.g., mouse click)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): 
		if char_index < full_text.length():
			# Skip to the end
			char_index = full_text.length()
			dialogue_label.visible_characters = char_index
			typing_timer.stop()
			continue_button.visible = true # Show the button upon skipping
			get_viewport().set_input_as_handled()


func _on_continue_button_pressed() -> void:
	# This function runs when the user clicks "Continue"
	# 1. Unlock Player
	if player_node:
		player_node.set_movement_locked(false)
		
	# 2. Hide the whole UI
	visible = false
	queue_free() # Optionally destroy the dialogue scene

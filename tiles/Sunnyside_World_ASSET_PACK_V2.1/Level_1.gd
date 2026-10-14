extends Node2D

# --- Story Stage Enum (State Machine) ---
enum StoryStage {
	INIT,
	DAVID,
	DAVID_BROTHER,
	SOLDIERS,
	DAVID_FIGHT,
	GUARD,
	DIALOGUE_GENERAL, # Dialogue sequence from the existing panels
	GO_DAVID,
	DAVID_MOVING, # New stage for David's movement
	DAVID_COMBAT, # New stage for David's combat sequence
	QUIZ,
	COMPLETED
}
var current_story_stage: int = StoryStage.DAVID

# --- Node References ---
@onready var collision_immunity_timer: Timer = $ImmunityTimer
@onready var player_node: CharacterBody2D = $TileMap/Player
@onready var pause_panel: Panel = $UILayer/Pause_Panel
@onready var pause_button: TextureButton = $UILayer/Pause_btn
@onready var joystick: Control = $UILayer/VirtualJoystick

# David and Goliath Nodes (Assumed Paths based on Image)
@onready var david_sprite: AnimatedSprite2D = $NPC_David_Area/AnimatedSprite2D
@onready var goliath_sprite: AnimatedSprite2D = $Goliath

# New Timers for Combat and Quiz Delay
@onready var combat_switch_timer: Timer = $CombatSwitchTimer # Attach this Timer node in the editor (3.0s)
@onready var quiz_delay_timer: Timer = $QuizDelayTimer # Attach this Timer node in the editor (3.0s)

# Dialogue Panels for the Main Sequence
@onready var david_dialogue_panels: Array[Control] = [$UILayer/david_dialogue, $UILayer/david_dialogue2, $UILayer/david_dialogue3]
@onready var david_brother_dialogue_panels: Array[Control] = [$UILayer/david_brother_dialogue, $UILayer/david_brother_dialogue2, $UILayer/david_brother_dialogue3]
@onready var soldiers_dialogue_panels: Array[Control] = [$UILayer/Soldiers_dialogue, $UILayer/Soldiers_dialogue2, $UILayer/Soldiers_dialogue3]
@onready var david_fight_dialogue_panels: Array[Control] = [$UILayer/david_fight_dialogue, $UILayer/david_fight_dialogue2, $UILayer/david_fight_dialogue3, $UILayer/david_fight_dialogue4]
@onready var guard_dialogue_panels: Array[Control] = [$UILayer/guard_dialogue, $UILayer/guard_dialogue2, $UILayer/guard_dialogue3]
@onready var dialogue_general_panels: Array[Control] = [$UILayer/Dialogue, $UILayer/Dialogue2, $UILayer/Dialogue3, $UILayer/Dialogue4, $UILayer/Dialogue5, $UILayer/Dialogue6, $UILayer/Dialogue7, $UILayer/Dialogue8, $UILayer/Dialogue9]
@onready var go_david_dialogue_panels: Array[Control] = [$UILayer/go_david_dialogue, $UILayer/go_david_dialogue2]
@onready var special_dialogue_panel: Control = $UILayer/Special_Dialogue

# Quiz References
@onready var quiz_panel: Control = $UILayer/Quiz_Panel
@onready var quiz_label: Label = $UILayer/Quiz_Panel/Quiz_Content/Quiz_Label
@onready var quiz_input: LineEdit = $UILayer/Quiz_Panel/Quiz_Input
@onready var quiz_submit_button: Button = $UILayer/Quiz_Panel/Quiz_Content/Submit_Button
@onready var try_again_panel: Control = $UILayer/Try_Again_Panel
@onready var try_again_button: Button = $UILayer/Try_Again_Panel/Try_Again_Button
@onready var quiz_label_timer: Timer = $UILayer/Quiz_Panel/Quiz_Content/QuizLabelTimer

# --- State Variables ---
var can_complete_level: bool = false
var is_in_dialogue: bool = false
var is_david_moving: bool = false

var current_dialogue_index: int = 0
var current_dialogue_array: Array[Control] = [] # Tracks which array is active

# --- David Movement Variables ---
# Coordinates for David's movement (already verified in previous step)
var target_point_1: Vector2 = Vector2(0, -290) # Move UP first
var target_point_2: Vector2 = Vector2(-80, -290) # Move to Goliath's general area
const DAVID_MOVEMENT_SPEED: float = 150.0

var current_target: Vector2
var current_movement_phase: int = 0 # 0: idle, 1: to P1, 2: to P2

# --- Quiz Data and State ---
# Structure: {question: String, answers: Array[String]}
const QUIZ_DATA: Array = [
	{
		"question": "After David recieve the King's permission, 
		David rush to face Goliath 
and successfuly defeat Goliath, 
Quiz time
First Question: Who challenged and fought Goliath?

Click screen to submit",
		"answers": ["DAVID"]
	},
	{
		"question": "Second Question: What is the name of the king during this story?",
		"answers": ["SAUL"]
	},
	{
		"question": "Third Question: To whom were the supplies given? (Enter the person or group.)",
		"answers": ["SOLDIERS", "DAVID’S BROTHER", "DAVID'S BROTHER", "DAVID'S BROTHERS"]
	},
	{
		"question": "Final Question: In which Bible verse can the story of David and Goliath be found?",
		"answers": ["1 SAMUEL 17", "1 SAMUEL", "1SAMUEL17"]
	}
]
var current_quiz_index: int = 0
var current_correct_answers: Array = []

# Typewriter Effect Variables
var current_quiz_question: String = ""
var char_index: int = 0


# --- Initialization ---
func _ready():
	collision_immunity_timer.start(0.2)
	
	# Hide all panels
	var all_dialogue_panels: Array[Control] = david_dialogue_panels + david_brother_dialogue_panels + soldiers_dialogue_panels + \
									david_fight_dialogue_panels + guard_dialogue_panels + dialogue_general_panels + \
									go_david_dialogue_panels
									
	for panel in all_dialogue_panels:
		panel.visible = false
		
	special_dialogue_panel.visible = false
	quiz_panel.visible = false
	try_again_panel.visible = false
	
	pause_panel.visible = false
	pause_button.visible = true
	
	# Connect new timers
	combat_switch_timer.timeout.connect(_on_combat_switch_timer_timeout)
	quiz_delay_timer.timeout.connect(_on_quiz_delay_timer_timeout)
	
	quiz_label_timer.timeout.connect(Callable(self, "_on_quiz_label_timer_timeout"))
	
	call_deferred("connect_joystick")
	
func connect_joystick() -> void:
	if is_instance_valid(player_node) and is_instance_valid(joystick):
		joystick.joystick_moved.connect(Callable(player_node, "set_joystick_input"), CONNECT_DEFERRED)
		print("CONNECTION STATUS: Joystick connection attempted successfully.")
	else:
		print("CONNECTION STATUS: FAILED TO CONNECT (Player or Joystick node invalid).")

func _on_immunity_timer_timeout():
	can_complete_level = true
	print("Level completion trigger enabled.")
	
# --- Game Loop (For David's Movement) ---
func _process(delta: float):
	if is_david_moving:
		move_david(delta)

# --- David Movement and Combat Sequence ---
func start_david_movement() -> void:
	print("Starting David's Movement Sequence.")
	current_story_stage = StoryStage.DAVID_MOVING
	is_david_moving = true
	
	# Phase 1: Move to target_point_1
	current_target = target_point_1
	current_movement_phase = 1
	david_sprite.play("walk_up_david")
	
	# Player movement is now allowed during this phase via end_dialogue() fix
	if is_instance_valid(joystick):
		joystick.visible = true

func move_david(delta: float) -> void:
	# Get the main node holding David's position (NPC_David_Area in this case)
	var david_node = $NPC_David_Area
	
	if current_movement_phase == 1:
		# Move towards Target Point 1
		var direction: Vector2 = (current_target - david_node.position).normalized()
		david_node.position += direction * DAVID_MOVEMENT_SPEED * delta
		
		if david_node.position.distance_to(current_target) < 5.0:
			print("David reached Target Point 1. Starting Phase 2.")
			
			# Phase 2: Move to target_point_2
			current_target = target_point_2
			current_movement_phase = 2
			
			# Check direction to play correct animation (if needed)
			if current_target.x < david_node.position.x:
				david_sprite.play("walk_left_david")
			elif current_target.x > david_node.position.x:
				david_sprite.play("walk_right_david")
			
	elif current_movement_phase == 2:
		# Move towards Target Point 2 (Combat Point)
		var direction: Vector2 = (current_target - david_node.position).normalized()
		david_node.position += direction * DAVID_MOVEMENT_SPEED * delta
		
		if david_node.position.distance_to(current_target) < 5.0:
			print("David reached Target Point 2. Starting Combat.")
			david_node.position = current_target # Snap to position
			is_david_moving = false
			current_movement_phase = 0
			
			start_combat_sequence()

func start_combat_sequence() -> void:
	current_story_stage = StoryStage.DAVID_COMBAT
	
	# Combat Animations: Phase 1
	david_sprite.play("fight_david")
	goliath_sprite.play("fight_goliath")
	
	# Start timer for the switch (3.0 seconds)
	combat_switch_timer.wait_time = 3.0
	combat_switch_timer.one_shot = true
	combat_switch_timer.start()
	
func _on_combat_switch_timer_timeout() -> void:
	print("Switching combat animations (Phase 2). Starting 2s quiz delay.")
	
	# Combat Animations: Phase 2 (Attack/Defeat)
	david_sprite.play("attack_david")
	goliath_sprite.play("defeat_goliath")
	
	# Tanggalin ang koneksyon sa animation_finished, at simulan ang quiz delay timer KAAGAD.
	# Ang quiz delay timer ang magsisimula ng quiz pagkatapos ng 2 segundo.
	quiz_delay_timer.wait_time = 2.0 # Bagong 2-segundong delay para sa post-animation view
	quiz_delay_timer.one_shot = true
	quiz_delay_timer.start()

# Tinanggal na ang logic dito. Ang quiz delay ay nagsimula na sa _on_combat_switch_timer_timeout.
# Panatilihin natin itong function pero wala na itong gawin (or burahin kung hindi ito naka-connect kahit saan)
func _on_defeat_goliath_finished() -> void:
	pass
	
func _on_quiz_delay_timer_timeout() -> void:
	print("Quiz delay finished. Showing Quiz Panel.")
	
	# I-freeze ang animation ni Goliath at ibalik si David sa idle
	goliath_sprite.speed_scale = 0.0 
	david_sprite.play("idle_david") 
	
	# Disable player movement before starting the quiz
	if is_instance_valid(player_node) and player_node.has_method("disable_movement"):
		player_node.disable_movement()
	if is_instance_valid(joystick):
		joystick.visible = false

	current_story_stage = StoryStage.QUIZ
	start_quiz()

# --- NPC Interaction Logic (Core Dialogue Management) ---

# Checks if the attempted dialogue matches the current required story stage
func check_and_start_dialogue(stage: int, panels: Array[Control]) -> void:
	if stage == current_story_stage:
		start_dialogue(panels)
	else:
		start_dialogue([special_dialogue_panel]) # Show Special Dialogue panel

# Starts any dialogue sequence
func start_dialogue(panels: Array[Control]) -> void:
	if not can_complete_level or is_in_dialogue:
		return

	is_in_dialogue = true
	current_dialogue_array = panels
	current_dialogue_index = 0
	
	if not current_dialogue_array.is_empty():
		current_dialogue_array[current_dialogue_index].visible = true
		
	# FIX: ALWAYS disable player movement and hide joystick when ANY dialogue starts.
	# This ensures the 'Continue' button receives focus and clicks.
	if is_instance_valid(player_node) and player_node.has_method("disable_movement"):
		player_node.disable_movement()
		
	if is_instance_valid(joystick):
		joystick.visible = false
		
	print("Dialogue sequence started. Player movement disabled.")

# Advances to the next panel or ends the sequence
func advance_dialogue() -> void:
	if not current_dialogue_array.is_empty() and current_dialogue_index < current_dialogue_array.size():
		current_dialogue_array[current_dialogue_index].visible = false

	current_dialogue_index += 1
	
	if current_dialogue_index < current_dialogue_array.size():
		current_dialogue_array[current_dialogue_index].visible = true
	else:
		end_dialogue()
		
# Ends the dialogue and advances the story stage
func end_dialogue() -> void:
	# 1. Hide the last active panel
	if not current_dialogue_array.is_empty():
		var last_index = current_dialogue_array.size() - 1
		current_dialogue_array[last_index].visible = false
		
	# 2. Advance the story stage if the required dialogue was completed
	if current_dialogue_array == david_dialogue_panels and current_story_stage == StoryStage.DAVID:
		current_story_stage = StoryStage.DAVID_BROTHER
	elif current_dialogue_array == david_brother_dialogue_panels and current_story_stage == StoryStage.DAVID_BROTHER:
		current_story_stage = StoryStage.SOLDIERS
	elif current_dialogue_array == soldiers_dialogue_panels and current_story_stage == StoryStage.SOLDIERS:
		current_story_stage = StoryStage.DAVID_FIGHT
	elif current_dialogue_array == david_fight_dialogue_panels and current_story_stage == StoryStage.DAVID_FIGHT:
		current_story_stage = StoryStage.GUARD
	elif current_dialogue_array == guard_dialogue_panels and current_story_stage == StoryStage.GUARD:
		current_story_stage = StoryStage.DIALOGUE_GENERAL
	elif current_dialogue_array == dialogue_general_panels and current_story_stage == StoryStage.DIALOGUE_GENERAL:
		current_story_stage = StoryStage.GO_DAVID
	elif current_dialogue_array == go_david_dialogue_panels and current_story_stage == StoryStage.GO_DAVID:
		# IMPORTANT: Instead of starting the quiz, start David's movement sequence
		start_david_movement()
		
	# 3. Reset state and enable movement (unless movement or quiz started)
	is_in_dialogue = false
	current_dialogue_array = []
	current_dialogue_index = 0
	
	# FIX: Only disable player movement for the Quiz stage. Player can now move 
	# during the DAVID_MOVING phase (current_story_stage != StoryStage.QUIZ)
	if current_story_stage != StoryStage.QUIZ:
		if is_instance_valid(player_node) and player_node.has_method("enable_movement"):
			player_node.enable_movement()
			
		if is_instance_valid(joystick):
			joystick.visible = true
		
	if current_story_stage != StoryStage.DAVID_MOVING:
		print("Dialogue sequence ended. Player movement enabled.")


# --- Quiz Logic (Multi-Question) ---

# Loads the question and answers into the global variables and starts the typewriter
func load_current_question() -> void:
	if current_quiz_index >= QUIZ_DATA.size():
		return
		
	var question_data = QUIZ_DATA[current_quiz_index]
	current_quiz_question = question_data.question
	current_correct_answers = question_data.answers # Corrected variable name
	
	quiz_label.text = "" # Clear label
	quiz_input.text = "" # Clear input
	quiz_input.editable = true
	char_index = 0
	
	quiz_label_timer.wait_time = 0.05
	quiz_label_timer.start()
	
func start_quiz() -> void:
	# Disable player controls for the duration of the quiz
	if is_instance_valid(player_node) and player_node.has_method("disable_movement"):
		player_node.disable_movement()
	if is_instance_valid(joystick):
		joystick.visible = false

	current_quiz_index = 0
	quiz_panel.visible = true
	load_current_question()


func _on_quiz_label_timer_timeout():
	if char_index < current_quiz_question.length():
		quiz_label.text += current_quiz_question[char_index]
		char_index += 1
	else:
		quiz_label_timer.stop()

# Advances the quiz to the next question or completes the level
func advance_quiz() -> void:
	current_quiz_index += 1
	
	if current_quiz_index < QUIZ_DATA.size():
		# Load the next question
		print("Correct Answer! Advancing to Question %d." % (current_quiz_index + 1))
		load_current_question()
	else:
		# Final question answered correctly: Complete Level
		print("Final Answer Correct! Level 1 Complete!")
		current_story_stage = StoryStage.COMPLETED
		# Your completion logic:
		# NOTE: 'LevelCore' is assumed to be an autoloaded singleton.
		LevelCore.ach_3_earned = true
		LevelCore.ach_6_earned = true
		get_tree().change_scene_to_file("res://Scenes/1st_scene.tscn") # Example scene change

func _on_submit_button_pressed():
	var player_answer: String = quiz_input.text.to_upper().strip_edges()
	
	if current_correct_answers.has(player_answer): # Corrected variable name
		advance_quiz()
	else:
		# Wrong Answer: Show Try Again Panel
		print("Wrong Answer. Showing Try Again panel.")
		try_again_panel.visible = true
		quiz_input.editable = false
		
func _on_try_again_button_pressed():
	# Reset answer field and hide Try Again panel, then reload the SAME question
	try_again_panel.visible = false
	load_current_question() # Reloads the current question
	quiz_input.grab_focus()

# --- Signal Connections (Interaction Triggers) ---

# NPC DAVID MANAGER FUNCTION (Handles DAVID, DAVID_FIGHT, GO_DAVID stages for ONE Area2D)
func _on_npc_david_manager_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Only allow interaction if David is not currently moving or fighting
	if current_story_stage == StoryStage.DAVID_MOVING or current_story_stage == StoryStage.DAVID_COMBAT:
		return
	
	print("Entered NPC David's Area. Checking current story stage...")
	
	if current_story_stage == StoryStage.DAVID:
		start_dialogue(david_dialogue_panels)
	elif current_story_stage == StoryStage.DAVID_FIGHT:
		start_dialogue(david_fight_dialogue_panels)
	elif current_story_stage == StoryStage.GO_DAVID:
		start_dialogue(go_david_dialogue_panels)
	else:
		start_dialogue([special_dialogue_panel])


# NPC 2: DAVID_BROTHER Dialogue Trigger (Collision Area)
func _on_david_brother_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		check_and_start_dialogue(StoryStage.DAVID_BROTHER, david_brother_dialogue_panels)
		
# NPC 3: SOLDIERS Dialogue Trigger (Collision Area)
func _on_soldiers_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		check_and_start_dialogue(StoryStage.SOLDIERS, soldiers_dialogue_panels)

# NPC 5: GUARD Dialogue Trigger (Collision Area)
func _on_guard_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		check_and_start_dialogue(StoryStage.GUARD, guard_dialogue_panels)
		
# NPC 6: DIALOGUE_GENERAL Dialogue Trigger (Collision Area)
func _on_dialogue_general_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		check_and_start_dialogue(StoryStage.DIALOGUE_GENERAL, dialogue_general_panels)


# --- UI Connection (Advance Dialogue) ---

# Connect all "next" buttons (Next, Next2, Next3, Continue, Continue2, etc.) to this single function.
func _on_dialogue_next_button_pressed() -> void:
	advance_dialogue()

func _on_dialogue_continue_pressed() -> void:
	# Use this ONLY for single-panel close buttons, like on Special_Dialogue
	if is_in_dialogue and current_dialogue_array.size() == 1:
		end_dialogue()
	else:
		# If this is connected to a multi-panel sequence button, just advance (which will end the sequence)
		advance_dialogue()


# --- Pause/Exit Functions ---
func _on_exit_pressed() -> void:
	print("Exit pressed")

func _on_pause_btn_pressed() -> void:
	pause_panel.visible = true
	pause_button.visible = false
	get_tree().paused = true
	
	if is_instance_valid(joystick):
		joystick.visible = false


func _on_resume_pressed() -> void:
	pause_panel.visible = false
	pause_button.visible = true
	get_tree().paused = false
	
	if is_instance_valid(joystick):
		joystick.visible = true


func _on_game_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/1st_scene.tscn")

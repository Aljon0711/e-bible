extends Node2D

# ----------------- 1. DECLARATIONS -----------------

@onready var player = $Player
@onready var adam = $npc_adam
@onready var eve = $npc_eve
@onready var serpent = $npc_serpent
@onready var main_camera = $Player/Camera2D
@onready var tree_marker = $TreeMarker
@onready var hidden_spot = $HiddenSpot
@onready var dialogue_ui = $DialogueUI
@onready var animal_quiz_ui = $AnimalQuizUI
@onready var forbidden_fruit = $ForbiddenFruit 

# UI Elements
@onready var mission2_ui = $mission2_eve
@onready var mission2_panel = $Player/Camera2D/Mission2Layer/Mission2
@onready var food_label = $mission2_eve/FruitLabel
@onready var narration_ui = $NarrationUI
@onready var narration_label = $NarrationUI/ColorRect/NarrationLabel
@onready var mission3_leaves_ui = $mission3_leaves_ui
@onready var leaves_label = $mission3_leaves_ui/LeavesLabel

# Black Screen Element
@onready var black_screen = $BlackScreen

# Final quiz (lalabas pagkatapos ng narration) — nasa CanvasLayer para laging visible
@onready var final_quiz_ui = $Player/Camera2D/FinalQuizLayer/FinalQuizUI
@onready var final_quiz_question_label = $Player/Camera2D/FinalQuizLayer/FinalQuizUI/QuestionLabel
@onready var final_quiz_answer_input = $Player/Camera2D/FinalQuizLayer/FinalQuizUI/AnswerInput
@onready var final_quiz_submit = $Player/Camera2D/FinalQuizLayer/FinalQuizUI/SubmitButton

# Virtual joystick (mobile)
@onready var virtual_joystick = $Player/Camera2D/JoystickLayer/VirtualJoystick

# Status Flags
var dialogue_is_active = false
var dialogue_is_finished = false
var mission1_completed = false
var mission2_started = false
var mission2_completed = false
var fruits_collected = 0
const TOTAL_FRUITS_NEEDED = 8
var mission3_started = false
var mission3_completed = false
var leaves_collected = 0
const TOTAL_LEAVES_NEEDED = 3
var can_start_mission3 = false
var judgement_index = 0

# ----------------- 2. DIALOGUE & QUIZ DATA -----------------

const ADAM_EVE_ENCOUNTER_DIALOGUE = [
	{ "speaker": "Adam", "text": "Hey! Don’t go near that tree. It’s dangerous. If you eat its fruit, you’ll get into serious trouble." },
	{ "speaker": "Player", "text": "Why? What’s wrong with that fruit?" },
	{ "speaker": "Adam", "text": "The Lord God gave us a clear command regarding this tree." },
	{ "speaker": "Adam", "text": "Take care." }
]

const MISSION1_DIALOGUE = [
	{ "speaker": "Player", "text": "Adam, what keeps you busy?" },
	{ "speaker": "Adam", "text": "Excellent! Here are some animals. Could you try to name them?" }
]

const QUIZ_WIN_DIALOGUE = [
	{ "speaker": "Adam", "text": "Perfect! These names are exactly what I had in mind. Thank you for your help!" }
]

const QUIZ_LOSE_DIALOGUE = [
	{ "speaker": "Adam", "text": "Hmm... I don't think those names suit them quite well. Maybe we should try again?" }
]

const EVE_MISSION2_DIALOGUE = [
	{ "speaker": "Eve", "text": "Hello! I am Eve. God created me to be Adam’s companion." },
	{ "speaker": "Eve", "text": "Can you help me gather 8 pieces of food for our meal?" }
]

const EVE_COMPLETE_DIALOGUE = [
	{ "speaker": "Eve", "text": "Wonderful! You found all 8 pieces of food. Adam and I are very grateful!" }
]

const SERPENT_TEMPTATION_DIALOGUE = [
	{ "speaker": "Serpent", "text": "Did God really say, 'You must not eat from any tree in the garden'?" },
	{ "speaker": "Eve", "text": "We may eat fruit from the trees... but about the tree in the middle, God said we must not eat it, or we will die." },
	{ "speaker": "Serpent", "text": "You will not certainly die. For God knows that when you eat it, your eyes will be opened, and you will be like God." },
	{ "speaker": "Narration", "text": "*Eve picks up the forbidden fruit and eats it.*" }
]

const EVE_PERSUADES_ADAM = [
	{ "speaker": "Eve", "text": "Adam, try this. This fruit is beautiful and provides wisdom." },
	{ "speaker": "Adam", "text": "But Eve, God warned us..." },
	{ "speaker": "Eve", "text": "Look at me, I did not die. It is delicious, come and eat as well." },
	{ "speaker": "Narration", "text": "*Adam took the fruit and ate it. Suddenly, their eyes were opened.*" }
]

const MISSION3_DIALOGUE = [
	{ "speaker": "Eve", "text": "I feel so ashamed... we need to cover ourselves, Adam." },
	{ "speaker": "Adam", "text": "Please bring us 3 large fig leaves quickly." }
]

const LEAVES_COMPLETE_DIALOGUE = [
	{ "speaker": "Adam", "text": "Thank you. Now we can cover ourselves." },
	{ "speaker": "Adam", "text": "We broke the command. We must face the consequence." }
]

const FINAL_JUDGEMENT_SCENE = [
	{ "speaker": "Narration", "text": "The wind changed. A cold breeze swept through the garden as the sun began to set." },
	{ "speaker": "Narration", "text": "Suddenly, the voice of the Lord God echoed through the trees, calling out: 'Adam, where are you?'" },
	{ "speaker": "Adam", "text": "I heard you in the garden, and I was afraid because I was naked; so I hid." },
	{ "speaker": "Narration", "text": "The Lord God spoke to the Serpent: 'Because you have done this, cursed are you above all livestock. On your belly you will go, and eat dust all the days of your life.'" },
	{ "speaker": "Narration", "text": "To Eve, He said: 'I will make your pains in childbearing very severe; with painful labor you will give birth to children.'" },
	{ "speaker": "Narration", "text": "To Adam, He said: 'Cursed is the ground because of you; through painful toil you will eat food from it. By the sweat of your brow you will eat your food until you return to the ground.a'" },
	{ "speaker": "Narration", "text": "Because they disobeyed the command, they were led out of the beautiful garden of Eden." },
	{ "speaker": "Narration", "text": "To the east of Eden, God placed Cherubim and a flaming sword that turned every way to guard the way to the tree of life." }
]

const FINAL_QUIZ_QUESTION = "What did Adam and Eve eat that led to their punishment? (One word)"
const FINAL_QUIZ_ANSWERS = ["forbidden", "apple", "fruit", "knowledge"]  # accepted answers (lowercase)

# ----------------- 3. INITIAL SETUP -----------------

func _ready():
	# Gamitin ang camera ng player para makita ang Mission/Mission2
	main_camera.make_current()
	# UI Initial Setup
	if mission2_ui: mission2_ui.hide()
	if mission2_panel: mission2_panel.show()
	if narration_ui: narration_ui.hide()
	if mission3_leaves_ui: mission3_leaves_ui.hide()
	if black_screen: black_screen.hide()
	if final_quiz_ui: final_quiz_ui.hide()
	if final_quiz_submit:
		final_quiz_submit.pressed.connect(_on_final_quiz_submit_pressed)
	
	# Kamera Limits (I-adjust base sa sukat ng iyong Map)
	main_camera.limit_left = 0
	main_camera.limit_top = 0
	main_camera.limit_right = 1152 # I-adjust base sa pixel width ng map
	main_camera.limit_bottom = 648 # I-adjust base sa pixel height ng map
	main_camera.position_smoothing_enabled = true

	# Connect virtual joystick to player (mobile)
	if virtual_joystick and player and player.has_method("set_joystick_input"):
		virtual_joystick.joystick_moved.connect(player.set_joystick_input)

func _process(_delta):
	if not dialogue_is_active:
		main_camera.global_position = player.global_position

# ----------------- 4. MISSIONS LOGIC -----------------

func _on_forbidden_tree_trigger_body_entered(body):
	if body.name == player.name and not dialogue_is_active and not dialogue_is_finished:
		dialogue_is_active = true
		body.set_can_move(false)
		dialogue_ui.start_dialogue(ADAM_EVE_ENCOUNTER_DIALOGUE)
		dialogue_ui.dialogue_finished.connect(_on_adam_dialogue_finished, CONNECT_ONE_SHOT)

func _on_adam_dialogue_finished():
	dialogue_is_active = false
	dialogue_is_finished = true
	player.set_can_move(true)
	var tween = create_tween()
	adam.get_node("AnimatedSprite2D").play("walk-left")
	tween.tween_property(adam, "global_position", adam.global_position + Vector2(-200, 0), 2.0)
	tween.finished.connect(func(): adam.get_node("AnimatedSprite2D").play("idle"))

func _on_mission_1_adam_trigger_body_entered(body):
	if body.name == player.name:
		if dialogue_is_finished and not dialogue_is_active and not mission1_completed:
			dialogue_is_active = true
			body.set_can_move(false)
			dialogue_ui.start_dialogue(MISSION1_DIALOGUE)
			dialogue_ui.dialogue_finished.connect(start_mission1_quiz, CONNECT_ONE_SHOT)

func start_mission1_quiz():
	animal_quiz_ui.quiz_finished.connect(handle_mission1_result, CONNECT_ONE_SHOT)
	animal_quiz_ui.start_quiz()

func handle_mission1_result(success):
	dialogue_is_active = true
	if success:
		mission1_completed = true
		dialogue_ui.start_dialogue(QUIZ_WIN_DIALOGUE)
	else:
		dialogue_ui.start_dialogue(QUIZ_LOSE_DIALOGUE)
	dialogue_ui.dialogue_finished.connect(func(): 
		player.set_can_move(true)
		dialogue_is_active = false
	, CONNECT_ONE_SHOT)

func _on_eve_trigger_body_entered(body):
	if body.name == player.name:
		if mission1_completed and not mission2_started:
			dialogue_is_active = true
			body.set_can_move(false)
			dialogue_ui.start_dialogue(EVE_MISSION2_DIALOGUE)
			dialogue_ui.dialogue_finished.connect(func():
				mission2_started = true
				body.set_can_move(true)
				dialogue_is_active = false
				mission2_ui.show()
			, CONNECT_ONE_SHOT)
		elif fruits_collected == TOTAL_FRUITS_NEEDED and not mission2_completed:
			body.set_can_move(false)
			dialogue_ui.start_dialogue(EVE_COMPLETE_DIALOGUE)
			dialogue_ui.dialogue_finished.connect(func():
				mission2_completed = true
				mission2_ui.hide()
				start_serpent_event()
			, CONNECT_ONE_SHOT)

func collect_fruit():
	if mission2_started:
		fruits_collected += 1
		food_label.text = "Food: " + str(fruits_collected) + "/8"

func collect_leaf():
	if mission3_started:
		leaves_collected += 1
		leaves_label.text = "Leaves: " + str(leaves_collected) + "/3"

# ----------------- 5. SERPENT EVENT -----------------

func start_serpent_event():
	dialogue_is_active = true
	player.set_can_move(false)
	var duration = 4.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(main_camera, "global_position", tree_marker.global_position, duration)
	
	eve.get_node("AnimatedSprite2D").play("eve-walk-down")
	tween.tween_property(eve, "global_position", tree_marker.global_position + Vector2(-30, 0), duration)
	
	serpent.get_node("AnimatedSprite2D").play("default")
	tween.tween_property(serpent, "global_position", tree_marker.global_position + Vector2(30, 0), duration)
	
	tween.chain().finished.connect(func():
		eve.get_node("AnimatedSprite2D").play("idle")
		dialogue_ui.start_dialogue(SERPENT_TEMPTATION_DIALOGUE)
		dialogue_ui.dialogue_finished.connect(func():
			if forbidden_fruit:
				forbidden_fruit.hide() 
			adam_approaches_eve()
		, CONNECT_ONE_SHOT)
	)

func adam_approaches_eve():
	var adam_tween = create_tween()
	adam.get_node("AnimatedSprite2D").play("walk-right")
	var target_pos = Vector2(eve.global_position.x - 7, eve.global_position.y)
	adam_tween.tween_property(adam, "global_position", target_pos, 3.0)
	adam_tween.finished.connect(func():
		adam.get_node("AnimatedSprite2D").play("idle")
		eve.get_node("AnimatedSprite2D").play("eve-walk-west")
		dialogue_ui.start_dialogue(EVE_PERSUADES_ADAM)
		dialogue_ui.dialogue_finished.connect(walk_to_hidden_spot, CONNECT_ONE_SHOT)
	)

func walk_to_hidden_spot():
	var duration = 3.5
	var tween = create_tween().set_parallel(true)
	adam.get_node("AnimatedSprite2D").play("walk-down")
	tween.tween_property(adam, "global_position", hidden_spot.global_position + Vector2(20, 0), duration)
	eve.get_node("AnimatedSprite2D").play("eve-walk-down")
	tween.tween_property(eve, "global_position", hidden_spot.global_position + Vector2(-20, 0), duration)
	tween.tween_property(main_camera, "global_position", hidden_spot.global_position, duration)
	tween.chain().finished.connect(func():
		adam.get_node("AnimatedSprite2D").play("idle")
		eve.get_node("AnimatedSprite2D").play("idle")
		can_start_mission3 = true
		dialogue_is_active = false
		player.set_can_move(true)
	)

# ----------------- 6. MISSION 3 & FINAL CUTSCENE -----------------

func _on_mission_3_trigger_body_entered(body):
	if body.name == player.name and can_start_mission3 and not mission3_started:
		dialogue_is_active = true
		player.set_can_move(false)
		dialogue_ui.start_dialogue(MISSION3_DIALOGUE)
		dialogue_ui.dialogue_finished.connect(func(): 
			mission3_started = true
			mission3_leaves_ui.show()
			dialogue_is_active = false
			player.set_can_move(true)
		, CONNECT_ONE_SHOT)
	elif body.name == player.name and mission3_started and not mission3_completed and leaves_collected == TOTAL_LEAVES_NEEDED:
		mission3_completed = true
		player.set_can_move(false)
		mission3_leaves_ui.hide()
		dialogue_ui.start_dialogue(LEAVES_COMPLETE_DIALOGUE)
		dialogue_ui.dialogue_finished.connect(func():
			start_final_judgement_cutscene() 
		, CONNECT_ONE_SHOT)

func start_final_judgement_cutscene():
	judgement_index = 0
	dialogue_is_active = true 
	narration_ui.show()
	show_next_judgement_line()

func show_next_judgement_line():
	if judgement_index < FINAL_JUDGEMENT_SCENE.size():
		var line = FINAL_JUDGEMENT_SCENE[judgement_index]
		judgement_index += 1
		narration_label.text = line.speaker + ": " + line.text
	else:
		# Natapos ang narration — itago ang narration, ipakita ang Final Quiz
		narration_ui.hide()
		dialogue_is_active = false
		_start_final_quiz()

func _start_final_quiz():
	if final_quiz_ui and final_quiz_question_label and final_quiz_answer_input:
		final_quiz_question_label.text = FINAL_QUIZ_QUESTION
		final_quiz_answer_input.text = ""
		final_quiz_ui.show()
		final_quiz_answer_input.grab_focus()
	else:
		# Fallback kung wala ang FinalQuizUI
		LevelCore.ach_1_earned = true
		LevelCore.ach_4_earned = true
		call_deferred("_go_back")

func _on_final_quiz_submit_pressed():
	if not final_quiz_ui or not final_quiz_answer_input:
		return
	var answer = final_quiz_answer_input.text.to_lower().strip_edges()
	var correct = false
	for a in FINAL_QUIZ_ANSWERS:
		if answer == a or answer.begins_with(a) or a in answer:
			correct = true
			break
	if correct:
		final_quiz_ui.hide()
		LevelCore.ach_1_earned = true
		LevelCore.ach_4_earned = true
		call_deferred("_go_back")
	else:
		final_quiz_question_label.text = FINAL_QUIZ_QUESTION + "\n\n(Incorrect. Try again.)"
		final_quiz_answer_input.text = ""
		final_quiz_answer_input.grab_focus()

# ----------------- 8. INPUT HANDLING -----------------

# Gamitin ang _input para siguradong tumatanggap ng click/tap ang narration (kahit may naka-STOP na Control)
func _input(event):
	if event == null:
		return
	if narration_ui.visible:
		var advance = event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed)
		if advance:
			show_next_judgement_line()
			get_viewport().set_input_as_handled()

func _unhandled_input(event):
	if event == null:
		return
	
	# Tap screen para itago ang Mission2 intro panel
	if mission2_panel and mission2_panel.visible:
		if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			mission2_panel.hide()
			get_viewport().set_input_as_handled()
			return
		
	if narration_ui.visible:
		if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			show_next_judgement_line()
			get_viewport().set_input_as_handled()

func _go_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/1st_scene.tscn")

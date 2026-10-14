extends CanvasLayer

var current_question = 0
var questions = [
	{
		"question": "Who was God talking to?",
		"answer": "Noah"
	},
	{
		"question": "What did Noah build?",
		"answer": "Arc"
	}
]

var answered = false

func _ready():
	# Create the UI
	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.offset_left = -200
	panel.offset_top = -100
	panel.size = Vector2(400, 200)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Question label
	var question_label = Label.new()
	question_label.text = questions[current_question]["question"]
	question_label.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(question_label)
	
	# Answer input
	var answer_input = LineEdit.new()
	answer_input.placeholder_text = "Type your answer and press Enter"
	answer_input.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(answer_input)
	
	# Feedback label
	var feedback_label = Label.new()
	feedback_label.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(feedback_label)
	
	# Connect input signal
	answer_input.text_submitted.connect(func(text):
		check_answer(text, feedback_label, answer_input, question_label)
	)
	
	answer_input.grab_focus()

func check_answer(text: String, feedback_label: Label, answer_input: LineEdit, question_label: Label):
	var correct_answer = questions[current_question]["answer"].to_lower()
	var user_answer = text.to_lower().strip_edges()
	
	if user_answer == correct_answer:
		feedback_label.text = "Correct! ✓"
		feedback_label.add_theme_color_override("font_color", Color.GREEN)
		current_question += 1
		
		if current_question >= questions.size():
			# Quiz complete
			await get_tree().create_timer(1.0).timeout
			print("QUIZ COMPLETED!")
			LevelCore.ach_2_earned = true
			LevelCore.ach_5_earned = true
			call_deferred("_go_back")
		else:
			# Next question
			await get_tree().create_timer(1.0).timeout
			question_label.text = questions[current_question]["question"]
			feedback_label.text = ""
			feedback_label.remove_theme_color_override("font_color")
			answer_input.text = ""
			answer_input.grab_focus()
	else:
		feedback_label.text = "Incorrect. Try again."
		feedback_label.add_theme_color_override("font_color", Color.RED)
		answer_input.text = ""
		answer_input.grab_focus()

func _go_back() -> void:
	# Ensure this quiz node is removed from the scene tree so it doesn't persist
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/1st_scene.tscn")

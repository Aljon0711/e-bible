extends CanvasLayer

signal quiz_finished(success: bool)

@onready var panel = $PanelContainer
@onready var animal_image = $PanelContainer/VBoxContainer/AnimalImage
@onready var question_label = $PanelContainer/VBoxContainer/QuestionLabel

# Siguraduhin na ang path na ito ay tugma sa iyong Scene Tree
@onready var choice_buttons = [
	$PanelContainer/VBoxContainer/HBoxContainer/ChoiceA,
	$PanelContainer/VBoxContainer/HBoxContainer/ChoiceB,
	$PanelContainer/VBoxContainer/HBoxContainer/ChoiceC,
	$PanelContainer/VBoxContainer/HBoxContainer/ChoiceD
]

var current_index = 0
var score = 0

const QUIZ_DATA = [
	{
		"image": "res://images/chicken.jpg",
		"question": "What should we call this animal?",
		"answer": "Chicken",
		"choices": ["Chicken", "Duck", "Goat", "Turkey"]
	},
	{
		"image": "res://images/cow.jpg",
		"question": "How about this one?",
		"answer": "Cow",
		"choices": ["Cow", "Horse", "Sheep", "Buffalo"]
	},
	{
		"image": "res://images/duck.jpg",
		"question": "And this creature?",
		"answer": "Duck",
		"choices": ["Goose", "Duck", "Swan", "Hen"]
	},
	{
		"image": "res://images/pig.jpg",
		"question": "What is the best name for this?",
		"answer": "Pig",
		"choices": ["Boar", "Pig", "Donkey", "Goat"]
	},
	{
		"image": "res://images/sheep.jpg",
		"question": "And lastly, how about this?",
		"answer": "Sheep",
		"choices": ["Goat", "Calf", "Sheep", "Llama"]
	}
]

func _ready():
	panel.hide()
	# I-connect ang buttons ISANG BESES lang sa simula
	for btn in choice_buttons:
		btn.pressed.connect(_on_button_pressed.bind(btn))

func start_quiz():
	current_index = 0
	score = 0
	panel.show()
	load_question()

func load_question():
	if current_index >= QUIZ_DATA.size():
		finish_quiz()
		return
		
	var data = QUIZ_DATA[current_index]
	
	# 1. I-load ang dynamic text at image
	animal_image.texture = load(data.image)
	question_label.text = data.question # Dito kukunin ang text sa QUIZ_DATA
	
	# 2. I-update ang text ng buttons
	for i in range(choice_buttons.size()):
		choice_buttons[i].text = data.choices[i]
		choice_buttons[i].disabled = false # Siguraduhing hindi naka-disable

# Bagong function para i-handle ang click nang malinis
func _on_button_pressed(button: Button):
	# I-disable muna ang buttons para maiwasan ang double-click spam
	for btn in choice_buttons:
		btn.disabled = true
		
	var selected_name = button.text
	if selected_name == QUIZ_DATA[current_index].answer:
		score += 1
		print("Correct! Score: ", score)
	else:
		print("Wrong! Score: ", score)
	
	current_index += 1
	
	# Mag-delay ng konti (0.2s) para makita ang click bago lumipat
	await get_tree().create_timer(0.2).timeout
	load_question()

func finish_quiz():
	panel.hide()
	var is_success = (score == QUIZ_DATA.size())
	emit_signal("quiz_finished", is_success)

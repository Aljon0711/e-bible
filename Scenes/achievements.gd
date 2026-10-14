extends Control

# Lock Background (ColorRect or TextureRect) - Hide this when unlocked
@onready var ach_1_locked_bg: ColorRect = $lvl1_not_achieve
@onready var ach_2_locked_bg: ColorRect = $lvl2_not_achieve
@onready var ach_3_locked_bg: ColorRect = $lvl3_not_achieve
@onready var ach_4_locked_bg: ColorRect = $lvl1_not_old
@onready var ach_5_locked_bg: ColorRect = $lvl2_not_old
@onready var ach_6_locked_bg: ColorRect = $lvl3_not_old
# ... Add references for the other locked backgrounds

# Lock Icon (Sprite2D or TextureRect) - Hide this when unlocked
@onready var ach_1_lock_icon: Sprite2D = $Lock1 
@onready var ach_2_lock_icon: Sprite2D = $Lock2
@onready var ach_3_lock_icon: Sprite2D = $Lock3
@onready var ach_4_lock_icon: Sprite2D = $Lock4
@onready var ach_5_lock_icon: Sprite2D = $Lock5
@onready var ach_6_lock_icon: Sprite2D = $Lock6

func _ready() -> void:
	update_achievement_ui()

func is_ach_earned(index: int) -> bool:
	match index:
		1: return LevelCore.ach_1_earned
		2: return LevelCore.ach_2_earned
		3: return LevelCore.ach_3_earned
		4: return LevelCore.ach_4_earned
		5: return LevelCore.ach_5_earned
		6: return LevelCore.ach_6_earned
	return false


func update_achievement_ui() -> void:
	# --- ACHIEVEMENT 1 & 4 CODE (Unlocked by Level 1) ---
	# Check if ach_1_earned (lvl1_not_achieve) is TRUE
	if is_ach_earned(1): 
		ach_1_locked_bg.visible = false
		ach_1_lock_icon.visible = false
	else:
		ach_1_locked_bg.visible = true
		ach_1_lock_icon.visible = true
	
	# Check if ach_4_earned (lvl1_not_old) is TRUE
	if is_ach_earned(4): 
		ach_4_locked_bg.visible = false
		ach_4_lock_icon.visible = false
	else:
		ach_4_locked_bg.visible = true
		ach_4_lock_icon.visible = true
		
	# --- ACHIEVEMENT 2 & 5 CODE (Unlocked by Level 2) ---
	if is_ach_earned(2): 
		ach_2_locked_bg.visible = false
		ach_2_lock_icon.visible = false
	else:
		ach_2_locked_bg.visible = true
		ach_2_lock_icon.visible = true

	if is_ach_earned(5): 
		ach_5_locked_bg.visible = false
		ach_5_lock_icon.visible = false
	else:
		ach_5_locked_bg.visible = true
		ach_5_lock_icon.visible = true

	# --- ACHIEVEMENT 3 & 6 CODE (Unlocked by Level 3) ---
	if is_ach_earned(3):
		ach_3_locked_bg.visible = false
		ach_3_lock_icon.visible = false
	else:
		ach_3_locked_bg.visible = true
		ach_3_lock_icon.visible = true
		
	if is_ach_earned(6):
		ach_6_locked_bg.visible = false
		ach_6_lock_icon.visible = false
	else:
		ach_6_locked_bg.visible = true
		ach_6_lock_icon.visible = true

func _on_back_pressed() -> void:
	SfxPlayer.play_sfx_level()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

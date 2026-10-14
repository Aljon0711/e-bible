extends Node2D 

@onready var animated_sprite = $AnimatedSprite2D
# Maaaring DialogueTrigger (tile_map) o DialogueTrig (woodtile) ang pangalan ng child
@onready var dialogue_trigger: Area2D = $DialogueTrigger if has_node("DialogueTrigger") else $DialogueTrig

# Kapag natapos ang dialogue, huwag muling ipakita hanggang umalis ang player sa trigger
var dialogue_just_ended = false

func _ready():
	if dialogue_trigger:
		dialogue_trigger.body_exited.connect(_on_dialogue_trigger_body_exited)

func _on_dialogue_trigger_body_exited(body: Node2D):
	if body.is_in_group("player"):
		dialogue_just_ended = false

# --- DIALOGUE TRIGGER FUNCTION (Final, Stable Fix) ---
func _on_dialogue_trigger_body_entered(body: Node2D):
	
	if body.is_in_group("player"):
		# Huwag muling buksan ang Dialogic kung kakaratapos lang at nandito pa ang player
		if dialogue_just_ended:
			return

		# 1. Prevent re-triggering
		dialogue_trigger.set_deferred("monitoring", false) 
		
		var game_manager = get_node("/root/GameManager")
		
		# Check if GameManager exists
		if not game_manager:
			print("ERROR: GameManager not found!")
			dialogue_trigger.set_deferred("monitoring", true)
			return
		
		# 2. Decide which dialogue to show based on mission progress
		var timeline_to_start = 'Intro_Story_Mission_1'
		var should_activate_mission = 1  # Track which mission to activate after dialogue
		
		if game_manager.mission_3_intro_shown:
			# Mission 3 has started, no more dialogue with Noah
			dialogue_trigger.set_deferred("monitoring", true)
			return
		elif game_manager.mission_2_complete and not game_manager.mission_3_intro_shown:
			# Show Mission 3 intro and transport to Arc
			timeline_to_start = 'Mission_3_inTheArc'
			should_activate_mission = 3
		elif game_manager.mission_2_active:
			# Mission 2 is currently active, don't show any dialogue yet
			timeline_to_start = 'Mission 2'  # Can add a "still working on it" dialogue if you want
			should_activate_mission = 0
		elif game_manager.mission_1_complete and not game_manager.mission_2_active:
			# Show Mission_1_Complete first, then activate Mission 2
			timeline_to_start = 'Mission_1_Complete'
			should_activate_mission = 2
		elif game_manager.mission_1_active:
			# Mission 1 is currently active, player should be collecting wood
			timeline_to_start = 'Intro_Story_Mission_1'
			should_activate_mission = 0
		
		# 3. Start the dialogue
		var dialog_scene = Dialogic.start(timeline_to_start)
		get_tree().get_root().add_child(dialog_scene)
		
		# 4. FIX: Use the SceneTree timer to reliably wait for dialogue to finish.
		# This is the most reliable way to handle cleanup without problematic signals.
		# A 50ms timer is enough time for Dialogic to start.
		await get_tree().create_timer(0.05).timeout
		
		# 5. Wait for the Dialogic scene to be removed by Dialogic itself
		# We use the 'tree_exited' signal, which fires when the node is deleted.
		await dialog_scene.tree_exited 
		
		# 6. Trigger the mission update after the dialogue is fully gone
		if should_activate_mission == 1:
			game_manager.activate_mission_1()
			print("MISSION 1 ACTIVATED AFTER DIALOGUE!")
		elif should_activate_mission == 2:
			game_manager.activate_mission_2()
			print("MISSION 2 ACTIVATED AFTER DIALOGUE!")
		elif should_activate_mission == 3:
			game_manager.activate_mission_3()
			print("MISSION 3 ACTIVATED! Transporting to the Arc...")
			# Transport player to the Arc scene
			get_tree().change_scene_to_file("res://woodtile.tscn")
			return  # Don't re-enable trigger since we're changing scenes
		
		# 7. Re-enable the trigger at mark na kakaratapos lang ng dialogue
		dialogue_just_ended = true
		dialogue_trigger.set_deferred("monitoring", true)

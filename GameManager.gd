extends Node

# --- Mission 1 Variables (Wood) ---
var mission_1_active = false
var mission_1_complete = false
const mission_1_wood_goal = 5 

func activate_mission_1():
	mission_1_active = true
	print("MISSION 1 ACTIVATED!")

func complete_mission_1():
	if mission_1_active and not mission_1_complete:
		mission_1_complete = true
		print("MISSION 1 COMPLETED! Player can now return to Noah.")

# --- Mission 2 Variables (Food) ---
var mission_2_active = false
var mission_2_complete = false
const mission_2_food_goal = 5

func activate_mission_2():
	mission_2_active = true
	print("MISSION 2 ACTIVATED!")

func complete_mission_2():
	if mission_2_active and not mission_2_complete:
		mission_2_complete = true
		print("MISSION 2 COMPLETED! Player can now return to Noah.")

# --- Mission 3 Variables (Arc) ---
var mission_3_active = false
var mission_3_intro_shown = false
var mission_3_complete = false

func activate_mission_3():
	mission_3_active = true
	mission_3_intro_shown = true
	mission_3_complete = false
	print("MISSION 3 ACTIVATED! Player will be transported to the Arc.")

func complete_mission_3():
	if mission_3_active and not mission_3_complete:
		mission_3_complete = true
		mission_3_active = false
		print("MISSION 3 COMPLETED! Player reached the Arc.")

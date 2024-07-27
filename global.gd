extends Node

var player = null
var visual_box = null
var gloves_equipped : bool = true
var gloves_unlock_left : int = 3

# Store the previous scene's path
var previous_scene = ""

# Function to change to a new scene and store the current scene as previous
func change_scene(scene_path):
	previous_scene = get_tree().current_scene.filename
	get_tree().change_scene_to_file(scene_path)

# Function to go back to the previous scene
func go_back_to_previous_scene():
	if previous_scene != "":
		get_tree().change_scene_to_file(previous_scene)


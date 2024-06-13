extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://game.tscn")


func _on_options_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()

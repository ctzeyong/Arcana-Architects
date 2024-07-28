extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_options_button_pressed():
	%Help.visible = true

func _on_quit_button_pressed():
	get_tree().quit()


func _on_return_button_pressed():
	%Help.visible = false

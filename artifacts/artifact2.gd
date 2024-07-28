extends Control

func _on_next_level_button_pressed():
	%ToBeContinued.visible = true

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_quit_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

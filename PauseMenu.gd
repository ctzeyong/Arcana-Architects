extends Control

var main_menu = preload("res://menu.tscn").instantiate()

func resume():
	get_tree().paused = false

func pause():
	get_tree().paused = true

func test_esc():
	if Input.is_action_just_pressed("escape") && !get_tree().paused:
		$"..".visible = true
		pause()

	elif Input.is_action_just_pressed("escape") && get_tree().paused:
		$"..".visible = false
		resume()

func _on_resume_button_pressed():
	resume()
	$"..".visible = false

func _on_restart_button_pressed():
	resume()
	get_tree().reload_current_scene()
	$"..".visible = false

func _on_quit_to_menu_button_pressed():
	resume()
	$"..".visible = false
	get_tree().change_scene_to_file(main_menu)

func _process(delta):
	test_esc()


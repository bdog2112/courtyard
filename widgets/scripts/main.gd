extends Node3D


func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	# Toggle fullscreen
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Quit game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Reload scene
	if Input.is_action_just_pressed("start"):
		get_tree().reload_current_scene()

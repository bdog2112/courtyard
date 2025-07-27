# PROJECT TEMPLATE NOTES
# By default, IDE "embeds" the game window, which causes slower loading times.
# We can disable embedding. But, the setting is stored in an inconvenient place.
#
# In order to minimize wasted disk space and speed up project template copy
# times, it's preferable to delete the project's ".godot" folder. Unfortunately,
# the "embed game window" setting is stored in ".godot/editor/project_metadata.cfg".
#
# So, here is how to keep the template lean while retaining the desired setting.
# 1 Open ".godot" and delete everything except the "editor" folder.
# 2 Open "editor" folder and delete everything except "project_metadata.cfg".
#
# This will keep the desired settings while reducing clutter and waste.
extends Node3D


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit(0)

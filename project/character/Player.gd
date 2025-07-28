#extends KinematicBody
extends CharacterBody3D

# TTD:
# ANIMATION RELATED
# - Create idle to walk and walk to idle animations
# - Fix transition from idle to walk
# - Reverse Jumping Up animation to make falling to idle animation
# - Fix transition from falling to idle
# - Consider making idle to run and run to idle animations
# - Fix transition from falling to walkrun
# - Find way to show falling animation when walking off ledge (versus jumping)
# - Make character feet touch ground better on slopes
# - Make character rotate instead of flip when changing directions
# ENVIRONMENT RELATED
# - Create a more interesting environment
# - Create an elevator widget
# - Create moving platform widget
# - Create a conveyor belt widget
# - Create a catapult widget
# - Create rope swing widget
# - Test loading/unloading heavily detailed sections of terrain
# PLAYER ABILITIES
# - Fix issue where player can't jump while running downhill
# - Create levitate and teleport abilities
# - Create ledge traversing functionality
# - Create wall climbing functionality
# DEVELOPER RELATED
# - Create HUD overlay to display variables

@export var SPEED = 6.0
@export var JUMP_VELOCITY = 5 # 4.5
#@onready var camera: Camera = $CameraPivot/SpringArm/Camera
@onready var camera: Camera3D = $CameraPivot/SpringArm/Camera
@onready var xPivot = $CameraPivot
@onready var yPivot = $"." # Player
@onready var character = $Character
@onready var anim_player: AnimationPlayer = $Character/AnimationPlayer
@onready var anim_tree: AnimationTree = $Character/AnimationTree
@export var sens = 0.5
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var gravity = 9.8
var idle_blend_state := Vector3.ZERO
var last_print_time = Time.get_ticks_msec()
var last_detes_time = Time.get_ticks_msec()
var dynamic_detes: Label = Label.new()
#var theme: Theme = Theme.new()
var dete_dic: Dictionary = {}
var dete_update_interval = 500


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim_tree.active = true
	anim_player.get_animation("Idle(2)").loop = true
	anim_player.get_animation("Walking").loop = true
	anim_player.get_animation("Running").loop = true
#	anim_player.get_animation("Jumping Up").loop = true
	anim_player.get_animation("Falling Idle").loop = true
	anim_player.autoplay = "Idle(2)"
	dynamic_detes.add_theme_color_override("font_color", Color.BLACK)
	#dynamic_detes.text = "Dynamic Detes"
	add_child(dynamic_detes)
	velocity = Vector3.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		yPivot.rotate_y(deg_to_rad(-event.relative.x * sens))
		xPivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		xPivot.rotation.x = clamp(xPivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))


func _physics_process(delta):

	# Handle jump and other interactions
	var dir = _get_inputs()

	# Handle camera panning (process left stick inputs)
	_pan_the_camera()

	# Handla player movements (process right stick inputs)
	_process_movement(dir, delta)

	# Update character animation
	_update_animation(delta)


func _update_animation(delta):
	var hvel := Vector2(velocity.x, velocity.z).length()
	var blend_amount: float = 0
	var time_scale: float = 0

	if is_on_floor() and not hvel:
		# Character idle
		anim_tree.set("parameters/BlendIdleWalkRun/blend_amount", 0)
		anim_tree.set("parameters/BlendGroundAir/blend_amount", 0)
		# Reset the play head of BlendWalkRun to maintain animation sync.
		# Also, never set BlendWalkRun blend_amount to full 0 or 1. Always
		# keep it higher/lower by a fractional amount. When it's 0 or 1, the
		# animations become out of sync.
		anim_tree.set("parameters/Seek/seek_position", 0)
		pass
	elif is_on_floor():
		# Character running
		var max_out = 1.7 # 1.4
		time_scale = clamp(remap(hvel, 4.5, 5, 1.1, max_out), 1.1, max_out)
		anim_tree.set("parameters/BlendIdleWalkRun/blend_amount", 0.999)
		anim_tree.set("parameters/BlendGroundAir/blend_amount", 0)
		anim_tree.set("parameters/WalkTimeScale/scale", time_scale)
		anim_tree.set("parameters/RunTimeScale/scale", time_scale)
		pass
	elif Input.is_action_just_pressed("ui_jump") and not is_on_floor():
		# Character jumping/falling
		anim_tree.set("parameters/OneShotJump/active", true)
		anim_tree.set("parameters/BlendGroundAir/blend_amount", 1)

	#print_detes("2", "hvel: %s\nblend_amount: %s\ntime_scale: %s" % [hvel, blend_amount, time_scale], 500, dynamic_detes)


func print_output(text, update_interval):
	var cur_time = Time.get_ticks_msec()
	var elapsed_time = Time.get_ticks_msec() - last_print_time
	if elapsed_time > update_interval:
		last_print_time = cur_time
		print(text)

func print_detes(dete_id, text, update_interval, detes):
	# Print a list of "deets". Each has a unique "deet_id".
	# Use a single update_interval. Only updated it if it changes.
	# If a deet doesn't exist in the array, then add it.
	# If deet exists, then update it.
	# If update interval is reached, then print each row of array.
	# Never clear the array. Let it clear on restart.
	# Alternatively, let an input clear the array.
	var cur_time = Time.get_ticks_msec()
	# Update deet interval
	if not dete_update_interval == update_interval:
		dete_update_interval = update_interval
	# Add/update deet in dictionary
	if (not dete_dic.has(dete_id)) or (not dete_dic[dete_id] == text):
		dete_dic[dete_id] = text
	# Iterate deet array and print
	var elapsed_time = cur_time - last_detes_time
	if elapsed_time > update_interval:
		last_detes_time = cur_time
		detes.text = ""
		for dete in dete_dic:
			detes.text += dete_dic[dete] + "\n"


func _pan_the_camera():
	# TODO: See about implementing "get_vector" function and using "actions"
	# instead of reading the game controller directly.

	# Add some constants to help control camera panning
	var xSens = 5
	var ySens = 3
	var dead_zone = 0.05

	# Get joystick inputs for camera panning
	var ax: = Input.get_axis("ui_left", "ui_right")
	var ay: = Input.get_axis("ui_up", "ui_down")

	# Add a dead zone to center of the control sticks
	if abs(ax) < dead_zone:
		ax = 0
	if abs(ay) < dead_zone:
		ay = 0

	# Pan the camera
	yPivot.rotate_y(deg_to_rad(-ax * xSens))
	xPivot.rotate_x(deg_to_rad(-ay * ySens))
	xPivot.rotation.x = clamp(xPivot.rotation.x, deg_to_rad(-45), deg_to_rad(45))


func _get_inputs()->Vector3:
	# Character jump
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Quit game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Reload scene
	if Input.is_action_just_pressed("start"):
		get_tree().reload_current_scene()

	# Toggle fullscreen
	if Input.is_action_just_pressed("toggle_screen"):
		var mode := get_viewport().get_window().mode
		if mode == Window.MODE_FULLSCREEN:
			mode = Window.MODE_WINDOWED
		else:
			mode = Window.MODE_FULLSCREEN

		get_viewport().get_window().mode = mode

	# Get the input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_fwd", "move_back")
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	return direction


func _process_movement(direction, delta):
	var ground_decel = 2
	var air_decel = 0.01

	# Apply gravity when in mid-air
	if not is_on_floor():
		velocity.y -= gravity * 2 * delta
	elif not velocity.y == JUMP_VELOCITY:
		velocity.y = -1

	if direction and is_on_floor():
		# If pressing move and character on the ground then move quickly
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	elif is_on_floor():
		# If not pressing move and character on ground then decelerate quickly.
		velocity.x = move_toward(velocity.x, 0, ground_decel)
		velocity.z = move_toward(velocity.z, 0, ground_decel)
	else:
		# Character is airborne. Decelerate moderately.
		velocity.x = move_toward(velocity.x, 0, air_decel)
		velocity.z = move_toward(velocity.z, 0, air_decel)

	# Move the character and keep from sliding down slopes
	move_and_slide()
	apply_floor_snap()


	# Rotate character model to face in direction of control inputs
	if direction:
		var player_zbas = yPivot.global_transform.basis.z
		var target_y_rot = player_zbas.signed_angle_to(direction, Vector3.UP)
		character.rotation.y = target_y_rot

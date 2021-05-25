extends Spatial


class_name CameraManager

onready var spring_arm: SpringArm = get_node("CameraArm")
onready var camera = get_node("CameraArm/Camera")
export(NodePath) var target

#Camera Variables
var mouseDelta : Vector2 = Vector2()
export var camera_sensitivity = 0.5
export var min_angle = -70
export var max_angle = 75
export var default_camera_reset_time = 5
export var attach_offset: float

var camera_reset_time = 5
var default_camera_rotation

var camera_target: Spatial

#Camera Zoom-In Zoom-Out Variables
export var max_zoom: int = 10
export var min_zoom: int = 3
export var default_camera_length = 10
export var camera_zoom_speed = 1
export var camera_zoom_step = 1
var current_zoom = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_target = get_node(target)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_camera_rotation = rotation
	default_camera_length = spring_arm.get_length()
	pass # Replace with function body.

func handle_camera_zoom(zoom_value):
	
	spring_arm.set_length(current_zoom)
	pass

func _input(event):
	if event.is_action_pressed("zoom_in") and current_zoom > min_zoom:
		current_zoom -= camera_zoom_step	
	if event.is_action_pressed("zoom_out") and current_zoom < max_zoom:
		current_zoom += camera_zoom_step
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= event.relative.x * camera_sensitivity
			rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y * camera_sensitivity, min_angle, max_angle)
			camera_reset_time = 5
	if event.is_action_pressed("click1"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	camera_reset_time -= delta
	if (camera_reset_time <= 0):
		camera_reset_time = default_camera_reset_time
		rotation = default_camera_rotation
	#print(camera_reset_time)
	pass

func _physics_process(delta):
	
	if (spring_arm.get_length() !=  current_zoom):
		spring_arm.set_length(lerp(current_zoom, spring_arm.get_length(), delta))
	set_translation(camera_target.global_transform.origin)
	pass

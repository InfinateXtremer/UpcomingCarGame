extends Spatial

onready var spring_arm = get_node("camera_arm")
export(Shape) var vehicle_shape


#Camera Variables
var mouseDelta : Vector2 = Vector2()
export var camera_sensitivity = 0.5
var min_angle = -70
var max_angle = 75
var default_camera_reset_time = 5
var camera_reset_time = 5
var default_camera_rotation


#Camera Zoom-In Zoom-Out Variables
export(float) var max_zoom_out = 3
export(float) var mix_zoom_in = 10
export var camera_length = 10
export var camera_zoom_speed = 1
var current_zoom = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_camera_rotation = rotation
	pass # Replace with function body.

func handle_camera_zoom(zoom_value):
	
	spring_arm.set_length(current_zoom)
	pass

func _input(event):
	if event.is_action_pressed("zoom_out"):
		pass
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= event.relative.x * camera_sensitivity
			rotation_degrees.x -= event.relative.y * camera_sensitivity
			rotation_degrees.x = clamp(rotation_degrees.x, min_angle, max_angle)
			camera_reset_time = 5
	if event.is_action_pressed("click1"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _notification(what):
	match (what):
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			print("lost focus")
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			print("got focus")

func _process(delta):
	camera_reset_time -= delta
	if (camera_reset_time <= 0):
		camera_reset_time = default_camera_reset_time
		rotation = default_camera_rotation
	#print(camera_reset_time)
	pass
	
func setup_collision():
	pass

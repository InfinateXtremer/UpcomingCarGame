extends Spatial



onready var line = get_node("ImmediateGeometry")
onready var offset_suspension = get_node("Spatial")
onready var rigidbody = get_node("../")

onready var vehicle: RigidBody = get_node("..")
#Suspension
export var rest_length: float = .5
export var spring_travel: float = .3
export var spring_stiffness: float = 40000
export var damper_stiffness: float = 3000

var min_length: float = rest_length - spring_travel
var max_length: float = rest_length + spring_travel
var last_length: float
var spring_length: float
var spring_force: float
var spring_velocity: float
var damper_force: float


export var wheel_fl:bool
export var wheel_fr:bool
export var wheel_rl:bool
export var wheel_rr:bool
export var wheel_radius: float = .31

export var steer_angle: float
export var steer_time: float = 3

var suspension_force: Vector3
var wheel_velocity_local: Vector3
var Fx: float
var Fy: float
var wheel_angle: float

var Movement_V:float

var result

func _process(_delta):


	if Input.is_action_pressed("forward"):
		Movement_V = .1
	elif Input.is_action_pressed("backwards"):
		Movement_V = -.1
	else:
		Movement_V = 0


	line.clear()
	line.begin(Mesh.PRIMITIVE_LINES)
	""" Raycast location and ned
	line.add_vertex(Vector3.ZERO)
	var raycast_direction = -global_transform.basis.y
	var raycast = raycast_direction * raycast_length
	var raycast_end = Vector3.ZERO + global_transform.basis.xform_inv(raycast) 
	line.add_vertex(raycast_end)
	"""
		# End drawing.
	line.add_vertex(offset_suspension.transform.origin)
	line.set_color(Color(255, 0, 0))
	line.add_vertex(offset_suspension.transform.origin + Vector3.DOWN * (spring_length))
	line.set_color(Color(255, 0, 0))
	
	line.add_vertex(offset_suspension.transform.origin + Vector3.DOWN * (spring_length))
	line.set_color(Color(0, 255, 0))
	line.add_vertex(offset_suspension.transform.origin + Vector3.DOWN * (spring_length + wheel_radius))
	line.set_color(Color(0, 255, 0))
	line.end()
	rotation_degrees.y = rotation_degrees.y + wheel_angle
	wheel_angle = lerp(wheel_angle, steer_angle, steer_time * _delta)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _physics_process(delta):
	var raycast_length = max_length + wheel_radius
	#var raycast_start = global_transform.origin
	var raycast_start = offset_suspension.global_transform.origin
	var raycast_direction = -global_transform.basis.y
	var raycast = raycast_direction * raycast_length
	var raycast_end = raycast_start + raycast
	var space_state = get_world().direct_space_state
	# use global coordinates, not local to node
	result = space_state.intersect_ray(raycast_start, raycast_end)

	if result:
		#print("Started at:", self.global_transform.origin)
		#print("Hit at point: ", result.position)
		last_length = spring_length
		#Get distance
		var origin = raycast_start
		var collision_point = result.position
		var distance = origin.distance_to(collision_point)
		spring_length = distance - wheel_radius
		#spring_length = clamp(spring_length, min_length, max_length)
		spring_velocity = (last_length - spring_length) / delta
		spring_force = spring_stiffness * (rest_length - spring_length)
		damper_force = damper_stiffness * spring_velocity
		
		suspension_force = (spring_force + damper_force) * result.normal #* offset_suspension.global_transform.basis.y
		wheel_velocity_local = rigidbody.linear_velocity + rigidbody.angular_velocity.cross(result.position - global_transform.origin) # GetPointVelocity(hit.point) from unity
		#print(wheel_velocity_local)
		Fx = Movement_V * spring_force
		Fy = wheel_velocity_local.x * spring_force
		print(Fx * vehicle.transform.basis.z)	
		vehicle.add_force(suspension_force + (Fx * vehicle.transform.basis.z) + (Fy * -vehicle.transform.basis.x), result.position - vehicle.global_transform.origin)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

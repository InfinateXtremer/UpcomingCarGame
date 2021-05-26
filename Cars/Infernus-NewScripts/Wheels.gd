extends RayCast

var suspension: float
var dampening_strength: float
export var power_wheel: bool
export var turning_wheel: bool
var friction_slip: float
var max_velocity:float
var breaking_power:float
var engine_force:float
var thrust:float
var steering:float
var drifting_angle:float

var car_body:RigidBody

# Called when the node enters the scene tree for the first time.
func _ready():
	car_body = get_node("..")
	suspension = car_body.suspension
	dampening_strength = car_body.dampening_strength
	friction_slip = car_body.friction_slip
	max_velocity = car_body.max_velocity
	breaking_power = car_body.breaking_power
	engine_force = car_body.engine_force
	drifting_angle = car_body.drifting_angle
	pass # Replace with function body.

func _physics_process(delta):
	thrust = car_body.power_input
	var _engine_force = engine_force
	var _breaking_power = breaking_power
	"WHEN ADDING THE FORCE REMEMBER TO DO HIT - WHATEVER LOCATION"
	if is_colliding():
		var hit = get_collision_point() # we get raycast hit location
		var hit_distance = (hit - global_transform.origin).length() # we subtract hit's location from the raycast's start location and get the length to get distance
		var velocity_at_touch:Vector3 = car_body.linear_velocity + car_body.angular_velocity.cross(hit - car_body.global_transform.origin) # math to get velocity of car when hit happens
		var suspension_velocity:float = velocity_at_touch.dot(global_transform.basis.y) #we get speed of compression
		var damp = dampening_strength * suspension_velocity #we do damping by multipliying damp with suspension compression speed
		var raycast_length = cast_to.length() # entire suspension length
		var compressed_amound = raycast_length - hit_distance #by subtracting ray length through hit distance we get the compressed amount
		var compression = compressed_amound / raycast_length
		
		#project wheel's forward vector to ground so it doesn't go in the air while driving fast
		var normalized_wheel_forward = (global_transform.basis.z - global_transform.basis.z.project(get_collision_normal())).normalized()
		
		#make the car float
		car_body.add_force(global_transform.basis.y * (compression * suspension - damp) , hit - car_body.global_transform.origin)
		
		var slip_velocity:float = velocity_at_touch.dot(global_transform.basis.x)  #we get car x (left,right) velocity
		car_body.add_force(global_transform.basis.x * -slip_velocity * friction_slip, hit - car_body.global_transform.origin) #apply negative x(left,right) so car stops going left right
		
		#Check if car's speed is around 0.5 than stop the car
		if car_body.linear_velocity.length() <= 0.5: 
			car_body.add_force(-car_body.linear_velocity.normalized(), Vector3(0,0,0)) #apply negative force so the car stops and doesn't go on it's own
			
		if power_wheel: # wheels that drive the car forward, quarter force if they're not power wheels
			car_body.add_force(normalized_wheel_forward * _engine_force * thrust, hit - car_body.global_transform.origin)
		
		if car_body.breaking:
			car_body.add_force(-car_body.linear_velocity.normalized() * _breaking_power, hit - car_body.global_transform.origin)
			
		if car_body.linear_velocity.dot(car_body.global_transform.basis.x) >= drifting_angle or car_body.linear_velocity.dot(car_body.global_transform.basis.x) <= -drifting_angle:
			friction_slip = 2
		else:
			friction_slip = car_body.friction_slip

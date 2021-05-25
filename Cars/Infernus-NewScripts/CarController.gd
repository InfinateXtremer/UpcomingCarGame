extends RigidBody

export(Array, NodePath) var Wheel_Nodes = []
var Wheels = []


export var max_steering:float = 30

export var suspension: float = 1000
export var dampening_strength: float = 50
export var friction_slip: float = 10
export var max_velocity:float = 60
export var breaking_power:float = 2
export var engine_force:float = 10

var _max_steering:float

var power_input:float
var steering_input:float
var breaking:bool

func _ready():
	for wheel in Wheel_Nodes:
		Wheels.append(get_node(wheel))

func _input(event):
	if event.is_action_pressed("forward"):
		power_input = Input.get_action_strength("forward")
	if event.is_action_released("forward"):
		power_input = Input.get_action_strength("forward")
	if event.is_action_pressed("backwards"):
		power_input = -Input.get_action_strength("backwards")
	if event.is_action_released("backwards"):
		power_input = -Input.get_action_strength("backwards")
	if event.is_action_pressed("break"):
		breaking = true
	if event.is_action_released("break"):
		breaking = false
	if event.is_action_pressed("left"):
		steering_input = Input.get_action_strength("left")
	if event.is_action_released("left"):
		steering_input = Input.get_action_strength("left")
	if event.is_action_pressed("right"):
		steering_input = -Input.get_action_strength("right")
	if event.is_action_released("right"):
		steering_input = -Input.get_action_strength("right")

func _process(delta):
	#print(linear_velocity.length())
	pass

func _physics_process(delta):	
	
	
	#totally unique math and totally not taken from a big triple a game that have cars
	if linear_velocity.length() <= max_velocity / 4:
		_max_steering = max_steering * 1.2
	elif linear_velocity.length() < max_velocity /2:
		_max_steering = max_steering / 2.5

	for wheel in Wheels:
		if wheel.turning_wheel:
			#Problem max_steering multiplied with steering_input makes them 0, multipliying it again with wheel.transform.basis.y makes it everything become 0
			wheel.transform.basis = Basis(Quat(wheel.transform.basis.y, deg2rad(90) + (deg2rad(_max_steering) * steering_input)))
			pass
			
			
			
			
			
			
			
			

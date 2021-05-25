extends RayCast

export var max_force: float = 300.0
export var spring_force: float = 180.0
export var spring_stiffness: float = 0.85
export var spring_damping: float = 0.05
export var Xtraction: float = 1.0
export var Ztraction: float = 0.15


var last_distance : float = abs(cast_to.y)
var last_hit: Vector3

var current_velocity: Vector3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var parent_body: RigidBody

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_body = get_parent()
	pass # Replace with function body.


# function for applying drive force to parent body (if grounded)
func applyDriveForce(force : Vector3) -> void:
	if is_colliding():
		parent_body.apply_impulse(parent_body.global_transform.basis.xform(parent_body.to_local(get_collision_point())),force)


func _physics_process(delta) -> void:
	# if grounded, handle forces
	if is_colliding():
		# obtain instantaneaous linear velocity
		var curHit = get_collision_point()
		current_velocity = (curHit - last_hit) / delta
		
		# apply spring force with damping force
		var curDistance = (global_transform.origin - get_collision_point()).length()
		var FSpring = spring_stiffness * (abs(cast_to.y) - curDistance) 
		var FDamp = spring_damping * (last_distance - curDistance) / delta
		var suspensionForce = clamp((FSpring + FDamp) * spring_force,0,max_force)
		var suspensionImpulse = global_transform.basis.y * suspensionForce * delta
		
		# obtain axis velocity
		var ZVelocity = global_transform.basis.xform_inv(current_velocity).z
		var XVelocity = global_transform.basis.xform_inv(current_velocity).x
		
		# axis deceleration forces
		var XForce = -global_transform.basis.x * XVelocity * (parent_body.weight * parent_body.gravity_scale)/parent_body.rayElements.size() * Xtraction * delta
		var ZForce = -global_transform.basis.z * ZVelocity * (parent_body.weight * parent_body.gravity_scale)/parent_body.rayElements.size() * Ztraction * delta
		
		# counter sliding by negating off axis suspension impulse
		XForce.x -= suspensionImpulse.x * parent_body.global_transform.basis.y.dot(Vector3.UP)
		ZForce.z -= suspensionImpulse.z * parent_body .global_transform.basis.y.dot(Vector3.UP)
		
		# final impulse force vector to be applied
		var finalForce = suspensionImpulse + XForce + ZForce

			
		# note that the point has to be xform()'ed to be at the correct location. Xform makes the pos global
		parent_body.apply_impulse(parent_body.global_transform.basis.xform(parent_body.to_local(get_collision_point())),finalForce)
		last_distance = curDistance
		last_hit = curHit
	else:
		# not grounded, set prev values to fully extended suspension
		last_distance = -cast_to.y
		last_hit = to_global(cast_to)

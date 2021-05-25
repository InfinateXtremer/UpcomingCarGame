extends RayCast

var graphic

var mass = 1.00
var wheelRadius  = 0.33
var suspensionRange  = 0.28
var suspensionForce  = 400
var suspensionDamp  = 75
var compressionFrictionFactor  = 0.00

var sidewaysFriction  = 1
export var sidewaysDamp  = 10
export var sidewaysSlipVelocity  = 0.1
export var sidewaysSlipForce  = 1
export var sidewaysSlipFriction  = 1 
export var sidewaysStiffnessFactor  = 1

export var forwardFriction  = 1
export var forwardSlipVelocity  = 1
export var forwardSlipForce  = 1
export var forwardSlipFriction  = 1
export var forwardStiffnessFactor  = 1

var frictionSmoothing  = 0

var usedSideFriction  = 0.00
var usedForwardFriction  = 0.00
var sideSlip  = 0.00
var forwardSlip  = 0.00

var driven  = false;
var brake  = false;
var skidbrake  = false;

var speed  = 0.00

var RaycastHit = get_collision_point()

var car_body: RigidBody

var wheelCircumference = 0.00

var grounded = false;

func IsGrounded():
	return grounded

func _ready():
	wheelCircumference = wheelRadius * PI * 2
	car_body = get_node("..")

func _physics_process(delta):
	
	#transform.TransformDirection(Vector3.down)
	var down = -global_transform.basis.y 
	if is_colliding():
		var hit = get_collision_point()
		
		#parent.GetPointVelocity(hit.point);
		var velocityAtTouch:Vector3 = car_body.linear_velocity + car_body.angular_velocity.cross(hit - global_transform.origin) 
		
		"""hit.distance""" #hit.distance / (suspensionRange + wheelRadius);
		var compression:float = (global_transform.origin - get_collision_point()).length() / (suspensionRange + wheelRadius)
		compression = -compression + 1
		
		# -down * compression * suspensionForce;
		var force:Vector3 = -down * compression * suspensionForce
		
		#transform.InverseTransformDirection(velocityAtTouch);
		var t = global_transform.basis.xform_inv(velocityAtTouch)
		
		t.z = 0
		t.x = 0
		
		# shockDrag = transform.TransformDirection(t) * -suspensionDamp
		var shockDrag:Vector3 = global_transform.basis.xform(t) * -suspensionDamp
		
		# forwardDifference = transform.InverseTransformDirection(velocityAtTouch).z - speed;
		var forwardDifference:float = global_transform.basis.xform_inv(velocityAtTouch).z - speed
		
		# newForwardFriction = Mathf.Lerp(forwardFriction, forwardSlipFriction, forwardSlip * forwardSlip);
		var newForwardFriction:float = lerp(forwardFriction, forwardSlipFriction, forwardSlip * forwardSlip)
		
		#increase the current working friction value depending on how hard the shock is pressing the wheel against the ground
		#newForwardFriction = Mathf.Lerp(newForwardFriction, newForwardFriction * compression * 1, compressionFrictionFactor);
		newForwardFriction = lerp(newForwardFriction, newForwardFriction * compression * 1, compressionFrictionFactor);

		if (frictionSmoothing > 0):
			#usedForwardFriction = Mathf.Lerp(usedForwardFriction, newForwardFriction, Time.fixedDeltaTime / frictionSmoothing);
			usedForwardFriction = lerp(usedForwardFriction, newForwardFriction, delta / frictionSmoothing)
		else:
			usedForwardFriction = newForwardFriction;
		
		#transform.TransformDirection(new Vector3(0, 0, -forwardDifference)) * usedForwardFriction;
		var forwardForce:Vector3 = global_transform.basis.xform(Vector3(0, 0, -forwardDifference)) * usedForwardFriction;

		#forwardSlip = Mathf.Lerp(forwardForce.magnitude / forwardSlipForce, forwardDifference / forwardSlipVelocity, forwardStiffnessFactor);
		forwardSlip = lerp(forwardForce.length() / forwardSlipForce, forwardDifference / forwardSlipVelocity, forwardStiffnessFactor)
		
		#transform.InverseTransformDirection(velocityAtTouch).x;
		var sidewaysDifference:float = global_transform.basis.xform_inv(velocityAtTouch).x
		
		#Mathf.Lerp(sidewaysFriction, sidewaysSlipFriction, sideSlip * sideSlip);
		var newSideFriction:float = lerp(sidewaysFriction, sidewaysSlipFriction, sideSlip * sideSlip);
		
		newSideFriction = lerp(newSideFriction, newSideFriction * compression * 1, compressionFrictionFactor)
		
		if(frictionSmoothing > 0):
				usedSideFriction = lerp(usedSideFriction, newSideFriction, delta / frictionSmoothing)
		else:
				usedSideFriction = newSideFriction
		#transform.TransformDirection(new Vector3(-sidewaysDifference, 0, 0)) * usedSideFriction;
		var sideForce = global_transform.basis.xform(Vector3(-sidewaysDamp, 0, 0)) * usedSideFriction
		sideSlip = lerp(sideForce.length() / sidewaysSlipForce, sidewaysDifference / sidewaysSlipVelocity, sidewaysStiffnessFactor)
		
		t.z = 0;
		t.y = 0;
		
		#sideDrag = transform.TransformDirection(t) * -sidewaysDamp;
		var sideDrag:Vector3 = global_transform.basis.xform(t)* -sidewaysDamp
		
		#parent.AddForceAtPosition(force + shockDrag - forwardForce + sideForce + sideDrag, transform.position);
		car_body.add_force(force + shockDrag - forwardForce + sideForce + sideDrag, hit - global_transform.origin);

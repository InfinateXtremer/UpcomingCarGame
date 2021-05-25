extends Spatial

var R
var G
var B
var material
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	R = rng.randf_range(0, 1)
	rng.randomize()
	G = rng.randf_range(0, 1)
	rng.randomize()
	B = rng.randf_range(0, 1)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	material = $Cube001.get_surface_material(0)
	material.albedo_color = Color(R, G, B)
	$Cube001.set_surface_material(0, material)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player
var speed

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("../../Vehicle")
	pass # Replace with function body.

func _process(delta):
	speed = player.linear_velocity.length()
	set_text(String(player.linear_velocity.dot(player.global_transform.basis.x)))
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

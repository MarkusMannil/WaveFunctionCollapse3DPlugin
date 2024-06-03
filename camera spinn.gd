extends Spatial


export var center = Vector3(10,5,10)

export var radius :float  = 10

export var speed : float = 1

var angle = 0

signal spin_done

export var on = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !on:
		return
	angle += delta * speed
	
	if angle >= 2 * PI:
		emit_signal("spin_done")
		on = false
		angle = 0
	
	var x =  radius *  sin(angle)
	var y =  radius *  cos(angle)
	
	translation = center + Vector3(x, 0 , y)
	
	rotation = Vector3(rotation.x, angle ,rotation.z)
	
	
	pass

func set_on_on():
	on = true

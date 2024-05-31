extends Spatial


export var center = Vector3(10,5,10)

export var radius :float  = 10

export var speed : float = 1

var angle = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	angle += delta * speed
	
	
	
	var x =  radius *  sin(angle)
	var y =  radius *  cos(angle)
	
	translation = center + Vector3(x, 0 , y)
	
	rotation = Vector3(rotation.x, angle ,rotation.z)
	
	
	pass

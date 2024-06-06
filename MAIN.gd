extends Spatial


var demo_2  = "res://Demo_2.tscn"
var demo_3  = "res://demo_3.tscn"
var demo_4  = "res://demo_4.tscn"

var cur = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	demo_2 = load(demo_2)
	demo_3 = load(demo_3)
	demo_4 = load(demo_4)
	
	demo_2.connect("swap", self , "swap")
	demo_3.connect("swap", self , "swap")
	demo_4.connect("swap", self , "swap")
	
	get_tree().change_scene_to(demo_2)


func swap():
	
	if cur == 0:
		cur = 1 
		get_tree().change_scene_to(demo_3)
		pass
	
	if cur == 1:
		cur = 2
		get_tree().change_scene_to(demo_4)
		pass
	
	if cur == 2:
		cur = 0
		get_tree().change_scene_to(demo_2)
		
		pass

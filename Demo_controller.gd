extends Node

var wfc
var cam 



func _ready():
	wfc = $wave_function_collapse
	cam = $Camera
	
	wfc.connect("demo_end",self,"gen_end")
	cam.connect("spin_done",self,"generate_map")
	


func gen_end():
	cam.set_on_on()

func generate_map():
	wfc.run_wave_function_collapse()
	



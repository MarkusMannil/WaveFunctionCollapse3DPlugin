extends Node

var wfc
var cam 

var count
var max_ = 1

signal swap

func _ready():
	count = 0
	wfc = $wave_function_collapse
	cam = $Camera
	
	wfc.connect("demo_end",self,"gen_end")
	cam.connect("spin_done",self,"generate_map")
	


func gen_end():
	cam.set_on_on()
	count += 1
	

func generate_map():
	wfc.run_wave_function_collapse()
	if count == max_:
		emit_signal("swap")
		print("should swap")
	



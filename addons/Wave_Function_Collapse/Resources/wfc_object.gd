tool
extends Resource
class_name WFC_object

export var name : String = ""

export var mesh : Mesh

export  var id : int 

# id of same obj
var mesh_id : int

export var rotation : Vector3 = Vector3(0,0,0)

export(Array) var up  = Array()

export(Array) var down = Array()

export(Array) var forward = Array()

export(Array) var backward = Array()

export(Array) var right = Array()

export(Array) var left = Array()

func _init():
	up = []
	down = []
	forward = []
	backward = []
	right = []
	left = []

func get_mesh():
	return mesh
	
func set_mesh(new_mesh : Mesh):
	mesh = new_mesh


func get_rules():
	return [up , down ,forward, backward, right , left]
	
func get_rule_as_int():
	
	var rule = [0,0,0,0,0,0]
	
	
	for i in range(up.size()):
		rule[0] += 1 << up[i]
	
	
	for i in range(down.size()):
		rule[1] += 1 << down[i]
		
		
	for i in range(forward.size()):
		rule[2] += 1 << forward[i]
		
		
	for i in range(backward.size()):
		
		rule[3] += 1 << backward[i]
		
		
	for i in range(right.size()):
		rule[4] += 1 << right[i]
		

	for i in range(left.size()):
		rule[5] += 1 << left[i]
		
		
	return rule


func get_rule_of_index(index:int):
	match index:
		0:
			return forward
		1:
			return backward
		2:
			return right
		3:
			return left
		4:
			return up
		5:
			return down

func change_rule_of_index(value , side :int , index: int ):
	match side:
		0:
			 forward[index] = value
		1:
			 backward[index] = value
		2:
			 right[index] = value
		3:
			 left[index] = value
		4:
			 up[index] = value
		5:
			 down[index] = value

func delete_rule_of_index(side :int , index: int ):
	match side:
		0:
			 forward.pop_at(index)
		1:
			 backward.pop_at(index)
		2:
			 right.pop_at(index)
		3:
			 left.pop_at(index)
		4:
			 up.pop_at(index)
		5:
			 down.pop_at(index)

func add_rule_to_side(side : int, obj ):
	
	match side:
		0:
			forward.append(obj)
		1:
			backward.append(obj)

		2:
			right.append(obj)
			
		3:
			left.append(obj)
			
		4:
			up.append(obj)
			
		5:
			down.append(obj)
			

func copy_selected_to_all(side):
	var rule 
	match side:
		0:
			rule = forward.duplicate()
		1:
			rule = backward.duplicate()
			
		2:
			rule = right.duplicate()
			
		3:
			rule = left.duplicate()
			
		4:
			rule = up.duplicate()
			
		5:
			rule = down.duplicate()
	
	up  = rule
	down = rule
	right = rule
	left = rule
	forward = rule
	backward= rule


func add_rule_to_all(rule):
	up.append(rule)
	down.append(rule)
	right.append(rule)
	left.append(rule)
	forward.append(rule)
	backward.append(rule)


func set_rules_empty():
	forward = []
	backward = []
	right = []
	left = []
	up = []
	down = []

func rotate_rules_y90():
	var temp_r = right
	var temp_l = left
	
	right = backward
	left = forward
	forward = temp_r
	backward = temp_l

	pass


func rotate_rules_y180():
	
	var temp_r = right
	var temp_f = forward
	
	right = left
	left = temp_r
	forward = backward
	backward = temp_f
	
	pass

func rotate_rules_y270():
	
	var temp_r = right
	var temp_l = left
	
	right = forward
	left = backward
	forward = temp_l
	backward = temp_r
	
	pass


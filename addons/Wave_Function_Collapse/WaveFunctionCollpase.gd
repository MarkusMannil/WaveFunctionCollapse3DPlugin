tool
extends Node
class_name wave_function_collapse

var wfc_objects : Array

export var objects_resource : Resource 

var neighbour_shifts : Array

var adjacency_objects : Array

# size of every object
export var object_size : Vector3 = Vector3(1,1,1)

# grid start cordinate
export var start_pos : Vector3 

# pos - min bound lowest x y z cords : inclusive
export var min_bound : Vector3

# pos + max bound highest x y z cords : inclusive 
export var max_bound : Vector3 = Vector3(1,1,1)

export var run_with_ui_select : bool = true

var all : int

var rnd : RandomNumberGenerator

var map : Array

var grid_map : GridMap

var mesh_lib : MeshLibrary

var pos_tiles : Array
var start_collapsable : int
var nan_pos : wfc_position

var error : bool = false 
# set up warnings 
func _init():
	connect("child_entered_tree",self, "_on_wave_function_collapse_child_entered_tree")
	connect("child_exiting_tree",self, "_on_wave_function_collapse_child_exiting_tree")

func _get_configuration_warning():
	if grid_map == null:
		return "A GridMap node must be added or created for this node to work"
	else:
		return ""

func _on_wave_function_collapse_child_entered_tree(node):
	if node.get_class() == "GridMap":
		grid_map = node
		update_configuration_warning()

func _on_wave_function_collapse_child_exiting_tree(node):
	
	if node == grid_map:
		grid_map = null
		update_configuration_warning()
	
	pass # Replace with function body.

func get_wfc_resource():
	return objects_resource


func ready_grid_map():
	if grid_map == null:
		printerr("Add Gridmap to wave_function_collapse node child")
		return true
	
	if grid_map.mesh_library == null:
		printerr("Add MeshLibrary to Gridmap")
		return true
	
	grid_map.mesh_library.clear()
	grid_map.clear()
	grid_map.cell_size = object_size
	return false
	

func get_objects():
	
	if objects_resource == null:
		printerr("Add WFC_object_list resource to wave_function_collapse node")
		return true
	
	wfc_objects = []
	
	var count = 0
	
	for obj in objects_resource.object_list:
		
		wfc_objects.append(obj)
		obj.id = count 
		add_mesh_to_mesh_lib(obj.mesh)
		count += 1 
		if obj.r_90:
			var new_obj = duplicate_wfc_obj(obj)
			new_obj.rotation = obj.rotation + Vector3(0,90,0)
			new_obj.rotate_rules_y90()
			new_obj.id = count
			count+= 1
			wfc_objects.append(new_obj)
			add_mesh_to_mesh_lib(obj.mesh)
			
		if obj.r_180:
			var new_obj = duplicate_wfc_obj(obj)
			new_obj.rotation = obj.rotation + Vector3(0,180,0)
			new_obj.rotate_rules_y180()
			new_obj.id = count
			count+= 1
			wfc_objects.append(new_obj)
			add_mesh_to_mesh_lib(obj.mesh)
			
		if obj.r_270:
			var new_obj = duplicate_wfc_obj(obj)
			new_obj.rotation = obj.rotation + Vector3(0,270,0)
			new_obj.rotate_rules_y270()
			new_obj.id = count
			count+= 1
			wfc_objects.append(new_obj)
			add_mesh_to_mesh_lib(obj.mesh)
	
	adjacency_objects = []
	objects_resource.update_special_rules()
	for obj in wfc_objects:
		adjacency_objects.append([0,0,0,0,0,0])
		get_object_adj(obj)
		
	return false

func duplicate_wfc_obj(obj :WFC_object):
	
	var new = WFC_object.new()
	
	new.mesh = obj.mesh
	new.rotation = obj.rotation
	
	new.up = obj.up.duplicate()
	new.down = obj.down.duplicate()
	new.right = obj.right.duplicate()
	new.left = obj.left.duplicate()
	new.forward = obj.forward.duplicate()
	new.backward = obj.backward.duplicate()
	
	return new
	

func get_object_adj(object):
	
	var obj_rules = object.get_rule_as_int()
	
	var index = object.id
	
	var special = objects_resource.special_rules
	
	for i in range(wfc_objects.size()):
		# i- th object's rules
		
		var obj = wfc_objects[i]
		
		var rule = obj.get_rule_as_int()
		
		if(rule[0] & obj_rules[1] != 0):
			if rule[0] & obj_rules[1] & special == 0:
				adjacency_objects[index][1] += 1 << i
			
		if(rule[1] & obj_rules[0] != 0):
			if rule[1] & obj_rules[0] & special == 0:
				adjacency_objects[index][0] += 1 << i
			
		if(rule[2] & obj_rules[3] != 0):
			if rule[2] & obj_rules[3] & special == 0:
				adjacency_objects[index][3] += 1 << i
			
		if(rule[3] & obj_rules[2] != 0):
			if rule[3] & obj_rules[2] & special == 0:
				adjacency_objects[index][2] += 1 << i
			
		if(rule[4] & obj_rules[5] != 0):
			if rule[4] & obj_rules[5] & special == 0:
				adjacency_objects[index][5] += 1 << i
			
		if(rule[5] & obj_rules[4] != 0):
			if rule[5] & obj_rules[4] & special == 0:
				adjacency_objects[index][4] += 1 << i
	
func get_adj_of_object_side(obj_id, obj_side):
	
	obj_side = fix_side_logic(obj_side)
	if adjacency_objects[obj_id].size() == 0:
		return [] 
	
	var decimal_value = adjacency_objects[obj_id][obj_side]
	
	var list = []
	var temp 
	var count = wfc_objects.size()
	
	
	while(count >= 0): 
		temp = decimal_value >> count 
		if(temp & 1): 
			list.append(wfc_objects[count])
		count -= 1 
	
	return(list)


func run_wave_function_collapse():
	rnd = RandomNumberGenerator.new()
	
	var err = ready_grid_map()
	if err: 
		return
		
	err =  get_objects()
	
	if err: 
		return
	var start = OS.get_ticks_msec()
	wave_function_collapse()
	print(OS.get_ticks_msec() - start , " msec")

func fix_side_logic(ui_side):
	match ui_side:
		0:
			return 2
		1:
			return 3
		2:
			return 4
		3:
			return 5
		4:
			return 0
		5:
			return  1



func add_mesh_to_mesh_lib(mesh : Mesh):
	var id = grid_map.mesh_library.get_last_unused_item_id()
	grid_map.mesh_library.create_item(id)
	grid_map.mesh_library.set_item_mesh(id, mesh)
	return id

func get_neighbour_shifts():
	# y+ y- x+ z+ x- z-
	return [Vector3(0,1,0), Vector3(0,-1,0), Vector3(1,0,0), Vector3(-1,0,0), Vector3(0,0,1), Vector3(0,0,-1)]


func _input(event):
	if !run_with_ui_select:
		return
	
	if event.is_action_pressed("ui_select"):
		run_wave_function_collapse()


func get_rule_with_dir(possible : int, i : int):
	
	var temp
	var count = int(floor(log(possible) / log(2)) + 1)
	var ret = 0
	while(count >= 0): 
		temp = possible >> count 
		if(temp & 1): 
			ret |= adjacency_objects[count][i]
		count -= 1
	return ret

# returns the oposite dir rule index
func get_index_from_dir(dir : Vector3):
	# obj_rules = int[6] # y+ y- x+ z+ x- z-
	if dir.y == 1:
		return 1
	if dir.y == -1:
		return 0
	if dir.x == 1:
		return 3
	if dir.x == -1:
		return 2
	if dir.z == 1:
		return 5
	if dir.z == -1:
		return 4


func get_random_active_bit(mask : int):
	rnd.randomize()
	if(mask == 0):
		return -1
	var bit = 0;
	var mask_len = int(floor(log(mask) / log(2)) + 1)
	while true:
		var rndm = int(rnd.randi())
		bit = 1 << rndm % mask_len
		if bit | mask == mask :
			break
	return bit

func is_collapsed(cell : int):
	var log_2 = log(cell) / log(2)
	var ceilNum = ceil(log_2)
	var floorNum = floor(log_2)
	return ceilNum == floorNum

func get_entropy(mask:int):
	var count = 0
	var n = mask
	# if count zero then return high number
	if(mask == 0):
		return 1
		
	while n > 0:
		n &= (n-1)
		count += 1
	
	return count

func bit_to_index(mask : int):

	var temp 
	var count = int(floor(log(all) / log(2)) + 1)
 
	while(count >= 0): 
		temp = mask >> count 
		if(temp & 1): 
			return count
		count -= 1 
	
	return -1

func dec2bin(decimal_value : int): 
	var binary_string = "" 
	var temp 
	var count = wfc_objects.size() # Checking up to 16 bits 
 
	while(count >= 0): 
		temp = decimal_value >> count 
		if(temp & 1): 
			binary_string = binary_string + "1" 
		else: 
			binary_string = binary_string + "0" 
		count -= 1 

	return binary_string



func create_map():
	
	nan_pos = wfc_position.new(-1, -1,Vector3(-1,-1,-1),-1)
	pos_tiles = []
	
	start_collapsable = 0
	var index = 0
	all = int(pow(2,wfc_objects.size())-1)
	for x in range(max_bound.x - min_bound.x):
		for y in range(max_bound.y - min_bound.y):
			for z in range(max_bound.z - min_bound.z):
				pos_tiles.append(wfc_position.new(index,all,Vector3(x,y,z),wfc_objects.size()))
				index += 1
	
	var start : wfc_position
	
	for pos in pos_tiles:
		add_neighbours_to_pos(pos)
		if(pos.pos == start_pos):
			start = pos
			
	pos_tiles.shuffle()
	
	if start != null:
		swich_pos(0, pos_tiles.find(start))
	
	pass

func add_neighbours_to_pos(pos : wfc_position):
	var arr = []
	
	var index = vector_to_index(pos.pos + Vector3.UP)
	if index != -1:
		arr.append(pos_tiles[index])
	else:
		arr.append(nan_pos)
	
	index = vector_to_index(pos.pos + Vector3.DOWN)
	if index != -1:
		arr.append(pos_tiles[index])
	else:
		arr.append(nan_pos)
	
	index = vector_to_index(pos.pos + Vector3.FORWARD)
	if index != -1:
		arr.append(pos_tiles[index])
	else:
		arr.append(nan_pos)
	
	index = vector_to_index(pos.pos + Vector3.BACK)
	if index != -1:
		arr.append(pos_tiles[index])
	else:
		arr.append(nan_pos)
	
	index = vector_to_index(pos.pos + Vector3.RIGHT)
	if index != -1:
		arr.append(pos_tiles[index])
	else:
		arr.append(nan_pos)
	
	index = vector_to_index(pos.pos + Vector3.LEFT)
	if index != -1:
		arr.append(pos_tiles[index])
	else:
		arr.append(nan_pos)
		
	pos.neighbours = arr

func vector_to_index(vec : Vector3):
	
	if vec.x < 0 or vec.x >= max_bound.x - min_bound.x:
		return -1
	if vec.y < 0 or vec.y >= max_bound.y - min_bound.y:
		return -1
	if vec.z < 0 or vec.z >= max_bound.z - min_bound.z:
		return -1
	
	return vec.x * (max_bound.y - min_bound.y) * (max_bound.z - min_bound.z) + vec.y * (max_bound.z - min_bound.z) + vec.z
	
	pass

func select_next_cell():
	
	while pos_tiles[start_collapsable].entropy <= 1:
		start_collapsable += 1
		if start_collapsable == pos_tiles.size() :
			return null
	
	return pos_tiles[start_collapsable]

func collapse_cell(pos : wfc_position):
	
	var pos_i = pos_tiles.find(pos)
	
	pos.bit_value = get_random_active_bit(pos.bit_value)
	
	pos.entropy = 1
	
	start_collapsable += 1
	
	
	
	propagate_map(pos)

func propagate_map(pos : wfc_position):
	
	var stack = []
	var point = 0
	
	var val_0
	var val_1
	
	for neighbour in pos.neighbours:
		stack.append(pos)
		stack.append(neighbour)

	while stack.size() > point:
		val_0 = stack[point]
		val_1 = stack[point + 1]
		point += 2
		
		if propagate_pos_by_pos(val_0,val_1):
			for n in val_1.neighbours :
				stack.append(val_1)
				stack.append(n)

func propagate_pos_by_pos(col : wfc_position, pos : wfc_position):
	# if pos is already collapsed don't check it 
	if pos.entropy <= 1: 
		return false
	
	var rul_index = get_index_from_dir(col.pos - pos.pos)
	
	var get_rul = get_rule_with_dir(col.bit_value, rul_index)
	
	var new = get_rul & pos.bit_value
	# if calculated is different than current change pos data and return true for checking children else do nothing
	if pos.bit_value != new:
		pos.bit_value = new 
		pos.entropy = get_entropy(new)
		sort_pos_by_entropy(pos)
		
		return true
	else:
		return false

func sort_pos_by_entropy(pos : wfc_position):
	var start = pos_tiles.find(pos)
	var next = pos_tiles[min(start + 1, pos_tiles.size()-1)]
	# check if next is lower 
	for j in range(start , 0 , -1):
		#c += 1
		if pos_tiles[start].entropy >= pos_tiles[start - 1].entropy:
			break
		
		var index = start - 1
		var entropy = pos_tiles[start - 1].entropy
		
		var l = start_collapsable - 1
		var r = start - 1
		
		# find first of same e
		if  pos_tiles[start - 2].entropy < entropy:
			index = start -1
		else: 
			for i in range(start_collapsable, index):
				var check = (l + r)/2
				if l+1 == r:
					index = r
					break
				if pos_tiles[check].entropy == entropy:
					r = check
				else: 
					l = check
		# swap
		var temp = pos_tiles[start]
		
		pos_tiles[start] = pos_tiles[index]
		pos_tiles[index] = temp
		
		start = index
		if index == 0:
			break


func swich_pos(index_1 : int, index_2 : int):
	var temp = pos_tiles[index_1]
	pos_tiles[index_1] = pos_tiles[index_2]
	pos_tiles[index_2] = temp

func put_obj_to_map():
	
	for obj in pos_tiles:
		
		var obj_index = bit_to_index(obj.bit_value)
		
		if obj_index == -1:
			continue
		
		var myQuaternion = Quat(Vector3(0, 1, 0.0), deg2rad(wfc_objects[obj_index].rotation.y))
		var cell_item_orientation = Basis(myQuaternion).get_orthogonal_index()
		grid_map.set_cell_item(obj.pos.x + min_bound.x, obj.pos.y + min_bound.y, obj.pos.z + min_bound.z, obj_index, cell_item_orientation)
		

func wave_function_collapse():
	create_map()
	
	
	while start_collapsable < pos_tiles.size():
		var pos = select_next_cell()
		if pos == null:
			break

		collapse_cell(pos)
	
	
	put_obj_to_map()

	
	

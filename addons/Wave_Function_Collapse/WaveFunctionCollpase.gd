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

var all : int

var rnd : RandomNumberGenerator

var map : Array

var grid_map : GridMap

var mesh_lib : MeshLibrary


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
		grid_map = get_child(0)
	
	grid_map.mesh_library.clear()
	grid_map.clear()
	grid_map.cell_size = object_size
	

func get_objects():
	
	if grid_map == null:
		grid_map = get_child(0)
	
	wfc_objects.clear()
	
	var count = 0
	
	for obj in objects_resource.object_list:
		
		wfc_objects.append(obj)
		obj.id = count 
		add_mesh_to_mesh_lib(obj.mesh)
		
		count += 1 
		# todo -> rot_logic
	
	adjacency_objects.clear()
	objects_resource.update_special_rules()
	for obj in wfc_objects:
		adjacency_objects.append([0,0,0,0,0,0])
		get_object_adj(obj)
	
	

func get_object_adj(object):
	
	var obj_rules = object.get_rule_as_int()
	
	var index = object.id
	
	var same_mesh : bool 
	
	var special = objects_resource.special_rules
	
	for i in range(wfc_objects.size()):
		# i- th object's rules
		
		var obj = wfc_objects[i]
		
		var rule = obj.get_rule_as_int()
		
		same_mesh = obj.mesh_id == object.mesh_id
		
		if(rule[0] & obj_rules[1] != 0):
			
			if same_mesh && (rule[0] & obj_rules[1] & special != 0):
				continue 
			else:
				adjacency_objects[index][1] += 1 << i
			
		if(rule[1] & obj_rules[0] != 0):
			if same_mesh && (rule[0] & obj_rules[1] & special != 0):
				continue 
			else:
				adjacency_objects[index][0] += 1 << i
			
		if(rule[2] & obj_rules[3] != 0):
			if same_mesh && (rule[2] & obj_rules[3] & special != 0):
				continue 
			else:
				adjacency_objects[index][3] += 1 << i
			
		if(rule[3] & obj_rules[2] != 0):
			if same_mesh && (rule[3] & obj_rules[2] & special != 0):
				continue 
			else:
				adjacency_objects[index][2] += 1 << i
			
		if(rule[4] & obj_rules[5] != 0):
			if same_mesh && (rule[4] & obj_rules[5] & special != 0):
				continue 
			else:
				adjacency_objects[index][5] += 1 << i
			
		if(rule[5] & obj_rules[4] != 0):
			if same_mesh && (rule[5] & obj_rules[4] & special != 0):
				continue 
			else:
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

func set_up_grid():
	map = []
	all = int(pow(2,wfc_objects.size())-1)
	
	for i in range(max_bound.x - min_bound.x):
		map.append([])
		for j in range(max_bound.y - min_bound.y):
			map[i].append([])
			for _l in range(max_bound.z - min_bound.z):
				map[i][j].append(all) 
	pass

func run_wave_function_collapse():
	rnd = RandomNumberGenerator.new()
	
	ready_grid_map()
	get_objects()
	set_up_grid()
	neighbour_shifts = get_neighbour_shifts()
	
	wave_function_collapse()
	

func fix_side_logic(ui_side):
	match ui_side:
		0:
			return 2
		1:
			return 3
		2:
			return  4
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
	
# layer thing
func fill_base_with_obj(id : int):
	for i in range(map.size()):
		for j in range(map[0][0].size()):
			map[i][0][j] = 1 << id
			propegate_map(Vector3(i,0,j))


func wave_function_collapse():
	
	var cur = start_pos
	
	while true:
		collapse_cell(cur)
		cur = get_next_cell_to_collapse()
		if cur == null:
			break
	put_objects_to_scene()


func _input(event):
	if event.is_action_pressed("ui_select"):
		run_wave_function_collapse()


func get_next_cell_to_collapse():
	var lowest_entropy_cells = []
	var cur_low_entropy = all
	var temp
	
	for x in range(max_bound.x - min_bound.x):
		for y in range(max_bound.y - min_bound.y):
			for z in range(max_bound.z - min_bound.z):
				if is_collapsed(map[x][y][z]):
					continue
				temp = get_entropy(map[x][y][z]) 
				if(cur_low_entropy == temp):
					lowest_entropy_cells.append(Vector3(x,y,z))
				elif(cur_low_entropy > temp):
					cur_low_entropy = temp
					lowest_entropy_cells.clear()
					lowest_entropy_cells.append(Vector3(x,y,z))
	
	var random = int(rand_range(0, lowest_entropy_cells.size()))
	
	if(lowest_entropy_cells.size() == 0):
		return null
	return lowest_entropy_cells[random]


func collapse_cell(pos : Vector3):
	
	var possible = map[pos.x][pos.y][pos.z]
	
	# get random bit and turn it into an index
	
	var obj_index = get_random_active_bit(possible)
	
	map[pos.x][pos.y][pos.z] = obj_index
	
	obj_index = bit_to_index(obj_index)
	
	# debug_grids()

	propegate_map(pos)
	
	pass

func propegate_map(pos : Vector3):
	
	var stack = []
	var current = pos
	
	for i in neighbour_shifts:
		stack.append(current + i)
	
	var boolean
	while stack.size() != 0:
		current = stack.pop_back()
		# vaatame kas 
		if propagate_cell(current):
			for i in get_neighbour_shifts():
				stack.append(current + i)


func propagate_cell(pos : Vector3):
	
	if is_pos_out_of_bounds(pos):
		return false
	
	var val = map[pos.x][pos.y][pos.z]
	var before_val = map[pos.x][pos.y][pos.z]
	
	if is_collapsed(before_val):
		return false
	
	#   vaata iga suunas oleva celli võimalike muutujate summat ning leia nende ühisosa
	
	var chk_pos 
	
	for shifts in get_neighbour_shifts():
		chk_pos = pos + shifts
		if is_pos_out_of_bounds(chk_pos):
			continue
		else:
			var shift_val = map[chk_pos.x][chk_pos.y][chk_pos.z]
			var get_rul = get_rule_with_dir(shift_val, get_index_from_dir(shifts))
			
			before_val &= get_rul
	
	map[pos.x][pos.y][pos.z] = before_val
	
	return val != before_val

func is_pos_out_of_bounds(pos : Vector3): 
	
	if pos.x < 0 || pos.x >= map.size():
		return true
	
	if pos.y < 0 || pos.y >= map[0].size():
		return true
		
	if pos.z < 0 || pos.z >= map[0][0].size():
		return true
	return false


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

func put_objects_to_scene():
	
#	var cool_mesh = load("res://kenney_modular-buildings/roof-slanted-flat_roof-slanted-flat.mesh")
#	var cool_id = add_mesh_to_mesh_lib(cool_mesh)
	
	
	for x in range(max_bound.x - min_bound.x):
		for y in range(max_bound.y - min_bound.y):
			for z in range(max_bound.z - min_bound.z):
				assert(is_collapsed(map[x][y][z]), " cell not collapsed -" + str(map[x][y][z]))
				
				var obj_index = bit_to_index(map[x][y][z])
				
				if obj_index == -1: 
					#printerr("WFC set_cell ERROR at: ", x ,",", y , "," ,z)
					#grid_map.set_cell_item(x + min_bound.x, y + min_bound.y, z + min_bound.z, cool_id)
					pass
					
				else:
					var myQuaternion = Quat(Vector3(0, 1, 0.0), deg2rad(wfc_objects[obj_index].rotation.y))
					
					var cell_item_orientation = Basis(myQuaternion).get_orthogonal_index()
					
					grid_map.set_cell_item(x + min_bound.x, y + min_bound.y, z + min_bound.z, obj_index, cell_item_orientation)
	pass


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
		return null
		
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







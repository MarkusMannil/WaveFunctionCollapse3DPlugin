@tool
extends Control

var wfc_list : Resource

var wfc_node : wave_function_collapse

@onready var preview_list  = $"%GridContainer"
 
@onready var preview_object_prefab = preload("res://addons/Wave_Function_Collapse/Plugin_controll/Mesh_preview/Mesh_preview.tscn")

@onready var rule_box_prefab = preload("res://addons/Wave_Function_Collapse/Plugin_controll/rule_box/Rule_box.tscn")

@onready var rule_base_prefab = preload("res://addons/Wave_Function_Collapse/Plugin_controll/base_rule/Rule_base.tscn")

var selected_object : mesh_preview = null

var fov : int = 30
var height : int = 1
var dist : int = 2
var angle : int = -21

signal cam_settings_changed 

var rule_dict = {}

var selected_angle = 0

func _ready():
	if wfc_list == null:
		other_node_selected()
		return
	
	load_camera_settings()
	
	connect("cam_settings_changed", Callable(%Mesh_preview, "cam_settings_changed"))
	
	for i in preview_list.get_children():
		preview_list.remove_child(i)
	
	if wfc_list.has_method("get_objects"):
		for obj in wfc_list.get_objects():
			var preview_object = preview_object_prefab.instantiate()
			preview_object.set_object_resource(obj)
			preview_object.set_base(self)
			preview_list.add_child(preview_object)
			connect("cam_settings_changed", Callable(preview_object, "cam_settings_changed"))
	
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	
	

func WFC_node_selected(node):
	wfc_list = node.get_wfc_resource()
	wfc_node = node
	$"%Main_Panel".visible = true
	$"%Edit_panel".visible = false
	$"%no_selected_panel".visible = false
	set_obj_inactive()
	_ready()
	
func add_icons():
	var gui = EditorInterface.get_editor_theme()
	$Main_Panel/Control/Panel/Action_buttons/Add.icon = gui.get_icon("New", "EditorIcons")
	$Main_Panel/Control/Panel/Action_buttons/Edit.icon = gui.get_icon("Edit", "EditorIcons")
	$Main_Panel/Control/Panel/Action_buttons/Duplicate.icon = gui.get_icon("Duplicate", "EditorIcons")
	$Main_Panel/Control/Panel/Action_buttons/Delete.icon =  gui.get_icon("Remove", "EditorIcons")
	$Main_Panel/Control/Panel/Generate.icon = gui.get_icon("Play", "EditorIcons")
	$Main_Panel/Control/Panel/Clear_map.icon = gui.get_icon("Clear", "EditorIcons")
	$Main_Panel/Control/Panel/Edit_rules.icon = gui.get_icon("Edit", "EditorIcons")
	$Main_Panel/Control/Panel/view_settings.icon = gui.get_icon("GDScript", "EditorIcons")
	pass

func other_node_selected():
	$"%Edit_rule_panel".visible = false
	$"%Main_Panel".visible = false
	$"%Edit_panel".visible = false
	$"%no_selected_panel".visible = true
	
	pass

func set_obj_active(object):
	if selected_object != null:
		selected_object.deselect()
	selected_object = object
	$Main_Panel/Control/Panel/Action_buttons/Edit.disabled = false
	$Main_Panel/Control/Panel/Action_buttons/Duplicate.disabled = false
	$Main_Panel/Control/Panel/Action_buttons/Delete.disabled = false
	
func set_obj_inactive():
	selected_object = null
	$Main_Panel/Control/Panel/Action_buttons/Edit.disabled = true
	$Main_Panel/Control/Panel/Action_buttons/Duplicate.disabled = true
	$Main_Panel/Control/Panel/Action_buttons/Delete.disabled = true
	
func _on_Edit_pressed():
	load_rules_to_dict()
	# maybe message
	if selected_object == null:
		return
		
	$"%Mesh_preview".set_object_resource(selected_object.object_resource)
	
	_on_Front_pressed()
	
	$"%Rotate_90_2".button_pressed = selected_object.object_resource.r_90
	$"%Rotate_180_2".button_pressed = selected_object.object_resource.r_180
	$"%Rotate_270_2".button_pressed = selected_object.object_resource.r_270
	
	wfc_node.get_objects()
	
	load_rules_of_side(0)
	
	
	$"%Main_Panel".visible = false
	$"%Edit_panel".visible = true

func _on_Back_pressed():
	$"%Main_Panel".visible = true
	$"%Edit_panel".visible = false
	$"%Edit_rule_panel".visible = false
	$"%Camera_settings".visible = false
	ResourceSaver.save(wfc_list, wfc_list.resource_path)
	pass # Replace with function body.



## Add change object side  new rule
func _on_Add_rule_button_pressed():
	
	var side = selected_angle
	
	var rul_box = rule_box_prefab.instantiate()
	rul_box.innit_rule_list(wfc_list.rule_list, selected_object.object_resource.get_rule_of_index(selected_angle).size(), 0)
	
	
	selected_object.object_resource.add_rule_to_side(side, 1)
	
	rul_box.connect("rule_changed", Callable(self, "rule_changed"))
	rul_box.connect("del_rule", Callable(self, "delete_rule"))
	
	$"%Rule_container".add_child(rul_box)
	update_rules()
	
	pass

func load_rules_of_side(side:int):
	clear_rules()
	var count = 0
	for rule in selected_object.object_resource.get_rule_of_index(side):
		
		rule = rule_dict[rule]
		var rul_box = rule_box_prefab.instantiate()
		rul_box.innit_rule_list(wfc_list.rule_list, count ,rule.id - 1)
		rul_box.connect("rule_changed", Callable(self, "rule_changed"))
		rul_box.connect("del_rule", Callable(self, "delete_rule"))
		
		rul_box.index
		$"%Rule_container".add_child(rul_box)
		count += 1
	pass
	
func clear_rules():
	
	for i in $"%Rule_container".get_children():
		$"%Rule_container".remove_child(i)
		i.queue_free()
	pass

func rule_changed(val : ui_rule, index : int):
	
	selected_object.object_resource.change_rule_of_index(val.id, selected_angle , index)
	
	update_rules()
	pass

func delete_rule(index, obj):
	selected_object.object_resource.delete_rule_of_index(selected_angle ,index)
	
	$"%Rule_container".remove_child(obj)
	obj.queue_free()
	
	var c = 0
	for i in $"%Rule_container".get_children():
		i.index = c
		c += 1
		
	
	update_rules()
	pass

func _on_update_adj_pressed():
	update_rules()

func update_rules():
	ResourceSaver.save(wfc_list, wfc_list.resource_path)
	fill_adj_objects_container()
		
func fill_adj_objects_container():
	wfc_node.get_objects()
	for i in $"%adj_obj_container".get_children():
		i.queue_free()
	var adj_objs =  wfc_node.get_adj_of_object_side(selected_object.object_resource.id, selected_angle)
	
	if adj_objs == null:
		return
	
	for obj in adj_objs:
		var preview_object = preview_object_prefab.instantiate()
		preview_object.set_base(self)
		preview_object.set_object_resource(obj)
		preview_object.disable_label_and_click()
		preview_object.set_mesh_rotation(get_op_side_rot(selected_angle),Vector3(0,0,0))
		$"%adj_obj_container".add_child(preview_object)
		connect("cam_settings_changed", Callable(preview_object, "cam_settings_changed"))
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	

func get_op_side_rot(side : int) -> Vector3:
	
	match side:
		0: 
			return Vector3(0,180,0)
		1: 
			return Vector3(0,0,0)
		2: 
			return Vector3(0,270,0)
		3: 
			return Vector3(0,90,0)
		4: 
			return Vector3(180,0,0)
		5: 
			return Vector3(0,0,0)
	
	return Vector3()
	pass

## Delete object
func _on_Delete_pressed():
	if selected_object == null:
		return
	change_objects_clickable(false)
	$"%Warning".text = "Are you sure you want to delete object " + selected_object.object_resource.name
	$"%Delete_panel".visible = true
	pass # Replace with function body.

func change_objects_clickable(clickable : bool):
	for object in $"%GridContainer".get_children():
		object.clicable = clickable

func _on_Add_Cancel_button_pressed():
	change_objects_clickable(true)
	$"%name_line_edit".text = ""
	$"%Mesh_path_button".text = "[empty]"
	$"%Add_object_panel".visible = false
	$"%Err".visible = false	
	$"%preview".visible = false
	pass # Replace with function body.

func _on_Add_Save_button_pressed():
	var accept = save_new_resource()
	
	if accept:
		$"%Add_object_panel".visible = false
		$"%name_line_edit".text = ""
		$"%Mesh_path_button".text = "[empty]"
		$"%Resource_path_button".text = "[empty]"
		$"%Err".visible = false
		$"%preview".visible = false
		_ready()
	else:
		$"%Err".visible = true
	pass # Replace with function body.

## Add new object
func _on_Add_pressed():
	change_objects_clickable(false)
	$"%Add_object_panel".visible = true
	
	pass # Replace with function body.

func _on_Mesh_path_button_pressed():
	$"%Mesh_select".popup_centered_clamped(Vector2(500,500))
	pass # Replace with function body.

func _on_Resource_path_button_pressed():
	$"%Folder_select".popup_centered_clamped(Vector2(500,500))
	pass # Replace with function body.

func _on_Folder_select_dir_selected(dir):
	$"%Resource_path_button".text = dir
	$"%Resource_path_button".tooltip_text = dir
	pass # Replace with function body.

func _on_Mesh_select_file_selected(path):
	$"%Mesh_path_button".text = path
	$"%Mesh_path_button".tooltip_text = path
	
	$"%preview_control".set_mesh(load(path))
	$"%preview".visible = true
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	pass # Replace with function body.

func save_new_resource():
	
	var object_name = $"%name_line_edit".text
	var mesh_path =$"%Mesh_path_button".text
	var write_path =$"%Resource_path_button".text
	
	if object_name.is_empty():
		return false
	
	var new_obj = WFC_object.new()
	
	new_obj.name =object_name
	
	var mesh
	
	if mesh_path == "[empty]":
		mesh = null
	else:
		mesh = load(mesh_path)
	
	new_obj.set_mesh(mesh)
	
	wfc_list.add_resource(new_obj)
	
	new_obj.resource_name = object_name
	
	new_obj.set_rules_empty()
	
	ResourceSaver.save(wfc_list, wfc_list.resource_path)
	
	return true

func _on_Yes_pressed():
	wfc_list.remove_object_from_list(selected_object.object_resource)
	set_obj_inactive()
	_ready()
	$"%Delete_panel".visible = false
	ResourceSaver.save(wfc_list, wfc_list.resource_path)
	pass # Replace with function body.

func _on_No_pressed():
	change_objects_clickable(true)
	$"%Delete_panel".visible = false

# BASE RULES
func _on_Add_rule_to_rules_pressed():
	
	# object
	var rule_data = ui_rule.new()
	
	rule_data.id = $"%Base_rule_list".get_child_count() + 1 
	
	rule_data.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	
	# ui
	var rule = rule_base_prefab.instantiate()
	
	rule.set_rule(rule_data)
	
	rule.custom_minimum_size = Vector2(340, 80)
	
	$"%Base_rule_list".add_child(rule)
	
	rule.connect("rule_saved", Callable(self, "_save_rule"))
	rule.connect("rule_del", Callable(self, "_delete_rule"))
	
	
	ResourceSaver.save(wfc_list, wfc_list.resource_path)
	#
	
	pass # Replace with function body.

func _save_rule(rule):
	var added = false
	for i in wfc_list.rule_list:
		if rule == i:
			added = true
			break
	
	if not added :
		wfc_list.add_rule(rule)
		
	rule_dict[rule.id] = rule
	ResourceSaver.save(wfc_list ,wfc_list.resource_path)
	pass

func _delete_rule(rule : ui_rule, obj):
	wfc_list.rule_list.erase(rule)
	$"%Base_rule_list".remove_child(obj)
	obj.queue_free()
	rule_dict = {}
	
	var i = 1
	for rul in wfc_list.rule_list:
		rul.id = i
		rule_dict[i] = rul
		i += 1
		
	for child in $"%Base_rule_list".get_children():
		child.update()
	
	ResourceSaver.save(wfc_list,wfc_list.resource_path)
	pass

func _on_Edit_rules_pressed():
	load_rules_to_dict()
	for child in $"%Base_rule_list".get_children():
		$"%Base_rule_list".remove_child(child)
		child.queue_free()
	
	for rul in wfc_list.rule_list:
		var rule = rule_base_prefab.instantiate()
		rule.set_rule(rul)
		rule.set_view_mode()
		
		rule.connect("rule_saved", Callable(self, "_save_rule"))
		rule.connect("rule_del", Callable(self, "_delete_rule"))
		
		$"%Base_rule_list".add_child(rule)
	
	
	$"%Main_Panel".visible = false
	$"%Edit_panel".visible = false
	$"%no_selected_panel".visible = false
	$"%Edit_rule_panel".visible = true	


func load_rules_to_dict():
	for rule in wfc_list.rule_list :
		rule_dict[rule.id] = rule


## GEN MODE
func _on_Generate_pressed():
	
	wfc_node.run_wave_function_collapse()
	pass # Replace with function body.

## Duplicate 
func _on_Duplicate_pressed():
	
	if selected_object == null:
		return
	
	$"%Duplicate_object".visible = true
	$"%duplicate_label".text = "Duplicate object " + selected_object.object_resource.resource_name
	pass # Replace with function body.

func _on_cancel_duplicate_button_pressed():
	$"%Duplicate_object".visible = false
	pass # Replace with function body.

func _on_duplicate_button_pressed():
	
	var keep_rules = $"%Keep rules".pressed
	var new
	if $"%Rotate_90".pressed:
		new = duplicate_object(Vector3(0,90,0), keep_rules, "_90")
		new.rotate_rules_y90()
		pass
	if $"%Rotate_180".pressed:
		new = duplicate_object(Vector3(0,180,0), keep_rules, "_180")
		new.rotate_rules_y180()
		pass
	if $"%Rotate_270".pressed:
		new = duplicate_object(Vector3(0,270,0), keep_rules, "_270")
		new.rotate_rules_y270()
		pass
	if  !$"%Rotate_90".pressed and  !$"%Rotate_180".pressed and  !$"%Rotate_270".pressed:
		new = duplicate_object(Vector3(), keep_rules, "_new")
		pass
	
	_ready()
	
	$"%Duplicate_object".visible = false

func duplicate_object(rot : Vector3 , keep_rules: bool , name_add : String) -> WFC_object:
	
	## object being duplicated
	
	var original_obj: WFC_object = selected_object.object_resource
	
	# duplicate object
	
	var new_obj : WFC_object = WFC_object.new()
	
	new_obj.mesh = original_obj.mesh
	
	new_obj.name =  original_obj.resource_name + name_add
	
	new_obj.resource_name = original_obj.resource_name + name_add
	
	new_obj.rotation = rot
	
	if keep_rules :
		copy_rules(original_obj, new_obj)
	
	# add to objects list
	wfc_list.object_list.append(new_obj)
	
	return new_obj
	
	pass

func copy_rules(original_obj : WFC_object, new_obj : WFC_object):
	
	new_obj.up = original_obj.up.duplicate()
	new_obj.down = original_obj.down.duplicate()
	new_obj.right = original_obj.right.duplicate()
	new_obj.left = original_obj.left.duplicate()
	new_obj.forward = original_obj.forward.duplicate()
	new_obj.backward = original_obj.backward.duplicate()




func _on_Front_pressed():
	selected_angle = 0
	$"%Current_selected".text  = "Front"
	$"%Mesh_preview".set_mesh_rotation(Vector3(0,0,0),Vector3(0,0,0))
	load_rules_of_side(0)
	
	
	fill_adj_objects_container()
	pass # Replace with function body.

func _on_Back_side_pressed():
	selected_angle = 1
	$"%Current_selected".text  = "Back"
	$"%Mesh_preview".set_mesh_rotation(Vector3(0,180,0),Vector3(0,0,0))
	load_rules_of_side(1)
	
	fill_adj_objects_container()
	pass # Replace with function body.

func _on_Right_pressed():
	selected_angle = 2
	$"%Current_selected".text  = "Right"
	$"%Mesh_preview".set_mesh_rotation(Vector3(0,90,0),Vector3(0,0,0))
	load_rules_of_side(2)
	
	fill_adj_objects_container()
	pass # Replace with function body.

func _on_Left_pressed():
	selected_angle = 3
	$"%Current_selected".text  = "Left"
	$"%Mesh_preview".set_mesh_rotation(Vector3(0,270,0),Vector3(0,0,0))
	load_rules_of_side(3)
	
	fill_adj_objects_container()
	pass # Replace with function body.

func _on_Up_pressed():
	selected_angle = 4
	$"%Current_selected".text  = "Up"
	$"%Mesh_preview".set_mesh_rotation(Vector3(0,0,0),Vector3(0, -(wfc_node.object_size.y / 2) ,0))
	load_rules_of_side(4)
	
	fill_adj_objects_container()
	pass # Replace with function body.

func _on_Down_pressed():
	selected_angle = 5
	$"%Current_selected".text  = "Down"
	$"%Mesh_preview".set_mesh_rotation(Vector3(180,0,0),Vector3(0,wfc_node.object_size.y / 2,0))
	load_rules_of_side(5)
	
	fill_adj_objects_container()
	pass # Replace with function body.

func _on_Clear_map_pressed():
	wfc_node.ready_grid_map()
	pass # Replace with function body.

# Todo rename
func _on_copy_pressed():
	$"%rul_to_all_options".clear()
	
	for rul in wfc_list.rule_list:
		$"%rul_to_all_options".add_item(str(rul.id) +" "+ rul.rule_name)
		
		
	$"%rul_to_all_options".selected = 0
	$"%Rule_ to_all_sides".visible = true
	

func _on_rul_to_all_options_item_selected(index):
	
	$"%rul_to_all_color".color = wfc_list.rule_list[index].color
	pass # Replace with function body.


func _on_add_rul_to_all_pressed():
	
	selected_object.object_resource.add_rule_to_all($"%rul_to_all_options".selected + 1)
	update_rules()
	_on_cancel_rul_to_all_pressed()


func _on_cancel_rul_to_all_pressed():
	
	$"%Rule_ to_all_sides".visible = false
	load_rules_of_side(selected_angle)


func _on_view_settings_pressed():
	$"%Camera_settings".visible = true


func _on_fov_spin_value_changed(value):
	fov = value
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	
	wfc_list.camera_settings["fov"] = value


func _on_Height_spin_value_changed(value):
	height = value
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	wfc_list.camera_settings["height"] = value


func _on_Dist_spin_value_changed(value):
	dist = value
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	wfc_list.camera_settings["dist"] = value
	

func _on_angle_spin_value_changed(value):
	angle = value 
	emit_signal("cam_settings_changed", fov, height, dist, angle)
	wfc_list.camera_settings["angle"] = value
	
func load_camera_settings():
	fov = wfc_list.camera_settings["fov"]
	height = wfc_list.camera_settings["height"]
	dist = wfc_list.camera_settings["dist"]
	angle = wfc_list.camera_settings["angle"]
	$"%fov_spin".value = fov
	$"%Height_spin".value = height
	$"%Dist_spin".value = dist
	$"%angle_spin".value = angle
	pass


func _on_Rotation_pressed():
	$"%Rotation_panel".visible = true
	pass # Replace with function body.

func _on_Close_allow_rot_pressed():
	selected_object.object_resource.r_90 = $"%Rotate_90_2".button_pressed
	selected_object.object_resource.r_180 = $"%Rotate_180_2".button_pressed
	selected_object.object_resource.r_270 = $"%Rotate_270_2".button_pressed
	
	$"%Rotation_panel".visible = false
	update_rules()


func _on_Rotation2_pressed():
	$"%Rotation options".clear()
	$"%Rotation options".add_item("0", 0)
	$"%Rotation options".add_item("90", 1)
	$"%Rotation options".add_item("180", 2)
	$"%Rotation options".add_item("270", 3)
	
	var obj_y_r = selected_object.object_resource.rotation.y
	
	
	
	match int(obj_y_r):
		0: 
			$"%Rotation options".select(0)
			
		90: 
			$"%Rotation options".select(1)
			
		180: 
			$"%Rotation options".select(2)
			
		270:
			$"%Rotation options".select(3)
			
	
	$"%Object_rotation".visible = true 


func _on_save_rot_option_pressed():
	var sel = $"%Rotation options".get_selected_id()
	var v = selected_object.object_resource.rotation
	
	match sel:
		0: 
			selected_object.object_resource.rotation = Vector3(v.x, 0 ,v.z)
		1:
			selected_object.object_resource.rotation = Vector3(v.x, 90 ,v.z)
		2:
			selected_object.object_resource.rotation = Vector3(v.x, 180 ,v.z)
		3:
			selected_object.object_resource.rotation = Vector3(v.x, 270 ,v.z)
	
	$"%Mesh_preview".rotation_changed()
	$"%Object_rotation".visible = false
	pass # Replace with function body.

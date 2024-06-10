@tool
extends EditorPlugin

const wfc_main_control = preload("res://addons/Wave_Function_Collapse/Plugin_controll/Main_controll/Plugin_main_tab.tscn")


var docked_scene : Control

var editor_interface_selection

var already_exists : bool = false

signal WFC_node_selected

signal other_node_selected

signal show_icon

func _enter_tree():
	
	
	docked_scene = wfc_main_control.instantiate()
	
	editor_interface_selection = get_editor_interface().get_selection()
	editor_interface_selection.connect("selection_changed", Callable(self, "_on_selection_changed"))
	
	connect("WFC_node_selected", Callable(docked_scene, "WFC_node_selected"))
	connect("other_node_selected", Callable(docked_scene, "other_node_selected"))
	connect("show_icon", Callable(docked_scene, "add_icons"))
	
	pass


func _exit_tree():
	remove_control_from_bottom_panel(docked_scene)
	docked_scene.free()
	pass


func _on_selection_changed():
	var selected = editor_interface_selection.get_selected_nodes() 
	if not selected.is_empty():
		if selected[0].has_method("wave_function_collapse"):
			emit_signal("WFC_node_selected",selected[0])
			if !already_exists:
				var buton = add_control_to_bottom_panel(docked_scene, "Wave Function Collapse")
				emit_signal("show_icon")
				buton.button_pressed = true
				already_exists = true
		else:
			emit_signal("other_node_selected")
			remove_control_from_bottom_panel(docked_scene)
			already_exists = false

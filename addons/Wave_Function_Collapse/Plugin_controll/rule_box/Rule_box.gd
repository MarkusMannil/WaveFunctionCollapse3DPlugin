@tool
extends Control

signal del_rule

signal rule_changed

# list of ui_rules
var base_rules : Array
# n -th rule in object side
var index : int 
var selected : int

func _ready():
	$del_button.icon = EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons")
	pass


# index of rule in rules
func innit_rule_list(base, i, sel = 0):
	index =  i 
	selected = sel
	$"%rule_list".clear()
	
	base_rules = base
	if base_rules.size() == 0:
		return
	
	
	
	for rul  in base_rules:
		$"%rule_list".add_item( str(rul.id) +" "+ rul.rule_name)
	
	
	var rul = base_rules[selected]
	$"%ColorRect".color = rul.color
	$"%rule_list".select(selected)
	
	


# index of item in base_rules
func _on_rule_list_item_selected(i):
	
	var rul = base_rules[i]
	$"%ColorRect".color = rul.color
	selected = i
	emit_signal("rule_changed",rul, index)
	pass # Replace with function body.


func _on_del_button_pressed():
	emit_signal("del_rule", index, self)
	pass # Replace with function body.

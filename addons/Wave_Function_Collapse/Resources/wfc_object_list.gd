tool
extends Resource

class_name WFC_object_list

export(Array, Resource) var object_list : Array  = []

export(Array, Resource) var rule_list : Array  = []

var special_rules : int = 0 

func _init():
	object_list = []
	rule_list = []
	var rul = load("res://addons/Wave_Function_Collapse/Plugin_controll/base_rule/base_rule.tres")
	add_rule(rul)

func add_resource(resource : WFC_object):
	object_list.append(resource)
	

func add_rule(rule : ui_rule):
	rule_list.append(rule)

func get_objects():
	return object_list

func remove_object_from_list(obj):
	object_list.erase(obj)

func update_special_rules():
	var res = 0
	
	for i in range(rule_list.size()):
		var rule = rule_list[i]
		if rule.special :
			res += 1 << (i + 1)
	special_rules = res 


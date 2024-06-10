@tool
extends Control

var rule : ui_rule


signal rule_saved
signal rule_del

func _ready():
	$Main/Delete.icon = EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons")
	$Main/Edit.icon = EditorInterface.get_editor_theme().get_icon("Edit", "EditorIcons")
	pass
	
func set_rule(rul):
	rule = rul
	update()


func update():
	$"%Id".text = str(rule.id)
	$"%Name_label".text = rule.rule_name
	$"%ColorRect".color = rule.color
	$"%special_show".button_pressed = rule.special
	
	$"%Id_edit".text =  str(rule.id)
	$"%TextEdit".text = rule.rule_name
	$"%ColorPickerButton".color = rule.color
	$"%special".button_pressed = rule.special
	
func _on_Edit_pressed():
	custom_minimum_size = Vector2(340, 80)
	$"%Main".visible = false
	$"%Edit".visible = true
	
	$"%Id_edit".text = $"%Id".text
	$"%ColorPickerButton".color = $"%ColorRect".color
	$"%TextEdit".text = $"%Name_label".text
	$"%special".button_pressed = $"%special_show".button_pressed

func set_view_mode():
	custom_minimum_size = Vector2(340, 40)
	$"%Edit".visible = false
	$"%Main".visible = true
	if rule.id == 1:
		$"%Delete".disabled = true
	
func _on_Delete_pressed():
	# send data to main_ui
	emit_signal("rule_del", rule, self)
	pass # Replace with function body.


func _on_Save_pressed():
	if $"%TextEdit".text == "": # || $"%TextEdit".text == "[empty]" :
		return
		
	print($"%TextEdit".text)
	rule.rule_name = $"%TextEdit".text
	rule.color = $"%ColorPickerButton".color
	rule.special = $"%special".button_pressed
	$"%Name_label".text = $"%TextEdit".text
	$"%ColorRect".color = $"%ColorPickerButton".color
	$"%special_show".button_pressed = $"%special".button_pressed
	
	custom_minimum_size = Vector2(340, 40)
	$"%Main".visible = true
	$"%Edit".visible = false
	
	
	emit_signal("rule_saved", rule)
	# send data to main_ui
	pass # Replace with function body.


func _on_Cancel_pressed():
	custom_minimum_size = Vector2(340, 40)
	$"%Main".visible = true
	$"%Edit".visible = false
	pass # Replace with function body.


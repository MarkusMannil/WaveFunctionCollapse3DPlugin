tool
extends ViewportContainer
class_name mesh_preview

var camera : Camera
var border
var base
var object_resource : WFC_object

export var clicable : bool = true

func _ready():
	camera = $Viewport/Camera
	border = $ReferenceRect
	
	pass

func set_base(obj):
	base = obj

func set_mesh(mesh : Mesh):
	$"%MeshInstance".mesh = mesh

func get_mesh_instance_mesh():
	return $Viewport/MeshInstance.mesh

func set_object_resource(obj : WFC_object):
	object_resource = obj
	$"%MeshInstance".rotation_degrees = object_resource.rotation
	$"%MeshInstance".mesh = obj.mesh
	$"%name_label".text = obj.resource_name
	$"%name_label".visible = true

func disable_label_and_click():
	$"%name_label".visible = false
	clicable = false
	

func _on_Control_gui_input(event):
	if clicable and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			select()
			

func _on_ReferenceRect_gui_input(event):
	if clicable and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			deselect()
			

func set_mesh_rotation(rot : Vector3, pos : Vector3):
	
	$"%MeshInstance".rotation_degrees = object_resource.rotation + rot
	$"%MeshInstance".translation = pos

func select():
	border.visible = true
	base.set_obj_active(self)


func deselect():
	border.visible = false
	base.set_obj_inactive()


func _on_Panel_gui_input(event):
	if clicable and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			select()
	pass # Replace with function body.

func cam_settings_changed(fov, height, dist, ang):
	camera.fov = fov
	camera.translation = Vector3(dist,height,0)
	camera.rotation_degrees = Vector3(ang,90,0)


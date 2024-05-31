class_name wfc_position

var id : int 
var bit_value : int
var pos : Vector3
var neighbours : Array
var entropy : int


func _init(i : int , bit : int, position : Vector3 , e : int ):
	id = i
	bit_value = bit 
	pos = position 
	entropy = e 
	
func _to_string():
	return  "|" + str(entropy) + "|"

extends SeveredPart
class_name Knife

func get_class():
	return "Knife"


var female
var poly


func _ready():
	female = owner.get_node("Female")
	poly = get_node("../../polygons")
	

func drop():
	if !isEnabled:
		isEnabled = true
		
		poly.z_index = Utility.getAbsZIndex(female.get_node("polygons/ArmR/Knife"))
		poly.get_node("Knife").set_visible(true)
		
		position = female.skeleton.hand[R].get_global_position() + Vector2(5, 2)
		fall(Vector2(30, 20), -2.0 + 4.0*randf())


func landed():
	.landed()
	poly.z_index = -900

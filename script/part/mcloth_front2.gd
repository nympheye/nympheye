extends PhysChain
class_name MClothFront2

func get_class():
	return "MClothFront2"

var male

func _init().(false):
	pass

func _ready():
	male = owner.get_node("Male")

func parentVel():
	return get_parent().vel

func getAngForce():
	return [[-25,10e4],[-10,0],[20,0],[40,-10e4]]

func getAngDamp():
	return 175

func getLength():
	return 50

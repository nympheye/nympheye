extends PhysChain
class_name MClothFront3

func get_class():
	return "MClothFront3"

var male

func _init().(false):
	pass

func _ready():
	male = owner.get_node("Male")

func parentVel():
	return get_parent().vel

func getAngForce():
	return [[-40,10e4],[-20,0],[20,0],[40,-10e4]]

func getAngDamp():
	return 160

func getLength():
	return 40

extends PhysChain
class_name FClothFront3

func get_class():
	return "FClothFront3"

var female : Female

func _init().(false):
	pass

func _ready():
	female = owner.get_node("Female")

func parentVel():
	return get_parent().vel

func getAngForce():
	return [[-40,10e4],[-20,0],[20,0],[40,-10e4]]

func getAngDamp():
	return 150

func getLength():
	return 40

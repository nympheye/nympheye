extends PhysChain
class_name FClothFront1

func get_class():
	return "FClothFront1"

var female : Female

func _init().(false):
	pass

func _ready():
	female = owner.get_node("Female")

func parentVel():
	return female.vel

func getAngForce():
	return [[40,10e4],[75,0],[95,0],[130,-20e4]]

func getAngDamp():
	return 160

func getLength():
	return 40

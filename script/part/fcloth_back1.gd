extends PhysChain
class_name FClothBack1

func get_class():
	return "FClothBack1"

var female : Female

func _init().(false):
	pass

func _ready():
	female = owner.get_node("Female")

func parentVel():
	return female.vel

func getAngForce():
	return [[40,20e4],[75,0],[95,0],[130,-10e4]]

func getAngDamp():
	return 250

func getLength():
	return 80

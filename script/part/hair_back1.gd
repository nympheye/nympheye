extends PhysChain
class_name HairBack1

func get_class():
	return "HairBack1"

var female : Female

func _init().(false):
	pass

func _ready():
	female = owner.get_node("Female")

func parentVel():
	return female.vel

func getAngForce():
	return [[80,70e4],[90,0],[110,0],[120,-10e4]]

func getAngDamp():
	return 650

func getLength():
	return 60

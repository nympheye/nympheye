extends PhysChain
class_name HairFront

func get_class():
	return "HairFront"

var female : Female

func _init().(false):
	pass

func _ready():
	female = owner.get_node("Female")

func parentVel():
	return female.vel

func getAngForce():
	return [[75,3e4],[85,0],[95,0],[105,-8e4],[115,-12e4]]

func getAngDamp():
	return 270

func getLength():
	return 40

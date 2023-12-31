extends PhysChain
class_name MClothFront1

func get_class():
	return "MClothFront1"

var male

func _init().(false):
	pass

func _ready():
	male = owner.get_node("Male")

func parentVel():
	return male.vel

func getAngForce():
	return [[70,20e4],[95,0],[105,0],[140,-10e4]]

func getAngDamp():
	return 175

func getLength():
	return 50

func getRotation():
	var ang = .getRotation()
	if ang < -90:
		ang += 360
	return ang

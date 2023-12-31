extends PhysChain
class_name MClothBack1

func get_class():
	return "MClothBack1"

var male

func _init().(false):
	pass

func _ready():
	male = owner.get_node("Male")

func parentVel():
	return male.vel

func getAngForce():
	return [[50,10e4],[95,0],[105,0],[140,-20e4]]

func getAngDamp():
	return 260

func getLength():
	return 80

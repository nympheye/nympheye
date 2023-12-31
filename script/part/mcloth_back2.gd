extends PhysChain
class_name MClothBack2

func get_class():
	return "MClothBack2"

var male

func _init().(false):
	pass

func _ready():
	male = owner.get_node("Male")

func parentVel():
	return male.vel

func getAngForce():
	return [[-30,10e4],[-20,0],[0,0],[10,-20e4]]

func getAngDamp():
	return 260

func getLength():
	return 40

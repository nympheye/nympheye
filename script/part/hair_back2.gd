extends PhysChain
class_name HairBack2

func get_class():
	return "HairBack2"


var hair1 : PhysChain


func _init().(false):
	pass


func _ready():
	hair1 = get_parent()


func parentVel():
	return hair1.vel


func getAngForce():
	return [[-10,100e4],[0,0],[20,0],[30,-10e4]]


func getAngDamp():
	return 190


func getLength():
	return 50

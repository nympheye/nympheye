extends PhysChain
class_name FClothBack2

func get_class():
	return "FClothBack2"


var female : Female


func _init().(false):
	pass


func _ready():
	female = owner.get_node("Female")


func parentVel():
	return female.vel


func getAngForce():
	return [[-10,20e4],[0,0],[20,0],[30,-10e4]]


func getAngDamp():
	return 250


func getLength():
	return 40

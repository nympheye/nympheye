extends PhysChain
class_name ClothSegment

func get_class():
	return "ClothSegment"


const DRAG = 4.0


func _init().(false):
	pass


func _ready():
	physActive = false


func parentVel():
	return get_parent().vel


func getAngForce():
	return [[-10,1],[10,-1]]


func getAngDamp():
	return 150


func getLength():
	return 60


func externalForce():
	return .externalForce() - vel*DRAG


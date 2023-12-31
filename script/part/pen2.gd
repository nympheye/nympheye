extends PhysChain
class_name Pen2

func get_class():
	return "Pen2"


const ANG = -23


var male


func _init().(false):
	pass


func _ready():
	male = owner.get_node("Male")


func getAngForce():
	var erect = male.erect
	var ang = 15*erect
	var emult = 1.0 + 2.0*erect
	return [[ANG+ang,20e4*emult],[ANG+ang+11,0],[ANG+ang+20,-1e4],[max(ANG+35,ang+11),-30e4*emult]]


func getAngDamp():
	return 300*(1 + 2*male.erect*male.erect)


func getLength():
	return 25.0


func parentVel():
	return get_parent().vel


func getRotation():
	return rad2deg(transform.get_rotation() - 0.3*get_parent().transform.get_rotation())


func _process(delta):
	var erect = male.erect
	set_scale(getScale(erect))


static func getScale(erect):
	return Vector2(1 - 0.60*erect, 1 - 0.02*erect)

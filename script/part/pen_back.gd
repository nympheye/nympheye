extends PhysChain
class_name PenBack

func get_class():
	return "PenBack"


var male
var baseAng

var penetration
var contactDepth
var contactVect
var contactAngle


func _init().(false):
	pass


func _ready():
	male = owner.get_node("Male")
	baseAng = getRotation() + 2
	physActive = false
	penetration = 0.0
	contactDepth = 0.0
	contactVect = Vector2.ZERO
	contactAngle = 0


func parentVel():
	return male.vel


func getAngForce():
	return [[baseAng-10,10e4],[baseAng,0],[baseAng+5,0],[baseAng+15,-5e4]]


func externalForce():
	var tanVect = Vector2(-contactVect.y, contactVect.x)
	var dang = contactAngle - MGrabArmsPen.PEN_CONTACT_ANG
	var penetrationForce = -penetration*tanVect*(4e6*pow(dang, 3) + 4e3*dang)
	var missForce = 6e3*min(1, contactDepth/3)*contactVect*(1 - penetration)
	return penetrationForce + missForce + gravityForce()


func getAngDamp():
	return 250 + 2000*penetration


func getLength():
	return 35.0


func _physics_process(delta):
	pass

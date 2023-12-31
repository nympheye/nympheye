extends PhysChain
class_name LinPhysChain


var linVel
var basePos : Vector2
var origPos : Vector2
var distLim : Vector2


func _init(dirIn, distLimIn).(dirIn):
	linVel = Vector2(0,0)
	distLim = distLimIn


func _ready():
	basePos = transform.origin - gravityForce()/getLinForce()
	origPos = transform.origin


func _physics_process(delta):
	if !physActive:
		return
	delta *= timescale
	
	var velDiff = linVel - linParentVel().rotated(-get_parent().get_global_rotation())
	var accel : Vector2
	var displacement = transform.origin - basePos
	
	var force = getLinForce()
	if abs(displacement.y) > distLim[0] && sign(velDiff.y) == sign(displacement.y):
		force *= 4
	
	accel = -force*displacement
	accel += externalForce()
	accel -= velDiff*getLinDamp()
	linVel += delta*accel
	transform.origin += delta*(velDiff + delta*accel/2)


func parentVel():
	return linVel


func linParentVel():
	return null


func getLinForce():
	return null


func getLinDamp():
	return null


extends LinPhysChain
class_name BreastL

func get_class():
	return "BreastL"


const TOP_SHIFT = Vector2(-5, -3)


var female : Female
var origBasePos : Vector2


func _init().(true, Vector2(25, 25)):
	pass


func _ready():
	var options = get_node("/root/Options")
	female = owner.get_node("Female")
	origBasePos = basePos + TOP_SHIFT + Vector2(-2, 0)
	timescale = 1.3
	scale = options.fbreastScale*scale


func _process(delta):
	if !physActive:
		return
		
	basePos = origBasePos
	if female.isArmsUp:
		basePos += Vector2(-5, -21)
	else:
		var armAng = female.skeleton.arm[L].get_rotation_degrees()
		var upAmt = clamp((55-armAng)/65, 0, 1)
		basePos += upAmt*Vector2(-4, -23)


func removeTop():
	origBasePos -= TOP_SHIFT


func linParentVel():
	return female.vel


func getAngForce():
	return [[15,15e4],[25,0],[35,0],[45,-30e4]]


func getAngDamp():
	if female.hasTop:
		return 700
	else:
		return 300


func getLength():
	return 35


func getLinForce():
	if female != null && female.hasTop:
		return Vector2(600,250)
	else:
		return Vector2(250,150)


func getLinDamp():
	if female.hasTop:
		return 18
	else:
		return 9



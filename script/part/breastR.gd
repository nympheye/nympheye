extends LinPhysChain
class_name BreastR

func get_class():
	return "BreastR"


const TOP_SHIFT = Vector2(0, -3)


var female : Female
var origBasePos : Vector2
var breastPoly


func _init().(true, Vector2(25, 30)):
	pass


func _ready():
	var options = get_node("/root/Options")
	female = owner.get_node("Female")
	breastPoly = female.get_node("polygons/Body/Body/BreastR")
	origBasePos = basePos + TOP_SHIFT
	timescale = 1.3
	scale = options.fbreastScale*scale


func _process(delta):
	if !physActive:
		return
		
	basePos = origBasePos
	if female.isArmsUp:
		basePos += Vector2(0, -21)
	
	var upMove = clamp(0.07*(origPos.y - transform.origin.y), 0, 1)
	breastPoly.color.a =  1 - upMove


func removeTop():
	origBasePos -= TOP_SHIFT


func linParentVel():
	return female.vel


func getAngForce():
	return null


func getAngDamp():
	return 330


func getLength():
	return 25


func getLinForce():
	return Vector2(110,110)


func getLinDamp():
	if female.hasTop:
		return 15
	else:
		return 7

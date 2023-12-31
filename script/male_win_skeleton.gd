extends Skeleton2D
class_name MaleWinSkeleton

func get_class():
	return "MaleWinSkeleton"


const L = 0
const R = 1


var hip : Bone2D
var leg
var calf
var foot
var abdomen : Bone2D
var torso : Bone2D
var armL : Bone2D
var forearmL : Bone2D
var handL : Bone2D
var penis : Bone2D
var handR : Bone2D
var armR : Bone2D
var shoulderR : Bone2D

var thighLen
var calfLen
var legBaseLen
var shoulderLLen
var shoulderLBaseAng
var armLLen
var forearmLLen
var upperLLen
var armLBaseAng
var footBaseAng
var shoulderRHipOffset
var penisBasePos

var thighScale
var handPos
var footPos


func _init():
	pass


func _ready():
	hip = get_node("Hip")
	leg = [hip.get_node("LegL"), hip.get_node("LegR")]
	calf = [leg[L].get_node("CalfL"), leg[R].get_node("CalfR")]
	foot = [calf[L].get_node("FootL"), calf[R].get_node("FootR")]
	abdomen = hip.get_node("Abdomen")
	torso = abdomen.get_node("Torso")
	armL = torso.get_node("ArmL")
	forearmL = armL.get_node("ForearmL")
	handL = forearmL.get_node("HandL")
	handR = hip.get_node("HandR")
	armR = handR.get_node("ArmR")
	shoulderR = torso.get_node("ShoulderR")
	penis = hip.get_node("Penis")
	
	thighLen = [0, 0]
	calfLen = [0, 0]
	legBaseLen = [0, 0]
	footBaseAng = [0, 0]
	for i in [L,R]:
		thighLen[i] = calf[i].transform.origin.length()
		calfLen[i] = foot[i].transform.origin.length()
		legBaseLen[i] = (calf[i].transform.origin + foot[i].transform.origin).length()
		footBaseAng[i] = foot[i].get_rotation() + calf[i].get_rotation() + leg[i].get_rotation() + MPushBack.HIPROT
	
	var armLOffset = forearmL.transform.origin + handL.transform.origin.rotated(forearmL.get_rotation())
	armLLen = armLOffset.length()
	forearmLLen = handL.position.length()
	upperLLen = forearmL.position.length()
	armLBaseAng = atan2(armLOffset.y, armLOffset.x)
	var shoulderLOffset = torso.transform.origin + armL.transform.origin
	shoulderLLen = shoulderLOffset.length()
	shoulderLBaseAng = atan2(shoulderLOffset.y, shoulderLOffset.x)
	penisBasePos = penis.position
	
	shoulderRHipOffset = shoulderR.get_global_position() - hip.get_global_position()
	
	thighScale = [1, 1]
	handPos = [Vector2.ZERO, Vector2.ZERO]
	footPos = [Vector2.ZERO, Vector2.ZERO]
	placeHandR(hip.transform.origin, Vector2.ZERO, 0.0)


func placeLegs(footGlobalPos, tscale, cscale):
	var hipAng = hip.get_rotation()
	for i in [L,R]:
		footPos[i] = footGlobalPos[i]
		thighScale[i] = tscale[i]
		var calfScale = cscale[i]
		var hipPos = hip.transform.origin + leg[i].transform.origin.rotated(hipAng)
		var angs = HumanSkeleton.compute_angles(footGlobalPos[i] - hipPos, thighLen[i]*thighScale[i], calfLen[i]*calfScale, false)
		var legAng = angs[0] - hipAng
		var calfAng = angs[1] - angs[0]
		
		leg[i].set_rotation(legAng)
		#calf[i].set_rotation(calfAng)
		leg[i].set_scale(Vector2(thighScale[i], 1.0))
		
		var calfTrans = Math.scaledTrans(-calfAng, 1/thighScale[i])
		calfTrans = calfTrans.scaled(Vector2(calfScale, 1.0)).rotated(calfAng)
		calfTrans.origin = calf[i].transform.origin
		calf[i].transform = calfTrans
		
		var footAng = footBaseAng[i] - (legAng + calfAng + hipAng)
		var footTrans = Math.scaledTrans(-footAng, 1/calfScale)
		footTrans = footTrans.rotated(footAng)
		footTrans.origin = foot[i].transform.origin
		foot[i].transform = footTrans


func placeHandL(handGlobalPos, armScale):
	handPos[L] = handGlobalPos
	var abPos = hip.transform.origin + abdomen.transform.origin.rotated(hip.get_rotation())
	var angs = HumanSkeleton.compute_angles(handGlobalPos - abPos, shoulderLLen, armLLen*armScale, false)
	var abAng = angs[0] - hip.get_rotation() - shoulderLBaseAng
	var armAng = angs[1] - angs[0] - armLBaseAng + shoulderLBaseAng
	abdomen.set_rotation(abAng)
	armL.set_rotation(armAng)
	armL.set_scale(Vector2(armScale, 1.0))


func placeHandLBend(handGlobalPos, upperScale, foreScale, handAng):
	handPos[L] = handGlobalPos
	var hipAng = hip.get_rotation()
	var abAng = abdomen.get_rotation()
	var shoulderPos = getShoulderLPos()
	var angs = HumanSkeleton.compute_angles(handGlobalPos - shoulderPos, upperScale*upperLLen, foreScale*forearmLLen, true)
	var upperAng = angs[0] - hipAng - abAng
	var foreAng = angs[1] - angs[0]
	
	armL.set_scale(Vector2(upperScale, 1.0))
	armL.set_rotation(upperAng)
	
	var forearmTrans = Math.scaledTrans(-foreAng, 1/upperScale)
	forearmTrans = forearmTrans.scaled(Vector2(foreScale, 1.0)).rotated(foreAng)
	forearmTrans.origin = forearmL.transform.origin
	forearmL.transform = forearmTrans
	
	var handTrans = Math.scaledTrans(-handAng, 1/foreScale)
	handTrans = handTrans.scaled(Vector2(foreScale, 1.0)).rotated(handAng)
	handTrans.origin = handL.transform.origin
	handL.transform = handTrans


func placeHandR(handGlobalPos, shoulderShift, handAng):
	var hipAng = hip.get_rotation()
	handPos[R] = handGlobalPos
	handR.transform.origin = (handGlobalPos - hip.transform.origin).rotated(-hipAng)
	handR.set_rotation(handAng)
	
	var armVect = handGlobalPos - (hip.transform.origin + shoulderRHipOffset.rotated(hipAng) + shoulderShift)
	var armScale = 0.002*armVect.length()
	armR.set_scale(Vector2(armScale, 1.0))
	armR.set_rotation(armVect.angle() + PI - hipAng - handAng)
	

func getShoulderLPos():
	return hip.position + (abdomen.position + (torso.position + armL.position).rotated(abdomen.get_rotation())).rotated(hip.get_rotation())

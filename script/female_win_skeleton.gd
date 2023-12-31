extends Skeleton2D
class_name FemaleWinSkeleton

func get_class():
	return "FemaleWinSkeleton"


const L = 0
const R = 1


var hip : Bone2D
var leg
var calf
var foot
var torso : Bone2D
var chest : Bone2D
var head : Bone2D
var shoulderR : Bone2D
var arm
var forearm
var hand
var thumbL : Bone2D

var legLen
var calfLen
var armLen
var forearmLen
var handBasePosLen

var heightDiff
var footAngZero
var handAngleZero
var torsoBasePos
var chestBasePos
var shoulderRBasePos
var headBasePos

var breath
var handRot


func _init():
	pass


func _ready():
	hip = get_node("Hip")
	leg = [hip.get_node("LegL"), hip.get_node("LegR")]
	calf = [leg[L].get_node("CalfL"), leg[R].get_node("CalfR")]
	foot = [calf[L].get_node("FootL"), calf[R].get_node("FootR")]
	torso = hip.get_node("Torso")
	chest = torso.get_node("Chest")
	head = torso.get_node("Head")
	shoulderR = torso.get_node("ShoulderR")
	arm = [torso.get_node("ArmL"), shoulderR.get_node("ArmR")]
	forearm = [arm[L].get_node("ForearmL"), arm[R].get_node("ForearmR")]
	hand = [forearm[L].get_node("HandL"), forearm[R].get_node("HandR")]
	thumbL = hand[L].get_node("Thumb")
	
	torsoBasePos = torso.transform.origin + Vector2(10, -10)
	chestBasePos = chest.transform.origin
	shoulderRBasePos = shoulderR.transform.origin
	headBasePos = head.transform.origin
	handBasePosLen = [0, 0]
	for i in [L,R]:
		var handBasePos = hand[i].get_global_position() - arm[i].get_global_position()
		handBasePosLen[i] = handBasePos.length()
	
	legLen = [0, 0]
	calfLen = [0, 0]
	footAngZero = [0, 0]
	for i in [L,R]:
		legLen[i] = calf[i].transform.origin.length()
		calfLen[i] = foot[i].transform.origin.length()
		footAngZero[i] = leg[i].get_rotation() + calf[i].get_rotation()
	
	armLen = [0, 0]
	forearmLen = [0, 0]
	handAngleZero = [0, 0]
	for i in [L,R]:
		armLen[i] = forearm[i].transform.origin.length()
		forearmLen[i] = hand[i].transform.origin.length()
		handAngleZero[i] = arm[i].get_rotation() + forearm[i].get_rotation()
	
	breath = 0
	handRot = [0, 0]
	

func placeLegs(footGlobalPos):
	for i in [L,R]:
		var hipPos = hip.transform.origin + leg[i].transform.origin + heightDiff*Vector2.DOWN
		var angs = HumanSkeleton.compute_angles(footGlobalPos[i] - hipPos, legLen[i], calfLen[i], true)
		leg[i].set_rotation(angs[0])
		calf[i].set_rotation(angs[1] - angs[0])
		foot[i].set_rotation(footAngZero[i] - angs[1])


func placeArms(handGlobalPos):
	for i in [L,R]:
		var torsoAng = torso.get_rotation()
		var shoulderPos = hip.transform.origin + torso.transform.origin + \
				(arm[L] if i == L else shoulderR).transform.origin.rotated(torsoAng)
		var handShoulderVect = handGlobalPos[i] - shoulderPos
		
		var scale = getArmScale(i, handShoulderVect)
		var upperScale = scale[0]
		var foreScale = scale[1]
		
		var upperLen = armLen[i]*upperScale
		var foreLen = forearmLen[i]*foreScale
		var stretchScale = HumanSkeleton.getLimbStretch(upperLen + foreLen, handShoulderVect, 2.42)
		upperLen *= stretchScale
		foreLen *= stretchScale
		
		arm[i].set_scale(Vector2(upperScale, 1.0))
		
		var angs = HumanSkeleton.compute_angles(handShoulderVect, upperLen, foreLen, i == L)
		var upperAngle = angs[0] - torsoAng
		var forearmAngle = angs[1] - angs[0]
		arm[i].set_rotation(upperAngle)
		forearm[i].set_rotation(forearmAngle)
		
		var forearmTrans = Math.scaledTrans(-forearmAngle, 1/upperScale)
		forearmTrans = forearmTrans.scaled(Vector2(foreScale, 1.0)).rotated(forearmAngle)
		forearmTrans.origin = forearm[i].transform.origin
		forearm[i].transform = forearmTrans
		
		var handAng = handRot[i] - upperAngle - forearmAngle - torsoAng + handAngleZero[i]
		var handTrans = Math.scaledTrans(-handAng, 1/foreScale)
		handTrans = handTrans.rotated(handAng)
		handTrans.origin = hand[i].transform.origin
		hand[i].transform = handTrans


func setTorsoPos(torsoOffset):
	torso.position = torsoBasePos + torsoOffset
	head.position = headBasePos + 0.5*torsoOffset


func getTorsoPos():
	return torso.position - torsoBasePos


func setChestOffset(pos):
	chest.position = chestBasePos + pos


func setShoulderROffset(pos):
	shoulderR.position = shoulderRBasePos + pos


func breathe(delta):
	breath += delta/(2.0*Human.BREATH_TIME)
	setChestOffset(cos(2*PI*breath)*Vector2(-0.3, 1.4))


func getArmScale(index, armPos):
	var ratio = (armPos.length() - handBasePosLen[index])/handBasePosLen[index]
	if index == L:
		var upperScale = 1.0 + (0.5 if ratio > 1.0 else 0.70)*ratio
		var foreScale = 1.0 + (0.5 if ratio > 1.0 else 0.80)*ratio
		return [upperScale, foreScale]
	else:
		var scale = 1.0 + 0.85*ratio
		return [scale, scale]

extends Skeleton2D
class_name HumanSkeleton


const L = 0
const R = 1


var human
var hip : Bone2D
var thigh : Array
var calf : Array
var knee : Array
var foot : Array
var toe : Array
var chest : Bone2D
var abdomen : Bone2D
var torso : Bone2D
var neck : Bone2D
var head : Bone2D
var jaw : Bone2D
var arm : Array
var forearm : Array
var hand : Array
var clothF1 : Bone2D
var clothF2 : Bone2D
var clothF3 : Bone2D

var footBasePos0 : Array
var footBasePos : Array
var toeBasePos : Array
var torsoBasePos : Vector2
var chestBasePos : Vector2
var headBasePos : Vector2
var headAbOffset : Vector2
var chestAbOffset : Vector2
var legBaseLen : Array
var thighBaseAng : Array
var forwardSide
var backSide
var direction

var footAngleZero : Array
var thighLen : Array
var calfLen0 : Array
var calfLen : Array
var footLen : Array
var toeRotRatio : Array

var handAngleZero : Array
var armLen : Array
var forearmLen : Array
var handBasePos : Array
var handBasePosLen : Array
var shoulderBasePos : Array
var handHipOffset : Array

var abArmOffset : Array
var abArmOffsetLen : Array
var abArmOffsetAngle : Array
var hipArmOffset : Array
var hipArmOffsetLen : Array
var hipArmOffsetAngle : Array

var footPos : Array
var armAbsAngle : Array
var forearmAbsAngle : Array
var totalArmLen : Array
var handShoulderVect : Array
var rotShift : Vector2
var zeroAbsHandAngle : Array
var armDir : Array


func _init(directionIn):
	direction = directionIn
	armDir = [!direction, !direction]
	if direction:
		forwardSide = L
		backSide = R
	else:
		forwardSide = R
		backSide = L
	

func _ready():
	human = get_parent()
	
	hip = get_bone(0)
	thigh = [hip.get_node("ThighL"), hip.get_node("ThighR")]
	calf = [thigh[L].get_node("CalfL"), thigh[R].get_node("CalfR")]
	knee = [calf[L].get_node("KneeL"), calf[R].get_node("KneeR")]
	foot = [calf[L].get_node("FootL"), calf[R].get_node("FootR")]
	toe = [foot[L].get_node("ToeL"), foot[R].get_node("ToeR")]
	abdomen = hip.get_node("Abdomen")
	torso = abdomen.get_node("Torso")
	chest = torso.get_node("Chest")
	neck = torso.get_node("Neck")
	head = neck.get_node("Head")
	jaw = head.get_node("Jaw")
	arm = [torso.get_node("ArmL"), torso.get_node("ArmR")]
	forearm = [arm[L].get_node("ForearmL"), arm[R].get_node("ForearmR")]
	hand = [forearm[L].get_node("HandL"), forearm[R].get_node("HandR")]
	clothF1 = hip.get_node("ClothF1")
	clothF2 = clothF1.get_node("ClothF2")
	clothF3 = clothF2.get_node("ClothF3")
	
	torsoBasePos = torso.get_global_position() - hip.get_global_position()
	chestBasePos = chest.transform.get_origin()
	headBasePos = head.transform.origin
	headAbOffset = head.get_global_position() - abdomen.get_global_position()
	chestAbOffset = chest.get_global_position() - abdomen.get_global_position()
	
	thighLen = [calf[L].transform.origin.length(), calf[R].transform.origin.length()]
	calfLen0 = [foot[L].transform.origin.length(), foot[R].transform.origin.length()]
	calfLen = [calfLen0[L], calfLen0[R]]
	footLen = [toe[L].transform.origin.length(), toe[R].transform.origin.length()]
	footBasePos0 = [toe[L].get_global_position() - thigh[L].get_global_position(),
					toe[R].get_global_position() - thigh[R].get_global_position()]
	footBasePos = [footBasePos0[L], footBasePos0[R]]
	footPos = [footBasePos0[L], footBasePos0[R]]
	toeBasePos = [toe[L].transform.origin, toe[R].transform.origin]
	thighBaseAng = [thigh[L].transform.get_rotation(), thigh[R].transform.get_rotation()]
	footAngleZero = [0, 0]
	legBaseLen = [0, 0]
	for i in [L,R]:
		footAngleZero[i] = thigh[i].transform.get_rotation() + calf[i].transform.get_rotation() \
							+ foot[i].transform.get_rotation()
	
	armLen = [forearm[L].transform.origin.length(), forearm[R].transform.origin.length()]
	forearmLen = [hand[L].transform.origin.length(), hand[R].transform.origin.length()]
	handAngleZero = [-hand[L].transform.get_rotation(), -hand[R].transform.get_rotation()]
	handBasePos = [hand[L].get_global_position() - arm[L].get_global_position(),
					hand[R].get_global_position() - arm[R].get_global_position()]
	handBasePosLen = [handBasePos[L].length(), handBasePos[R].length()]
	shoulderBasePos = [arm[L].transform.origin, arm[R].transform.origin]
	
	updateArmPos()
	updateLegPos()
	
	handHipOffset = [hipArmOffset[L] + handBasePos[L],
					hipArmOffset[R] + handBasePos[R]]
	
	armAbsAngle = [0, 0]
	forearmAbsAngle = [0, 0]
	totalArmLen = [100, 100]
	handShoulderVect = [Vector2.DOWN, Vector2.DOWN]
	rotShift = Vector2.ZERO
	zeroAbsHandAngle = [0, 0]


func _process(delta):
	pass


func setChestOffset(pos):
	chest.transform.origin = chestBasePos + pos


func setLegsClosed(frac):
	pass


func updateArmPos():
	abArmOffset = [arm[L].transform.origin + torso.transform.origin,
					arm[R].transform.origin + torso.transform.origin]
	abArmOffsetLen = [abArmOffset[L].length(), abArmOffset[R].length()]
	abArmOffsetAngle = [atan2(abArmOffset[L].y, abArmOffset[L].x), \
						atan2(abArmOffset[R].y, abArmOffset[R].x)]
	
	hipArmOffset = [abArmOffset[L] + abdomen.transform.origin,
					abArmOffset[R] + abdomen.transform.origin]
	hipArmOffsetLen = [hipArmOffset[L].length(), hipArmOffset[R].length()]
	hipArmOffsetAngle = [atan2(hipArmOffset[L].y, hipArmOffset[L].x), \
						atan2(hipArmOffset[R].y, hipArmOffset[R].x)]


func updateLegPos():
	for i in [L,R]:
		var heelBasePos = Vector2(footBasePos[i].x - footLen[i]*cos(footAngleZero[i]),
							footBasePos[i].y - footLen[i]*sin(footAngleZero[i]))
		legBaseLen[i] = heelBasePos.length()


func place_legs(footGlobalPos, footDeltaAngle, legScale):
	for i in [L,R]:
		footPos[i] = footBasePos[i] + footGlobalPos[i] - hip.position
		
		var heelPos = getHeelPos(i, footDeltaAngle[i])
		
		var scale = legScale[i]
		if scale == null:
			scale = getLegScale(i, heelPos)
		var thighScale = scale[0]
		var calfScale = scale[1]
		
		var tLen = thighLen[i]*thighScale
		var cLen = calfLen[i]*calfScale
		var stretchScale = getLimbStretch(tLen + cLen, heelPos, 2.4)
		thighScale *= stretchScale
		calfScale *= stretchScale
		tLen *= stretchScale
		cLen *= stretchScale
		
		var footScale = getFootScale(i, footDeltaAngle[i])
		
		var angles = compute_angles(heelPos, tLen, cLen, direction)
		var thighAngle = angles[0] - hip.get_rotation()
		var calfAngle = angles[1] - thighAngle
		var footAngle = -(thighAngle + calfAngle) + footDeltaAngle[i] + footAngleZero[i]
		var toeAngle = -footDeltaAngle[i]*(1 - clamp(-0.02*footGlobalPos[i].y, 0, 1))
		
		thigh[i].set_rotation(thighAngle)
		thigh[i].set_scale(Vector2(thighScale, 1.0))
		
		var calfTrans = Math.scaledTrans(-calfAngle, 1/thighScale)
		calfTrans = calfTrans.scaled(Vector2(calfScale, 1.0)).rotated(calfAngle)
		calfTrans.origin = calf[i].transform.origin
		calf[i].transform = calfTrans
		
		knee[i].set_rotation(((-PI if direction else PI) - calfAngle)/2)
		
		var footTrans = Math.scaledTrans(-footAngle, 1/calfScale)
		footTrans = footTrans.scaled(Vector2(footScale, 1.0)).rotated(footAngle)
		footTrans.origin = foot[i].transform.origin
		foot[i].transform = footTrans
		
		var toeTrans = Math.scaledTrans(-toeAngle, 1/footScale)
		toeTrans = toeTrans.rotated(toeAngle)
		toeTrans.origin = toe[i].transform.origin
		toe[i].transform = toeTrans


func place_arms(handGlobalPos, handAngles, useGlobalAngles, armScale):
	for i in [L,R]:
		var abAng = abdomen.get_rotation()
		var hipAng = hip.get_rotation()
		var abShiftAng = abAng + abArmOffsetAngle[i]
		var abShift = (abArmOffsetLen[i]*Vector2(cos(abShiftAng), sin(abShiftAng)) - abArmOffset[i]).rotated(hipAng)
		var hipShiftAng = hipAng + hipArmOffsetAngle[i]
		var hipShift = hipArmOffsetLen[i]*Vector2(cos(hipShiftAng), sin(hipShiftAng)) - hipArmOffset[i]
		rotShift = abShift + hipShift
		
		handShoulderVect[i] = handBasePos[i] + (handGlobalPos[i] - hip.position) - rotShift
		handShoulderVect[i] -= arm[i].transform.origin - shoulderBasePos[i]
		
		var scale = armScale[i]
		if scale == null:
			scale = getArmScale(i, handShoulderVect[i])
		var upperScale = scale[0]
		var foreScale = scale[1]
		
		var upperLen = armLen[i]*upperScale
		var foreLen = forearmLen[i]*foreScale
		var stretchScale = getLimbStretch(upperLen + foreLen, handShoulderVect[i], 2.4)
		upperScale *= stretchScale
		foreScale *= stretchScale
		upperLen *= stretchScale
		foreLen *= stretchScale
		totalArmLen[i] = upperLen + foreLen
		
		var angles = compute_angles(handShoulderVect[i], upperLen, foreLen, armDir[i])
		armAbsAngle[i] = angles[0]
		forearmAbsAngle[i] = angles[1]
		
		var upperAngle = armAbsAngle[i] - abAng - hipAng
		var forearmAngle = forearmAbsAngle[i] - armAbsAngle[i]
		var handAngle = handAngles[i] - handAngleZero[i]
		
		zeroAbsHandAngle[i] = upperAngle + forearmAngle + abAng + hipAng
		if useGlobalAngles:
			handAngle -= zeroAbsHandAngle[i]
		
		arm[i].set_rotation(upperAngle)
		forearm[i].set_rotation(forearmAngle)
		hand[i].set_rotation(handAngle)
		
		arm[i].set_scale(Vector2(upperScale, 1.0))
		
		var forearmTrans = Math.scaledTrans(-forearmAngle, 1/upperScale)
		forearmTrans = forearmTrans.scaled(Vector2(foreScale, 1.0)).rotated(forearmAngle)
		forearmTrans.origin = forearm[i].transform.origin
		forearm[i].transform = forearmTrans
		
		var handTrans = Math.scaledTrans(-handAngle, 1/foreScale)
		handTrans = handTrans.rotated(handAngle)
		handTrans.origin = hand[i].transform.origin
		hand[i].transform = handTrans


func getHeelPos(side, footDeltaAngle):
	var footScale = getFootScale(side, footDeltaAngle)
	var scaledFootLen = footScale*footLen[side]
	var netFootAngle = footDeltaAngle + footAngleZero[side]
	return Vector2(footPos[side].x - scaledFootLen*cos(netFootAngle),
				footPos[side].y - scaledFootLen*sin(netFootAngle))


func getHeadPos():
	return abdomen.position + headAbOffset.rotated(abdomen.get_rotation())

func getChestPos():
	return abdomen.position + chestAbOffset.rotated(abdomen.get_rotation())


static func compute_angles(pos, a, b, upper):
	var R = sqrt(pos.x*pos.x + pos.y*pos.y)
	var omega = atan2(pos.y, pos.x)
	var alpha = 0
	var beta = 0
	if R < 0.999*(a + b):
		alpha = acos((R*R + a*a - b*b)/(2*R*a))
		beta = asin(sin(alpha)*a/b)
	if upper:
		return [omega - alpha, omega + beta]
	else:
		return [omega + alpha, omega - beta]


const STRETCH_RANGE = 0.014
static func getLimbStretch(limbLen, reachVect, stretchExtent):
	var ratio = reachVect.length()/limbLen
	var stretchAmt = clamp(((ratio - 1) + STRETCH_RANGE)/(2*STRETCH_RANGE), 0, 1)
	return 1 + stretchExtent*STRETCH_RANGE*stretchAmt


func getArmScale(index, pos):
	return [1.0, 1.0]

func getLegScale(index, heelPos):
	return [1.0, 1.0]

func getFootScale(index, footAngle):
	return 1.0

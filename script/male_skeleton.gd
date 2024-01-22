extends HumanSkeleton
class_name MaleSkeleton

func get_class():
	return "MaleSkeleton"


const HEAD_SCALE = 0.938*Vector2(1.0, 1.0)


var groin : Bone2D
var footLRun : Bone2D
var toeLRun : Bone2D
var bicepL : Bone2D
var bicepR : Bone2D
var shoulderR : Bone2D
var legsClosedFrac
var runningFrac
var handLGroinOffset : Vector2
var layThighRScale
var footLRunAngOffset

var layThigh
var layCalf
var layPen0
var layPen1
var layPen2
var baseLayThighAng
var baseLayCalfAng
var baseLayPen0Ang
var baseLayPen1Ang
var baseLayPen2Ang
var baseLayPen1Pos
var baseLayPen2Pos

var backThigh
var backCalf
var backFoot
var backFootBasePos
var backCalfLen
var backThighLen
var backFootAngleZero
var backArmL
var backForearmL
var backHandL


func _init().(false):
	toeRotRatio = [0.0, 0.0]
	legsClosedFrac = 0


func _ready():
	head.scale = HEAD_SCALE
	
	groin = hip.get_node("Groin")
	
	var options = get_node("/root/Options")
	var groinMove = 1 - max(0, options.msoftScale*options.mpenWidth)
	groin.position += groinMove*Vector2(10.0, 20.0)
	
	footLRun = calf[L].get_node("FootL_run")
	toeLRun = footLRun.get_node("ToeL_run")
	bicepL = arm[L].get_node("BicepL")
	bicepR = arm[R].get_node("BicepR")
	shoulderR = arm[R].get_node("ShoulderR")
	handLGroinOffset = Vector2(-10, 10) \
			- (torsoBasePos + shoulderBasePos[L] + handBasePos[L])
	footLRunAngOffset = footLRun.get_rotation() - foot[L].get_rotation()
	
	layThigh = [hip.get_node("ThighL_lay"), hip.get_node("ThighR_lay")]
	layCalf = [layThigh[L].get_node("CalfL_lay"), layThigh[R].get_node("CalfR_lay")]
	layPen0 = hip.get_node("Penis0_lay")
	layPen1 = hip.get_node("Penis1_lay")
	layPen2 = layPen1.get_node("Penis2_lay")
	baseLayThighAng = [layThigh[L].get_rotation(), layThigh[R].get_rotation()]
	baseLayCalfAng = [layCalf[L].get_rotation(), layCalf[R].get_rotation()]
	baseLayPen0Ang = layPen0.get_rotation()
	baseLayPen1Ang = layPen1.get_rotation()
	baseLayPen2Ang = layPen2.get_rotation()
	baseLayPen1Pos = layPen1.position
	baseLayPen2Pos = layPen2.position
	
	backArmL = torso.get_node("ArmL_back")
	backForearmL = backArmL.get_node("ForearmL_back")
	backHandL = backForearmL.get_node("HandL_back")
	backThigh = [hip.get_node("ThighL_back"), hip.get_node("ThighR_back")]
	backCalf = [backThigh[L].get_node("CalfL_back"), backThigh[R].get_node("CalfR_back")]
	backFoot = [backCalf[L].get_node("FootL_back"), backCalf[R].get_node("FootR_back")]
	backFootBasePos = [0, 0]
	backFootAngleZero = [0, 0]
	for i in [L,R]:
		backFootBasePos[i] = footBasePos[i] - backThigh[i].position + thigh[i].position
		backFootAngleZero[i] = backThigh[i].transform.get_rotation() + backCalf[i].transform.get_rotation()
	backThighLen = [backCalf[L].position.length(), backCalf[R].position.length()]
	backCalfLen = [backFoot[L].position.length(), backFoot[R].position.length()]
	
	layThighRScale = 1.0
	setLayLegMove(0, 0)


func setRunningFrac(frac, strideCycle):
	runningFrac = frac
	if frac > 0:
		footBasePos[L].x = footBasePos0[L].x - frac*210
		footBasePos[R] = footBasePos0[R] + frac*Vector2(200, 20)
		updateLegPos()


func setLegsClosed(frac):
	legsClosedFrac = frac
	footBasePos[L].x = footBasePos0[L].x - 130*frac
	footBasePos[R].x = footBasePos0[R].x + 130*frac


func getLegScale(index, heelPos):
	if index == L:
		var legLen = heelPos.length()
		var ratio = min(1.1, legLen/legBaseLen[L]) + 0.07*legsClosedFrac - 0.02*runningFrac
		if ratio < 1:
			ratio = 0.3 + 0.7*ratio
		return [-0.3 + 1.3*ratio, 0.3 + 0.7*ratio]
	else:
		var legLen = heelPos.length()
		var ratio = (legLen/legBaseLen[R] + 0.3)/1.3
		ratio = clamp(0.1 + 1.5*ratio, 0.6, 1.0)
		var closeFact = legsClosedFrac/(1 + 0.002*abs(footBasePos[L].x - footPos[L].x))
		var thighScale = 1 - 0.05*closeFact
		var calfScale = 1 - 0.15*closeFact
		var hipRot = hip.get_rotation()
		var rotFactor = 1 - (0.6*hipRot - 1.0*hipRot*hipRot)
		return [ratio*thighScale*rotFactor, (0.6 + 0.4*ratio)*calfScale]


func getFootScale(index, angle):
	if index == L:
		return 1.0 + max(0, -0.9*angle)
	else:
		return 1.0


func getArmScale(index, armPos):
	var stretch = (armPos.length() - handBasePosLen[index])/handBasePosLen[index]
	if index == L:
		var scale = 1.0 + 0.2*stretch
		return [scale, scale]
	else:
		var upperStretch = stretch
		var foreStretch = stretch
		if stretch < 0:
			foreStretch = -(1 - 1/pow(-stretch + 1, 16))/16 + 1.0*stretch*stretch
			upperStretch = -(1 - 1/pow(-stretch + 1, 2))/2
		var upperScale = 1.0 + 0.50*upperStretch
		var foreScale = 1.0 + 1.05*foreStretch
		return [upperScale, foreScale]


func placeBiceps():
	var stretchL = 1 - forearm[L].get_rotation_degrees()/82
	bicepL.position = Vector2(50*stretchL, -9*stretchL)
	var stretchR = 1 - forearm[R].get_rotation_degrees()/38
	bicepR.position = Vector2(15*stretchR, -12*max(0, stretchR))
	var liftR = max(0, 1 - (180 - arm[R].get_rotation_degrees())/70)
	shoulderR.position = Vector2(-50*liftR, 0*liftR)
	


func placeBackLegs(footGlobalPos):
	for i in [L,R]:
		footPos[i] = backFootBasePos[i] + footGlobalPos[i] - hip.position
		
		var heelPos = getHeelPos(i, 0)
		
		var angles = compute_angles(heelPos, backThighLen[i], backCalfLen[i], direction)
		var thighAngle = angles[0]
		var calfAngle = angles[1] - thighAngle
		var footAngle = min(0.6, -(thighAngle + calfAngle) + backFootAngleZero[i])
		
		backThigh[i].set_rotation(thighAngle)
		backCalf[i].set_rotation(calfAngle)
		backFoot[i].set_rotation(footAngle)


func setLayLegMove(amtL, amtR):
	amtL = 0.13*amtL
	layThigh[L].set_rotation(baseLayThighAng[L] + (amtL if amtL < 0 else 0.8*amtL))
	layCalf[L].set_rotation(baseLayCalfAng[L] - 1.2*amtL)
	var thighLScale = 1 - 0.6*max(0, amtL)
	layThigh[L].set_scale(Vector2(thighLScale, 1.0))
	var trans = Math.scaledTrans(-layCalf[L].get_rotation(), 1/thighLScale)
	trans = trans.rotated(layCalf[L].get_rotation())
	trans.origin = layCalf[L].transform.origin
	layCalf[L].transform = trans
	
	amtR = -0.2 + 0.4*amtR
	var thighRAng = baseLayThighAng[R] + amtR
	var calfRAng = baseLayCalfAng[R] - amtR
	layThigh[R].set_rotation(thighRAng)
	layThigh[R].set_scale(Vector2(layThighRScale, 1.0))
	var calfTrans = Math.scaledTrans(-calfRAng, 1/layThighRScale)
	calfTrans = calfTrans.rotated(calfRAng)
	calfTrans.origin = layCalf[R].transform.origin
	layCalf[R].transform = calfTrans


func placeBackArms():
	backArmL.set_rotation(arm[L].get_rotation())
	backArmL.set_scale(arm[L].get_scale())
	backForearmL.set_rotation(forearm[L].get_rotation())
	backForearmL.set_scale(forearm[L].get_scale())
	backHandL.set_rotation(hand[L].get_rotation())
	backHandL.set_scale(hand[L].get_scale())


func setLayPenPos(ang1, ang2, offset2, scale1, scale2):
	scale1 *= human.options.msoftScale
	scale1.y *= human.options.mpenWidth
	
	layPen1.set_rotation(baseLayPen1Ang + ang1)
	layPen1.set_scale(scale1)
	var relOffset = offset2.rotated(-(hip.get_rotation() + layPen1.get_rotation()))
	layPen2.transform.origin = baseLayPen2Pos + Vector2(relOffset.x/scale1.x, relOffset.y/scale1.y)
	
	var trans = Math.scaledTrans(-(baseLayPen2Ang + ang2) + PI/2, 1/scale1.y)
	trans = Math.compose(trans, Math.scaledTrans(-(baseLayPen2Ang + ang2), 1/scale1.x))
	trans = trans.scaled(scale2).rotated(baseLayPen2Ang + ang2)
	trans.origin = layPen2.transform.origin
	layPen2.transform = trans

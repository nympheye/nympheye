extends HumanSkeleton
class_name FemaleSkeleton

func get_class():
	return "FemaleSkeleton"


var legsClosedFrac
var runningFrac
var handLGroinOffset : Vector2
var heightDiff
var thumbLStartAng
var female

var breast : Array
var thumbL : Bone2D
var hairB1
var hairB2
var hairB3

var thighLKneel : Bone2D
var thighRKneel : Bone2D
var calfRKneel : Bone2D
var thighLKneelStartAng
var thighRKneelStartAng
var calfRKneelStartAng

var armUp : Array
var forearmUp : Array

var thighLLay1 : Bone2D
var calfLLay1 : Bone2D
var thighRLay1 : Bone2D
var calfRLay1 : Bone2D
var armLay1 : Array
var forearmLay1 : Array
var handLay1 : Array
var hairLay : Bone2D
var skinLay1: Array
var breastsLay1 : Bone2D
var chestLay1 : Bone2D

var thighLLay1s : Bone2D
var calfLLay1s : Bone2D
var thighRLay1s : Bone2D
var calfRLay1s : Bone2D
var footRLay1s : Bone2D

var thighROpen : Bone2D
var calfROpen : Bone2D
var footROpen : Bone2D

var vagSide : Bone2D
var vagTop : Bone2D

var thighLLay1StartAng
var calfLLay1StartAng
var thighRLay1StartAng
var calfRLay1StartAng
var hairLayStartPos
var thighLLay1sStartAng
var calfLLay1sStartAng
var chestLayStartPos

var layArmLen
var layForearmLen
var thighROpenLen
var calfROpenLen
var footROpenBasePos

var layUpperScale
var layForearmScale


func _init().(true):
	legsClosedFrac = 0
	runningFrac = 0
	toeRotRatio = [0.0, 0.0]


func _ready():
	female = get_parent()
	handLGroinOffset = Vector2(30, 18) \
			- (torsoBasePos + shoulderBasePos[L] + handBasePos[L])
	breast = [chest.get_node("BreastL"), chest.get_node("BreastR")]
	thumbL = hand[L].get_node("ThumbL")
	thumbLStartAng = thumbL.get_rotation()
	hairB1 = head.get_node("HairB1")
	hairB2 = hairB1.get_node("HairB2")
	hairB3 = hairB2.get_node("HairB3")
	
	armUp = [hip.get_node("Abdomen/Torso/ArmL_up"), hip.get_node("Abdomen/Torso/ArmR_up")]
	forearmUp = [armUp[L].get_node("ForearmL_up"), armUp[R].get_node("ForearmR_up")]
	
	thighLLay1 = hip.get_node("ThighL_lay1")
	calfLLay1 = thighLLay1.get_node("CalfL_lay1")
	thighRLay1 = hip.get_node("ThighR_lay1")
	calfRLay1 = thighRLay1.get_node("CalfR_lay1")
	armLay1 = [hip.get_node("Abdomen/Torso/ArmL_lay1"), hip.get_node("Abdomen/Torso/ArmR_lay1")]
	forearmLay1 = [armLay1[L].get_node("ForearmL_lay1"), armLay1[R].get_node("ForearmR_lay1")]
	handLay1 = [forearmLay1[L].get_node("HandL_lay1"), forearmLay1[R].get_node("HandR_lay1")]
	hairLay = head.get_node("Hair_lay")
	skinLay1 = [thighLLay1.get_node("SkinL"), thighRLay1.get_node("SkinR")]
	chestLay1 = torso.get_node("Chest_lay1")
	breastsLay1 = chestLay1.get_node("Breasts_lay1")
	thighLLay1s = hip.get_node("ThighL_lay1s")
	calfLLay1s = thighLLay1s.get_node("CalfL_lay1s")
	thighRLay1s = hip.get_node("ThighR_lay1s")
	calfRLay1s = thighRLay1s.get_node("CalfR_lay1s")
	footRLay1s = calfRLay1s.get_node("FootR_lay1s")
	
	thighROpen = hip.get_node("ThighR_open")
	calfROpen = thighROpen.get_node("CalfR_open")
	footROpen = calfROpen.get_node("FootR_open")
	thighROpenLen = calfROpen.position.length()
	calfROpenLen = footROpen.position.length()
	footROpenBasePos = footBasePos[R] + thighROpen.position - thigh[R].position + Vector2(0, -30)
	#footBasePos[R] + footGlobalPos - hip.position + openRHipOffset + Vector2(0, -30)
	
	vagTop = hip.get_node("Vag_top")
	vagSide = hip.get_node("Vag_side")
	
	thighLKneel = hip.get_node("ThighL_kneel")
	thighRKneel = hip.get_node("ThighR_kneel")
	calfRKneel = thighRKneel.get_node("CalfR_kneel")
	
	thighLLay1StartAng = thighLLay1.get_rotation()
	calfLLay1StartAng = calfLLay1.get_rotation()
	thighRLay1StartAng = thighRLay1.get_rotation()
	calfRLay1StartAng = calfRLay1.get_rotation()
	#armLay1StartAng = [armLay1[L].get_rotation(), armLay1[R].get_rotation()]
	#forearmLay1StartAng = [forearmLay1[L].get_rotation(), forearmLay1[R].get_rotation()]
	hairLayStartPos = hairLay.transform.origin
	thighLLay1sStartAng = thighLLay1s.get_rotation()
	calfLLay1sStartAng = calfLLay1s.get_rotation()
	chestLayStartPos = chestLay1.transform.origin
	thighLKneelStartAng = thighLKneel.get_rotation()
	thighRKneelStartAng = thighRKneel.get_rotation()
	calfRKneelStartAng = calfRKneel.get_rotation()
	
	layArmLen = [0, 0]
	layForearmLen = [0, 0]
	for i in [L,R]:
		layArmLen[i] = forearmLay1[i].transform.origin.length()
		layForearmLen[i] = handLay1[i].transform.origin.length()
	
	layUpperScale = [1.0, 1.0]
	layForearmScale = [1.0, 1.0]


func setRunningFrac(frac, strideCycle):
	if frac > 0:
		runningFrac = frac
		footBasePos[L].x = footBasePos0[L].x - runningFrac*250
		footBasePos[R].x = footBasePos0[R].x + runningFrac*140
		updateLegPos()


func setLegsClosed(frac):
	legsClosedFrac = frac
	footBasePos[L].x = footBasePos0[L].x - 240*frac
	footBasePos[R].x = footBasePos0[R].x + 130*frac
	updateLegPos()
	

func getArmScale(index, armPos):
	var stretch = (armPos.length() - handBasePosLen[index])/handBasePosLen[index]
	if index == L:
		if female.grabbingPart == Female.GRAB_BREAST && armDir[L]:
			return [0.95, 0.60]
		var scale
		if stretch < 0:
			scale = max(0.75, 1 + 1.0*stretch)
		else:
			scale = 1 + 0.3*stretch
		if armDir[L]:
			return [1.05*scale, 0.9*scale]
		else:
			return [scale, scale]
	else:
		var upperStretch = stretch
		var foreStretch = stretch
		if stretch < 0:
			upperStretch = -(1 - 1/pow(-upperStretch + 1, 32))/32
			foreStretch = -(1 - 1/pow(-foreStretch + 1, 16))/16
		var upperScale = 1.02 + 0.63*upperStretch
		var foreScale = 1.0 + 0.65*foreStretch
		return [upperScale, foreScale]


func getLegScale(index, heelPos):
	var legLen = heelPos.length()
	var diff = legLen/legBaseLen[R] - 1
	var downness = max(hip.position.y/female.downHeight, 0)
	if index == L:
		var ratio = legsClosedFrac/(1 + 0.002*abs(footBasePos[L].x - footPos[L].x))
		var thighScale = 1 - 0.17*ratio - 0.12*max(0, downness - 1.3)
		var calfScale = 1 - 0.32*ratio - 0.14*max(0, downness - 1.3)
		return [thighScale, calfScale]
	else:
		var thighScale = 1.0 + (1-runningFrac)*diff*(0.85 if diff > 0 else 0.15) - 0.06*min(downness, 1.1)
		var calfScale = 1.0 - 0.25*min(downness, 1.1)# + 0.07*runningFrac
		return [thighScale, calfScale]


func setLayLegsOpen(openAmtL, openAmtR):
	var thighAng = [-0.03*openAmtL, 0.1*openAmtR]
	var calfAng = [0.04*openAmtL, -0.1*openAmtR]
	var thighScale = [1.0, 1.0]
	var calfScale = [1.0, 1.0]
	if openAmtR < 0:
		thighScale[R] = 1.0 + 0.015*openAmtR
		calfScale[R] = 1.0 + 0.025*openAmtR
	setLayLegConfig(thighAng, calfAng, thighScale, calfScale)


func setKneelLegConfig(thighLAng, thighLScale, thighRAng, calfRAng, thighRScale, calfRScale):
	thighLAng += thighLKneelStartAng
	thighRAng += thighRKneelStartAng
	calfRAng += calfRKneelStartAng
	
	thighLKneel.set_scale(Vector2(thighLScale, 1.0))
	thighLKneel.set_rotation(thighLAng)
	thighRKneel.set_rotation(thighRAng)
	
	thighRKneel.set_scale(Vector2(thighRScale, 1.0))
	var calfTrans = Math.scaledTrans(-calfRAng, 1/thighRScale)
	calfTrans = calfTrans.scaled(Vector2(calfRScale, 1.0)).rotated(calfRAng)
	calfTrans.origin = calfRKneel.transform.origin
	calfRKneel.transform = calfTrans


func setLayLegConfig(thighAng, calfAng, thighScale, calfScale):
	thighAng[L] += thighLLay1StartAng
	calfAng[L] += calfLLay1StartAng
	thighAng[R] += thighRLay1StartAng
	calfAng[R] += calfRLay1StartAng
	thighLLay1.set_rotation(thighAng[L])
	thighRLay1.set_rotation(thighAng[R])
	
	thighLLay1.set_scale(Vector2(thighScale[L], 1.0))
	var calfLTrans = Math.scaledTrans(-calfAng[L], 1/thighScale[L])
	calfLTrans = calfLTrans.scaled(Vector2(calfScale[L], 1.0)).rotated(calfAng[L])
	calfLTrans.origin = calfLLay1.transform.origin
	calfLLay1.transform = calfLTrans
	
	thighRLay1.set_scale(Vector2(thighScale[R], 1.0))
	var calfRTrans = Math.scaledTrans(-calfAng[R], 1/thighScale[R])
	calfRTrans = calfRTrans.scaled(Vector2(calfScale[R], 1.0)).rotated(calfAng[R])
	calfRTrans.origin = calfRLay1.transform.origin
	calfRLay1.transform = calfRTrans


func setLegLSConfig(thighAng, calfAng, thighScale):
	var calfScale = 1.0
	thighAng += thighLLay1StartAng
	calfAng += calfLLay1StartAng
	thighLLay1s.set_rotation(thighAng)
	calfLLay1s.set_rotation(calfAng)
	thighLLay1s.set_scale(Vector2(thighScale, 1.0))
	var calfLsTrans = Math.scaledTrans(-calfAng, 1/thighScale)
	calfLsTrans = calfLsTrans.scaled(Vector2(calfScale, 1.0)).rotated(calfAng)
	calfLsTrans.origin = calfLLay1s.transform.origin
	calfLLay1s.transform = calfLsTrans


func setLaySkinMove(moveAmtL, moveAmtR):
	skinLay1[L].transform.origin = Vector2(0, -3*moveAmtL)
	skinLay1[R].transform.origin = Vector2(0, 3*moveAmtR)


func placeLayArms(handGlobalPos):
	for i in [L,R]:
		var upperScale = layUpperScale[i]
		var foreScale = layForearmScale[i]
		var hipAng = hip.get_rotation()
		var abAng = abdomen.get_rotation()
		var shoulderPos = heightDiff*Vector2.DOWN + hip.position + abdomen.position.rotated(hipAng) + \
				torso.position.rotated(hipAng + abAng) + armLay1[i].position.rotated(hipAng + abAng)
		var angs = HumanSkeleton.compute_angles(handGlobalPos[i] - shoulderPos, layArmLen[i]*upperScale, layForearmLen[i]*foreScale, i == L)
		var upperAngle = angs[0] - hipAng - abAng
		var forearmAngle = angs[1] - angs[0]
		armLay1[i].set_rotation(upperAngle)
		forearmLay1[i].set_rotation(forearmAngle)
		
		var scale = getLayArmScale(i, handGlobalPos[i] - shoulderPos)
		
		armLay1[i].set_scale(Vector2(upperScale, 1.0))
		
		var forearmTrans = Math.scaledTrans(-forearmAngle, 1/upperScale)
		forearmTrans = forearmTrans.scaled(Vector2(foreScale, 1.0)).rotated(forearmAngle)
		forearmTrans.origin = forearmLay1[i].transform.origin
		forearmLay1[i].transform = forearmTrans


func getLayArmScale(side, pos):
	return [1.0, 1.0]


func placeUpArms(handGlobalPos):
	for i in [L,R]:
		var abAng = abdomen.get_rotation()
		var abShiftAng = abAng + abArmOffsetAngle[i]
		var abShift = abArmOffsetLen[i]*Vector2(cos(abShiftAng), sin(abShiftAng)) - abArmOffset[i]
		
		var handPos = handBasePos[i] + handGlobalPos[i] - hip.position - abShift
		handPos -= armUp[i].transform.origin - shoulderBasePos[i]
		
		var angles = compute_angles(handPos, armLen[i], forearmLen[i], armDir[i])
		armAbsAngle[i] = angles[0]
		forearmAbsAngle[i] = angles[1]
		
		var upperAngle = armAbsAngle[i] - abAng
		var forearmAngle = forearmAbsAngle[i] - armAbsAngle[i]
		
		armUp[i].set_rotation(upperAngle)
		forearmUp[i].set_rotation(forearmAngle)


func placeLegROpen(footGlobalPos, thighScale, calfScale, footScale):
	var heelPos = footROpenBasePos + footGlobalPos - hip.position
	var angles = compute_angles(heelPos, thighScale*thighROpenLen, calfScale*calfROpenLen, false)
	var thighAngle = angles[0]
	var calfAngle = angles[1] - thighAngle
	var footAngle = 0
	
	thighROpen.set_rotation(thighAngle)
	thighROpen.set_scale(Vector2(thighScale, 1.0))
	
	var calfTrans = Math.scaledTrans(-calfAngle, 1/thighScale)
	calfTrans = calfTrans.scaled(Vector2(calfScale, 1.0)).rotated(calfAngle)
	calfTrans.origin = calfROpen.transform.origin
	calfROpen.transform = calfTrans
	
	var footTrans = Math.scaledTrans(-footAngle, 1/calfScale)
	footTrans = footTrans.scaled(Vector2(footScale, 1.0)).rotated(footAngle)
	footTrans.origin = footROpen.transform.origin
	footROpen.transform = footTrans


func setHeadRot(angleZ, angleX):
	var ang = angleZ + 0.40*angleX
	var t = Transform2D()
	t = t.rotated(ang)
	t.x.y += 0.4*angleX # face right
	#t.y.x -= 0.3*angleX # top up
	t.origin = headBasePos + angleX*Vector2(5, 15)
	head.transform = t

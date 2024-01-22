extends Action
class_name MFallBack

func get_class():
	return "MFallBack"


const FALL_TIME = 2.0
const SWITCH_TIME = 0.55*FALL_TIME
const BOUNCE_TIME = 0.4
const PEN_MOVE_TIME = FALL_TIME - 0.5

const FALL_RATE = 1/FALL_TIME
const BOUNCE_RATE = 1/BOUNCE_TIME

const FALL_X_DIST = 120
const FALL_Y_POS = 380 + 70
const FALL_ANG = 80*PI/180
const HEAD_ANG = 15*PI/180
const ARMR_SHIFT = 20
const AB_ANG = 10*PI/180
const AB_SHRINK = 0.2
const TORSO_GROW = 1/(1 - AB_SHRINK) - 1
const PEN0_START_ANG = 0.8


var male
var startPos : Vector2
var startAbAng
var startHeadAng
var layHeadAng
var isSwitch
var penStage
var isBounce
var isGrabbing
var layPen1StatPos
var footLStartAng
var footRStartAng
var footStartDeltaPos
var penPolySuffix

var shadowPoly


func _init(maleIn).(maleIn):
	male = maleIn


func start():
	male.crySounds.playRandom()
	male.stopGrabPart()
	
	male.isSurrender = true
	
	startPos = male.pos
	startAbAng = male.skeleton.abdomen.get_rotation()
	startHeadAng = male.getHeadAng()
	layPen1StatPos = male.skeleton.layPen1.position
	isSwitch = false
	penStage = 0
	isBounce = false
	isGrabbing = false
	footLStartAng = male.footAngles[L]
	footRStartAng = male.footAngles[R]
	footStartDeltaPos = [male.footGlobalPos[L]-startPos, male.footGlobalPos[R]-startPos]
	shadowPoly = male.get_node("polygons/Lay/Shadow")
	
	var penScale = male.options.msoftScale*Vector2(1, male.options.mpenWidth)
	male.skeleton.layPen0.set_scale(penScale)
	male.skeleton.layPen1.set_scale(penScale)
	
	penPolySuffix = "c" if male.pen1.isCutHead else ""


func canStop():
	return time > FALL_TIME && male.opponent.isPerforming("FWinApproach")

func isDone():
	return false


func perform(time, delta):
	if time < FALL_TIME:
		var fall = time*FALL_RATE
		var fall2 = fall*fall
		var fall3 = fall2*fall
		var fall4 = fall3*fall
		
		var fallX = 3*fall3 - 2*fall4
		var fallY = -0.2*fall + 2.7*fall2 - 0.8*fall3 - 0.7*fall4
		var fallAng = 3.0*fall3 - 2.0*fall4
		var headAng = 0.3*fall + 1.7*fall2 - 1.0*fall4
		var abAng = 0.2*fall + 1.3*fall2 - 0.5*fall4
		var abForwrdAmt = 0.2*fall + 1.0*fall2-1.8*fall4 + 0.6*fall4*fall4
		
		male.skeleton.abdomen.set_rotation((1-abAng)*startAbAng + abAng*AB_ANG - 2.5*abForwrdAmt)
		male.pos = Vector2(startPos.x + fallX*FALL_X_DIST, (1-fallY)*startPos.y + fallY*FALL_Y_POS)
		male.skeleton.hip.set_rotation(fallAng*FALL_ANG)
		male.setHeadAng(startHeadAng + headAng*HEAD_ANG)
		male.skeleton.arm[R].transform.origin.y = male.skeleton.shoulderBasePos[R].y + ARMR_SHIFT*fall
		
		shadowPoly.color = Color(1, 1, 1, max(0, 5*(fallAng-0.9)))
		
		male.skeleton.abdomen.scale = Vector2(1, 1 - fall*AB_SHRINK)
		male.skeleton.neck.scale = Vector2(1, 1 + fall*TORSO_GROW)
		
		male.targetRelHandPos[L] = Vector2(fallY*140, fallX*280)
		male.targetRelHandPos[R] = (fall - 2*fall2 + fall3)*Vector2(-100, 600) + fall*Vector2(180, 30)
		
		male.footGlobalPos[L] = startPos + fallX*Vector2(-80, 350) + (1-fallX)*footStartDeltaPos[L]
		male.footGlobalPos[R] = startPos + fallX*Vector2(100, 280) + (1-fallX)*footStartDeltaPos[R]
		male.footAngles[L] = footLStartAng - 1.4*fallX
		male.footAngles[R] = footRStartAng - 1.6*fallX
		
		var upAmt = 1 - fall
		male.skeleton.setLayLegMove(10*upAmt, -7*upAmt*upAmt*upAmt)
		male.skeleton.layThighRScale = 1.0 + 3.0*upAmt
		
		if time > 0.2 && time < 0.3:
			male.face.setEyesClosed()
		
	elif time < FALL_TIME + BOUNCE_TIME:
		if !isBounce:
			isBounce = true
			layHeadAng = male.getHeadAng()
			male.game.fallSounds.playRandom()
		var bounce = (time - FALL_TIME)*BOUNCE_RATE
		var bounce2 = bounce*bounce
		var bounce4 = bounce2*bounce2
		var headAng = 2.5*bounce - 3.8*bounce2 + 1.3*bounce4
		male.setHeadAng(layHeadAng - 0.2*headAng)
	else:
		male.setHeadAng(layHeadAng)
	
	if time > FALL_TIME + 0.05:
		isGrabbing = true
		male.targetRelHandPos[L] = Vector2(13, 110)
		male.approachTargetHandPos(0.26*delta)
	else:
		male.approachTargetHandPos(0.6*delta)
	male.breathe(delta, false)
	male.approachTargetHandAng(0.5*delta, L, -0.2 if isGrabbing else 0)
	male.approachTargetHandAng(delta, R, 0)
	
	if !isSwitch && time > SWITCH_TIME:
		isSwitch = true
		var poly = male.get_node("polygons")
		poly.get_node("LegL").set_visible(false)
		poly.get_node("LegR").set_visible(false)
		poly.get_node("Lay").set_visible(true)
		
		male.setZOrder([5,6,7,13,14])
		poly.get_node("Lay").z_index = 100
		
		poly.get_node("Body/Penis").set_visible(false)
		poly.get_node("Body/BallL").set_visible(false)
		poly.get_node("Body/BallR").set_visible(false)
		
		poly.get_node("Body/ClothB").set_visible(false)
		poly.get_node("Body/ClothF").set_visible(false)
		
		male.pen1.physActive = false
		male.freezeLegs = true
	
	var penTime = time - PEN_MOVE_TIME
	if penTime < 0:
		var penAmt = 1 + penTime/PEN_MOVE_TIME
		var penAmt2 = penAmt*penAmt
		var rotAmt = 1.9*penAmt2 - 0.9*penAmt2*penAmt2
		male.skeleton.layPen0.set_rotation(male.skeleton.baseLayPen0Ang + PEN0_START_ANG*rotAmt)
		
	else:
		var penAmt = min(1, penTime/1.0)
		var penAmt2 = penAmt*penAmt
		var penAmt4 = penAmt2*penAmt2
		var penMove = 0.2*penAmt + 3.0*penAmt2 - 2.8*penAmt4 + 0.6*penAmt4*penAmt4
		
		male.skeleton.layPen0.set_rotation(male.skeleton.baseLayPen0Ang + PEN0_START_ANG - 3.4*penMove)
		male.skeleton.layPen1.set_rotation(male.skeleton.baseLayPen1Ang + 2.8*(1-penMove))
		male.skeleton.layPen2.set_rotation(male.skeleton.baseLayPen2Ang + 1.2*(1-penMove))
		
		if penStage == 0:
			penStage = 1
			male.get_node("polygons/Lay/Penis0" + penPolySuffix).set_visible(true)
			male.get_node("polygons/Lay/Penis0" + penPolySuffix).z_index = 4
		
		if penStage == 1 && penAmt > 0.5:
			penStage = 2
			var poly = male.get_node("polygons/Lay")
			poly.get_node("Penis0" + penPolySuffix).set_visible(false)
			poly.get_node("Penis1" + penPolySuffix).set_visible(true)
			poly.get_node("LegL/LegL2").set_visible(true)
			


func stop():
	pass


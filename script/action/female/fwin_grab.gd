extends Action
class_name FWinGrab

func get_class():
	return "FWinGrab"


const GRAB_TIME = 1.1
const END_TIME = GRAB_TIME + 0.1
const TORSO_TIME = 0.4
const ROTATE_TIME = 0.3
const GRAB_POS = Vector2(36.0, -17)
const HOLD_POS = GRAB_POS + Vector2(1.2, -4.5)
const GRAB_PEN_SHIFT = Vector2(11, -14)
const GRAB_PEN1_ROT = -0.30
const GRAB_PEN2_ROT = 0.2
const GRAB_ANG = -0.14
const TORSO_END_POS = Vector2(-6, 6)


var opponent
var female
var mlose
var winSkeleton
var handLOffset
var handROffset

var chestPos
var knifeHoldStartPos
var isOpen
var isGrab


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	mlose = opponent.action
	winSkeleton = female.get_node("Skeleton2D_win")
	isOpen = false
	isGrab = false
	
	handLOffset = opponent.pos - (female.skeleton.handHipOffset[L] + female.skeleton.heightDiff*Vector2.DOWN)
	handROffset = opponent.pos - (female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN)
	
	knifeHoldStartPos = female.targetGlobalHandPos[R]


func perform(time, delta):
	
	winSkeleton.hip.position = female.pos
	winSkeleton.placeArms([female.handGlobalPos[L] + female.skeleton.handHipOffset[L], \
							female.handGlobalPos[R] + female.skeleton.handHipOffset[R]])
	
	if time > 0.2 && !isOpen:
		isOpen = true
		mlose.targetSquirmRate = 0.6
		var poly = female.get_node("polygons_win")
		poly.get_node("HandL").set_visible(false)
		poly.get_node("HandL_open").set_visible(true)
		poly.get_node("HandL_opent").set_visible(true)
		var layPoly = opponent.get_node("polygons/Lay")
		var index = layPoly.z_index + layPoly.get_node("Penis1").z_index
		poly.get_node("HandL_open").z_index = index - 1
		poly.get_node("HandL_opent").z_index = index + 1
	
	female.approachTargetHandPos(0.3*delta)
	winSkeleton.breathe(delta)
	
	var torsoAmt = clamp((time - TORSO_TIME)/(END_TIME - TORSO_TIME), 0, 1)
	var torsoAmt2 = torsoAmt*torsoAmt
	var torsoAmt4 = torsoAmt2*torsoAmt2
	torsoAmt = 1.4*torsoAmt + 0.6*torsoAmt2 - 1.4*torsoAmt4 + 0.4*torsoAmt4*torsoAmt4
	var torsoShift = torsoAmt*TORSO_END_POS
	winSkeleton.setTorsoPos(torsoShift)
	female.targetGlobalHandPos[R] = knifeHoldStartPos + 0.8*torsoShift
	
	if time < GRAB_TIME - ROTATE_TIME:
		female.targetGlobalHandPos[L] = handLOffset + GRAB_POS
	else:
		var rotAmt = min(1, 1 - (GRAB_TIME - time)/ROTATE_TIME)
		winSkeleton.handRot[L] = GRAB_ANG*rotAmt
		opponent.skeleton.setLayPenPos(GRAB_PEN1_ROT*rotAmt, GRAB_PEN2_ROT*rotAmt, rotAmt*GRAB_PEN_SHIFT, \
				Vector2(1.0, 1.0), Vector2(1.0, 1.0))
		female.targetGlobalHandPos[L] = handLOffset + (1 - rotAmt)*GRAB_POS + rotAmt*HOLD_POS
	
	if !isGrab && time > GRAB_TIME:
		var layPoly = opponent.get_node("polygons/Lay")
		var index = layPoly.z_index + layPoly.get_node("Penis1").z_index
		var poly = female.get_node("polygons_win")
		poly.get_node("HandL_grab1").z_index = index - 1
		poly.get_node("HandL_grab2").z_index = index + 1
		poly.get_node("ForearmL").z_index = index - 2
		poly.get_node("HandL_open").set_visible(false)
		poly.get_node("HandL_opent").set_visible(false)
		poly.get_node("HandL_grab1").set_visible(true)
		poly.get_node("HandL_grab2").set_visible(true)
	
	


func canStop():
	return time > END_TIME


func isDone():
	return false


func stop():
	pass

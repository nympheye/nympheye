extends Action
class_name FWin

func get_class():
	return "FWin"


const STEP_TIME = 0.7
const RFOOT_TIME = 0.3
const CROUCH_DELAY = 0.5
const CROUCH_TIME = 1.1
const START_OFFSET = 5
const STEP_POS = Vector2(290, -135)
const STEP_HEIGHT = 300
const FOOTR_POSX = 150
const SHIFT_DIST = 55
const HAND_START_TIME = RFOOT_TIME + STEP_TIME + CROUCH_DELAY + 0.1
const HAND_END_TIME = RFOOT_TIME + STEP_TIME + CROUCH_DELAY + CROUCH_TIME + 0.3
const FOOTL_ANG = 0.8
const HANDR_START_POS = Vector2(-5, 0)
const TORSO_END_POS = Vector2(20, -40)


var opponent
var female
var mlose
var winSkeleton : FemaleWinSkeleton
var startPos
var startAbAng
var targetFootDelta
var isSwitch
var handRStartPos

var maleNeckStartAng
var maleHeadStartAng

var chestPos
var knifeHoldPos


func _init(femaleIn, opponentIn).(femaleIn):
	female = femaleIn
	opponent = opponentIn


func start():
	mlose = opponent.action
	winSkeleton = female.get_node("Skeleton2D_win")
	isSwitch = false
	handRStartPos = female.handGlobalPos[R]
	
	female.setZOrder([-1,-2,0,1,2])
	var poly = female.get_node("polygons/ArmR")
	poly.get_node("Knife2_blood").z_index = poly.z_index + 1
	
	startPos = female.pos
	startAbAng = female.skeleton.abdomen.get_rotation()
	targetFootDelta = opponent.pos + STEP_POS - female.skeleton.footBasePos[L] - startPos
	
	var handLOffset = opponent.pos - (female.skeleton.handHipOffset[L] + female.skeleton.heightDiff*Vector2.DOWN)
	var handROffset = opponent.pos - (female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN)
	chestPos = handLOffset + Vector2(120, -30)
	knifeHoldPos = handROffset + Vector2(-130, -146)
	
	maleNeckStartAng = opponent.skeleton.neck.get_rotation()
	maleHeadStartAng = opponent.skeleton.head.get_rotation()


func perform(time, delta):
	
	winSkeleton.hip.position = female.pos
	winSkeleton.placeLegs([opponent.pos + STEP_POS + Vector2(-18, -3), \
			female.skeleton.footBasePos[R] + Vector2(opponent.pos.x+FOOTR_POSX-27, -15)])
	winSkeleton.placeArms([female.handGlobalPos[L] + female.skeleton.handHipOffset[L], \
							female.handGlobalPos[R] + female.skeleton.handHipOffset[R]])
	
	if time < RFOOT_TIME + STEP_TIME:
		var moveAmt = time/(STEP_TIME + RFOOT_TIME)
		var moveAmt2 = moveAmt*moveAmt
		var moveAmt3 = moveAmt*moveAmt2
		var moveAmt4 = moveAmt*moveAmt3
		var moveAmtX = 0.3*moveAmt + 1.7*moveAmt2 - 1.0*moveAmt4
		female.pos = startPos + Vector2(moveAmtX*SHIFT_DIST, 0)
	
	elif time > HAND_START_TIME && time < HAND_END_TIME:
		var moveAmt = (time - HAND_START_TIME)/(HAND_END_TIME - HAND_START_TIME)
		var moveAmt2 = moveAmt*moveAmt
		var moveAmt3 = moveAmt*moveAmt2
		var moveAmt4 = moveAmt*moveAmt3
		var handRAmt = 0.2*moveAmt + 2.0*moveAmt2 - 1.2*moveAmt4
		female.targetGlobalHandPos[R] = (1 - handRAmt)*startPos + handRAmt*knifeHoldPos
	
	if time < RFOOT_TIME:
		female.moveFoot(delta, R, opponent.pos.x + FOOTR_POSX)
		
	elif time < RFOOT_TIME + STEP_TIME:
		var stepAmt = (time - RFOOT_TIME)/STEP_TIME
		var stepAmt2 = stepAmt*stepAmt
		var stepAmt3 = stepAmt*stepAmt2
		var stepAmt4 = stepAmt*stepAmt3
		
		var stepAmtX = 0.3*stepAmt + 1.7*stepAmt2 - 1.0*stepAmt4
		var stepAmtY = stepAmt2 - stepAmt4
		
		female.footGlobalPos[L] = startPos + \
				Vector2(targetFootDelta.x*stepAmtX, targetFootDelta.y*stepAmt - STEP_HEIGHT*stepAmtY)
		female.footAngles[L] = stepAmt*FOOTL_ANG
		
		female.targetRelHandPos[R] = (1-stepAmt)*(handRStartPos - female.pos) + stepAmt*HANDR_START_POS
		
		if stepAmt > 0.7 && stepAmt < 0.8:
			var poly = female.get_node("polygons/LegL")
			var winPoly = female.get_node("polygons_win")
			poly.get_node("FootL").set_visible(false)
			poly.get_node("FootL2").set_visible(true)
			var bodyIndex = opponent.get_node("polygons/Body").z_index
			poly.get_node("FootL2").z_as_relative = false
			poly.get_node("FootL2").z_index = bodyIndex
			poly.get_node("CalfL").z_as_relative = false
			poly.get_node("CalfL").z_index = bodyIndex + 1
			winPoly.z_index = bodyIndex + 10
			winPoly.get_node("FootL").z_as_relative = false
			winPoly.get_node("FootL").z_index = bodyIndex
		
		if stepAmt > 0.85:
			var amt = (stepAmt - 0.85)/(1 - 0.85)
			opponent.skeleton.neck.set_rotation(maleNeckStartAng - 0.05*amt)
			opponent.skeleton.head.set_rotation(maleHeadStartAng - 0.03*amt)
			if !mlose.holdingThroat:
				mlose.holdThroat()
				opponent.crySounds.play(2)
				opponent.face.setPain(0)
		
	elif time < RFOOT_TIME + STEP_TIME + CROUCH_DELAY + CROUCH_TIME:
		var crouchAmt = max(0, (time - RFOOT_TIME - STEP_TIME - CROUCH_DELAY)/CROUCH_TIME)
		var crouchAmt2 = crouchAmt*crouchAmt
		var crouchAmt3 = crouchAmt*crouchAmt2
		var crouchAmt4 = crouchAmt*crouchAmt3
		var crouchAmt5 = crouchAmt*crouchAmt4
		
		var dropAmt = 0.2*crouchAmt + 1.8*crouchAmt3 - 1.0*crouchAmt5
		female.pos.y = (1-dropAmt)*startPos.y + dropAmt*175
		
		var handLAmt = 0.0*crouchAmt + 1.6*crouchAmt2 - 0.6*crouchAmt4
		female.targetGlobalHandPos[L] = (1 - handLAmt)*female.pos + handLAmt*chestPos
		
		female.targetAbAng = (1-crouchAmt)*startAbAng + crouchAmt*0.5
		female.approachTargetAbAng(delta)
		
		female.footAngles[L] = FOOTL_ANG
		
		if crouchAmt > 0.1:
			female.setHandRMode(FConst.HANDR_CLOSED)
		
		if !isSwitch && crouchAmt > 0.5:
			isSwitch = true
			female.get_node("polygons").set_visible(false)
			female.get_node("polygons_win").set_visible(true)
			opponent.get_node("polygons/ArmR/HandR").set_visible(false)
		
		winSkeleton.setTorsoPos((1 - crouchAmt)*TORSO_END_POS)
	else:
		var reactAmt = (time - (RFOOT_TIME + STEP_TIME + CROUCH_DELAY + CROUCH_TIME))/0.30
		if reactAmt < 1:
			var moveAmt = 1.3*(1 - pow(2*reactAmt-1, 2))
			opponent.skeleton.setLayLegMove(moveAmt, moveAmt)
		else:
			mlose.targetSquirmRate = 0.4
		var penReactAmt = (time - (RFOOT_TIME + STEP_TIME + CROUCH_DELAY + CROUCH_TIME))/0.5
		if penReactAmt < 1:
			var moveAmt = 1 - pow(2*penReactAmt-1, 2)
			opponent.skeleton.setLayPenPos(-0.4*moveAmt, -0.5*moveAmt, Vector2.ZERO, \
					Vector2(1.0, 1.0), Vector2(1.0, 1.0))
	
	female.approachTargetHandPos(0.6*delta)
	winSkeleton.breathe(delta)
	


func canStop():
	return time > HAND_END_TIME + 0.5


func isDone():
	return false


func stop():
	pass

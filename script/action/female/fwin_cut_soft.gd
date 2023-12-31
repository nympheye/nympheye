extends Action
class_name FWinCutSoft

func get_class():
	return "FWinCutSoft"


const PULL_TIME = 0.6
const HOLD_TIME = 0.05
const CUT_TIME = 2.0
const CUT2_TIME = 1.0
const CUT_DURATION = 0.3
const PULL_SHIFT = Vector2(36, -14)
const PEN_PULL_SHIFT = PULL_SHIFT + Vector2(-7, -2)
const CUT_START_POS = Vector2(-15, -5)
const CUT_END_POS = Vector2(-15, -55)
const SHOULDER_SHIFT = Vector2(-5, 20)
const SHOULDER_CUT_SHIFT = 0.6
const HOLD_PEN1_ROT = FWinGrab.GRAB_PEN1_ROT - 0.1
const HOLD_PEN2_ROT = FWinGrab.GRAB_PEN2_ROT + 0.1
const HOLD_PEN_SCALE = 0.75
const EXTEND_SHIFT = Vector2(5, -5)
const ROT_HANDL_SHIFT = Vector2(0, 0)
const TORSO_ROT_CUT = -0.30
const TORSO_ROT_END = -0.17
#const PULL_POS = FWinGrab.HOLD_POS + PULL_SHIFT


var opponent
var female
var mlose
var winSkeleton : FemaleWinSkeleton
var handLOffset
var handROffset
var handRStartPos
var torsoStartPos
var isCut1
var isCut2
var bleedTimer
var cry1SoundTrigger
var cry2SoundTrigger


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	mlose = opponent.action
	winSkeleton = female.get_node("Skeleton2D_win")
	isCut1 = false
	isCut2 = false
	bleedTimer = 999
	cry1SoundTrigger = false
	cry2SoundTrigger = false
	
	opponent.startCrying()
	
	handLOffset = opponent.pos - (female.skeleton.handHipOffset[L] + female.skeleton.heightDiff*Vector2.DOWN)
	handROffset = opponent.pos - (female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN)
	handRStartPos = female.handGlobalPos[R]
	torsoStartPos = winSkeleton.getTorsoPos()


func perform(time, delta):
	
	winSkeleton.hip.position = female.pos
	winSkeleton.placeArms([female.handGlobalPos[L] + female.skeleton.handHipOffset[L], \
							female.handGlobalPos[R] + female.skeleton.handHipOffset[R]])
	
	if time < PULL_TIME:
		var pullAmt = time/PULL_TIME
		var pullAmt2 = pullAmt*pullAmt
		pullAmt = 0.2*pullAmt + 1.8*pullAmt2 - 1.0*pullAmt2*pullAmt2
		female.targetGlobalHandPos[L] = handLOffset + FWinGrab.HOLD_POS + pullAmt*PULL_SHIFT
		female.handGlobalPos[L] = female.targetGlobalHandPos[L]
		opponent.skeleton.setLayPenPos((1 - pullAmt)*FWinGrab.GRAB_PEN1_ROT + pullAmt*HOLD_PEN1_ROT, \
					(1 - pullAmt)*FWinGrab.GRAB_PEN2_ROT + pullAmt*HOLD_PEN2_ROT, \
					FWinGrab.GRAB_PEN_SHIFT + pullAmt*PEN_PULL_SHIFT,
					Vector2(1.0, (1 - pullAmt) + pullAmt*HOLD_PEN_SCALE), Vector2(1.0, 1.0))
		mlose.targetSquirmRate = 1.0
	elif time < PULL_TIME + HOLD_TIME:
		pass
	elif time < PULL_TIME + HOLD_TIME + CUT_TIME:
		var dt = time - (PULL_TIME + HOLD_TIME)
		var rotAmt = min(1, dt/(0.6*CUT_TIME))
		winSkeleton.handRot[R] = -1.9*rotAmt
		var moveAmt = min(1, dt/(0.7*CUT_TIME))
		var moveAmt2 = moveAmt*moveAmt
		moveAmt = 0.5*moveAmt + 1.2*moveAmt2 - 0.7*moveAmt2*moveAmt2
		female.targetGlobalHandPos[R] = (1-moveAmt)*handRStartPos + moveAmt*(handROffset + CUT_START_POS)
		female.targetGlobalHandPos[L] = handLOffset + FWinGrab.HOLD_POS + PULL_SHIFT + moveAmt*ROT_HANDL_SHIFT
		female.approachTargetHandPos(0.4*delta)
		winSkeleton.torso.set_rotation(TORSO_ROT_CUT*moveAmt)
		winSkeleton.setShoulderROffset(moveAmt*SHOULDER_SHIFT)
	elif time < PULL_TIME + HOLD_TIME + CUT_TIME + CUT_DURATION:
		var dt = time - (PULL_TIME + HOLD_TIME + CUT_TIME)
		var cutAmt = min(1, dt/CUT_DURATION)
		female.targetGlobalHandPos[R] = handROffset + (1-cutAmt)*CUT_START_POS + cutAmt*CUT_END_POS
		winSkeleton.setShoulderROffset((1 - cutAmt*SHOULDER_CUT_SHIFT)*SHOULDER_SHIFT)
		female.approachTargetHandPos(0.8*delta)
		if cutAmt > 0.3 && !isCut1:
			isCut1 = true
			var poly = opponent.get_node("polygons/Lay")
			poly.get_node("Penis1" + mlose.penPolySuffix).set_visible(false)
			poly.get_node("Penis1" + mlose.penPolySuffix + "_cut1").set_visible(true)
			mlose.targetSquirmRate = 2.0
			female.game.cutSounds.playRandom()
			opponent.face.setEyesClosed()
		if !cry1SoundTrigger && cutAmt > 0.6:
			cry1SoundTrigger = true
			opponent.loseSounds.playRandom()
		var extendAmt = min(1, dt/(0.3*CUT_DURATION))
		female.targetGlobalHandPos[L] = handLOffset + FWinGrab.HOLD_POS + PULL_SHIFT + ROT_HANDL_SHIFT + extendAmt*EXTEND_SHIFT
		female.handGlobalPos[L] = female.targetGlobalHandPos[L]
		opponent.skeleton.setLayPenPos(HOLD_PEN1_ROT, HOLD_PEN2_ROT, \
					FWinGrab.GRAB_PEN_SHIFT + PEN_PULL_SHIFT + extendAmt*EXTEND_SHIFT,
					Vector2(1.0, HOLD_PEN_SCALE), Vector2(1.0, 1.0))
	elif time < PULL_TIME + HOLD_TIME + CUT_TIME + CUT_DURATION + CUT2_TIME:
		var dt = time - (PULL_TIME + HOLD_TIME + CUT_TIME + CUT_DURATION)
		var moveAmt = min(1, dt/(0.7*CUT2_TIME))
		female.targetGlobalHandPos[R] = handROffset + (1-moveAmt)*CUT_END_POS + moveAmt*CUT_START_POS
		female.approachTargetHandPos(0.8*delta)
		winSkeleton.setShoulderROffset((1 - (1-moveAmt)*SHOULDER_CUT_SHIFT)*SHOULDER_SHIFT)
	else:
		var dt = time - (PULL_TIME + HOLD_TIME + CUT_TIME + CUT_DURATION + CUT2_TIME)
		var cutAmt = min(1, dt/CUT_DURATION)
		female.targetGlobalHandPos[R] = handROffset + (1-cutAmt)*CUT_START_POS + cutAmt*CUT_END_POS
		female.approachTargetHandPos(0.8*delta)
		if cutAmt > 0.3 && !isCut2:
			isCut2 = true
			var poly = opponent.get_node("polygons/Lay")
			poly.get_node("Penis1" + mlose.penPolySuffix + "_cut1").set_visible(false)
			poly.get_node("Penis1_cut2").set_visible(true)
			female.get_node("polygons_win/HandL_grab1/HandL_penis").set_visible(!opponent.pen1.isCutHead)
			female.get_node("polygons_win/HandL_grab1/HandL_penisc").set_visible(opponent.pen1.isCutHead)
			female.game.cutSounds.playRandom()
		if !cry2SoundTrigger && cutAmt > 0.9:
			cry2SoundTrigger = true
			opponent.sobSounds.playRandom()
			human.game.isFinished = true
		var shiftAmt = min(1, dt/0.5)
		winSkeleton.torso.set_rotation(TORSO_ROT_CUT*(1-shiftAmt) + TORSO_ROT_END*shiftAmt)
		winSkeleton.setTorsoPos(torsoStartPos + shiftAmt*Vector2(2, -2))
		winSkeleton.setShoulderROffset((1 - shiftAmt*SHOULDER_CUT_SHIFT)*SHOULDER_SHIFT)
		female.targetGlobalHandPos[L] = handLOffset + Vector2(100, -50)
		var penScaleAmt = clamp((dt - 0.05)/0.12, 0, 1)
		var penMoveAmt = clamp((dt - 0.05)/0.35, 0, 1)
		opponent.skeleton.layPen1.position = opponent.skeleton.baseLayPen1Pos + penMoveAmt*Vector2(0, 5)
		opponent.skeleton.layPen1.set_scale( \
					female.options.msoftScale*Vector2(1 + 0.7*penScaleAmt, 0.9*penScaleAmt + (1 - penScaleAmt)*HOLD_PEN_SCALE))
	
	if isCut1:
		bleedTimer += delta
		if bleedTimer > 1.2:
			bleedTimer = 0.0
			opponent.bleed(null, Vector2(14, 12), true, opponent.get_node("polygons/Lay/Penis1"), 12, 0.1)
	
	winSkeleton.breathe(delta)
	

func canStop():
	return false

func isDone():
	return false

func stop():
	pass

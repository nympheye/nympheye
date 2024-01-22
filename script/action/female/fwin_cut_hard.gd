extends Action
class_name FWinCutHard

func get_class():
	return "FWinCutHard"


const HOLD_TIME = 0.05
const CUT_TIME = 2.0
const RESET_TIME = 1.0
const CUT_DURATION = 0.2
const CUT_START_POS = Vector2(-15, -3)
const CUT_END_POS = Vector2(-15, -55)
const SHOULDER_SHIFT = Vector2(-5, 20)
const SHOULDER_CUT_SHIFT = 0.6
const HANDL_ROT_SHIFT = Vector2(0, -2)
const TORSO_SHIFT = Vector2(-7, 12)


var opponent
var female
var mlose
var winSkeleton : FemaleWinSkeleton
var handLOffset
var handROffset
var handRStartPos
var torsoStartPos
var icut
var isCut
var bleedTimer
var isResetting
var cutStartPos
var cry1SoundTrigger
var cry2SoundTrigger
var doneTime


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	mlose = opponent.action
	winSkeleton = female.get_node("Skeleton2D_win")
	icut = 1
	isCut = [false, false, false, false]
	bleedTimer = 999
	isResetting = false
	cutStartPos = CUT_START_POS
	cry1SoundTrigger = false
	cry2SoundTrigger = false
	torsoStartPos = winSkeleton.getTorsoPos()
	doneTime = 0.0
	
	opponent.startCrying()
	
	handLOffset = opponent.pos - (female.skeleton.handHipOffset[L] + female.skeleton.heightDiff*Vector2.DOWN)
	handROffset = opponent.pos - (female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN)
	handRStartPos = female.handGlobalPos[R]
	
	female.targetGlobalHandPos[L] = handLOffset + FWinStroke.ESTROKE_POS
	winSkeleton.handRot[L] = FWinStroke.ESTROKE_ANG


func perform(time, delta):
	
	winSkeleton.hip.position = female.pos
	winSkeleton.placeArms([female.handGlobalPos[L] + female.skeleton.handHipOffset[L], \
							female.handGlobalPos[R] + female.skeleton.handHipOffset[R]])
	
	opponent.skeleton.setLayPenPos(FWinStroke.ESTROKE_PEN1_ROT, FWinStroke.ESTROKE_PEN2_ROT, FWinStroke.ESTART_PEN_SHIFT,
					FWinStroke.getPen1Scale(1.0, opponent), FWinStroke.getPen2Scale(1.0, mlose))
	
	if time < CUT_TIME:
		var dt = time
		var rotAmt = min(1, dt/(0.6*CUT_TIME))
		winSkeleton.handRot[R] = -1.9*rotAmt
		var moveAmt = min(1, dt/(0.7*CUT_TIME))
		var moveAmt2 = moveAmt*moveAmt
		moveAmt = 0.5*moveAmt + 1.2*moveAmt2 - 0.7*moveAmt2*moveAmt2
		female.targetGlobalHandPos[R] = (1-moveAmt)*handRStartPos + moveAmt*(handROffset + cutStartPos)
		female.approachTargetHandPos(0.4*delta)
		winSkeleton.torso.set_rotation(-0.35*moveAmt)
		winSkeleton.setShoulderROffset(moveAmt*SHOULDER_SHIFT)
		female.targetGlobalHandPos[L] = handLOffset + FWinStroke.ESTROKE_POS + moveAmt*HANDL_ROT_SHIFT
		winSkeleton.setTorsoPos((1 - rotAmt)*FWinStroke.TORSO_SHIFT + rotAmt*TORSO_SHIFT)
	else:
		icut = 1 + floor((time - CUT_TIME)/(CUT_DURATION + RESET_TIME))
		var cutTime = fmod(time - CUT_TIME, CUT_DURATION + RESET_TIME)
		if icut <= 3 && cutTime < CUT_DURATION:
			isResetting = false
			var cutAmt = min(1, cutTime/CUT_DURATION)
			female.targetGlobalHandPos[R] = handROffset + (1-cutAmt)*cutStartPos + cutAmt*CUT_END_POS
			winSkeleton.setShoulderROffset((1 - cutAmt*SHOULDER_CUT_SHIFT)*SHOULDER_SHIFT)
			if cutAmt > 0.3 && !isCut[icut]:
				opponent.face.setEyesClosed()
				female.owner.cutSounds.playRandom()
				isCut[icut] = true
				var poly = opponent.get_node("polygons/Lay")
				if icut == 1:
					poly.get_node("Penis3").set_visible(false)
					poly.get_node("Penis3_cut1").set_visible(true)
					poly.get_node("Penis3_cut_base").set_visible(true)
					mlose.targetSquirmRate = 2.0
				elif icut == 2:
					poly.get_node("Penis3_cut1").set_visible(false)
					poly.get_node("Penis3_cut2").set_visible(true)
				elif icut == 3:
					poly.get_node("Penis3_cut2").set_visible(false)
					poly.get_node("Penis3_cut_base").set_visible(false)
					poly.get_node("Penis3_cut3").set_visible(true)
					female.get_node("polygons_win/HandL_grab1/HandL_penis_hard").set_visible(true)
					female.targetGlobalHandPos[L] = handLOffset + Vector2(122, -77)
			if icut == 3:
				var penMoveAmt = clamp((cutTime - 0.1)/(CUT_DURATION - 0.1), 0, 1)
				opponent.skeleton.layPen1.transform.origin = opponent.skeleton.baseLayPen1Pos + penMoveAmt*Vector2(0, 5)
				opponent.skeleton.layPen1.set_scale(FWinStroke.getPen1Scale(1.0, opponent) + penMoveAmt*Vector2(0, -0.1))
			if !cry1SoundTrigger && icut == 1 && cutAmt > 0.6:
				cry1SoundTrigger = true
				opponent.loseSounds.playRandom()
			if !cry2SoundTrigger && icut == 3 && cutAmt > 0.9:
				cry2SoundTrigger = true
				opponent.sobSounds.playRandom()
				human.game.isFinished = true
		elif icut <= 2:
			if icut == 2:
				mlose.isCumming = false
			if !isResetting:
				isResetting = true
				cutStartPos += Vector2(-1, -4)
			var dt = cutTime - CUT_DURATION
			var moveAmt = min(1, dt/(0.7*RESET_TIME))
			female.targetGlobalHandPos[R] = handROffset + (1-moveAmt)*CUT_END_POS + moveAmt*cutStartPos
			winSkeleton.setShoulderROffset((1 - (1-moveAmt)*SHOULDER_CUT_SHIFT)*SHOULDER_SHIFT)
		
		female.approachTargetHandPos((0.3 if isCut[3] else 0.8)*delta)
		
		if isCut[3]:
			doneTime += delta
			var moveAmt = min(1, doneTime/0.5)
			winSkeleton.setTorsoPos(torsoStartPos + moveAmt*Vector2(2, -2))
		
	if isCut[1]:
		bleedTimer += delta
		if bleedTimer > 1.2:
			bleedTimer = 0.0
			opponent.bleed(null, Vector2(14, 3), true, opponent.get_node("polygons/Lay/Penis1"), 10, 0.1)
	
	winSkeleton.breathe(delta)
	

func canStop():
	return false

func isDone():
	return false

func stop():
	pass

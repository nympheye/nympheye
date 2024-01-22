extends Action
class_name FWinStroke

func get_class():
	return "FWinStroke"


const START_TIME = 0.55
const END_TIME = 0.1
const ERECT_THRESH1 = 0.4
const ERECT_THRESH2 = 0.85

const START_POS = Vector2(23, -15)
const START_ANG = -0.2
const START_PEN1_ROT = -0.4
const START_PEN2_ROT = 0.0
const START_PEN_SHIFT = Vector2(-1, -5)
const TORSO_SHIFT = Vector2(-8, 12)

const STROKE_POS = Vector2(45, -31)
const STROKE_ANG = -0.35
const STROKE_PEN1_ROT = -0.5
const STROKE_PEN2_ROT = STROKE_ANG - START_ANG + 0.05
const STROKE_PEN_SHIFT = START_PEN_SHIFT + 0.6*(STROKE_POS - START_POS) + Vector2(0, 1)

const ESTART_POS = Vector2(20, -26)
const ESTART_ANG = -0.50
const ESTART_PEN1_ROT = -0.49
const ESTART_PEN2_ROT = -0.4
const ESTART_PEN_SHIFT = Vector2(-3, -8)

const ESTROKE_POS = Vector2(47, -36)
const ESTROKE_ANG = -0.58
const ESTROKE_PEN1_ROT = ESTART_PEN1_ROT + 1.3*(ESTROKE_ANG - ESTART_ANG)
const ESTROKE_PEN2_ROT = -0.4
const ESTROKE_PEN_SHIFT = Vector2(-3, -8)


var opponent
var female
var mlose
var winSkeleton
var handLOffset
var handROffset
var erectLevel
var soundTrigger
var cryTrigger
var startCutTime
var strokeAmtStart


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	mlose = opponent.action
	winSkeleton = female.get_node("Skeleton2D_win")
	erectLevel = 1
	soundTrigger = false
	cryTrigger = false
	startCutTime = -1
	
	handLOffset = opponent.pos - (female.skeleton.handHipOffset[L] + female.skeleton.heightDiff*Vector2.DOWN)
	handROffset = opponent.pos - (female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN)


func perform(time, delta):
	
	if time < START_TIME:
		var moveAmt = time/START_TIME
		var moveAmt2 = moveAmt*moveAmt
		moveAmt = 0.4*moveAmt + 1.3*moveAmt2 - 0.7*moveAmt2*moveAmt2
		winSkeleton.handRot[L] = (1-moveAmt)*FWinGrab.GRAB_ANG + moveAmt*START_ANG
		female.targetGlobalHandPos[L] = handLOffset + (1-moveAmt)*FWinGrab.HOLD_POS + moveAmt*START_POS
		opponent.skeleton.setLayPenPos((1-moveAmt)*FWinGrab.GRAB_PEN1_ROT + moveAmt*START_PEN1_ROT, \
					(1-moveAmt)*FWinGrab.GRAB_PEN2_ROT + moveAmt*START_PEN2_ROT, \
					(1-moveAmt)*FWinGrab.GRAB_PEN_SHIFT + moveAmt*START_PEN_SHIFT,
					Vector2(1.0, 1.0), Vector2(1.0, 1.0))
		winSkeleton.setTorsoPos(moveAmt*TORSO_SHIFT + (1-moveAmt)*FWinGrab.TORSO_END_POS)
	else:
		opponent.targetErect = 1.0
		opponent.approachTargetErect(0.45*delta) # +1
		var erect = opponent.erect
		var flaccid = 1 - erect
		
		var strokeRate = 5.0*(1 + 0.6*erect)
		var dt = time - START_TIME
		
		var strokeAmt
		
		if startCutTime < 0:
			strokeAmt = 0.5*(1 - cos(strokeRate*dt))
			strokeAmtStart = strokeAmt
		else:
			startCutTime += delta
			var endAmt = startCutTime/END_TIME
			strokeAmt = (1-endAmt)*strokeAmtStart + endAmt*1.0
			if endAmt >= 1:
				human.performFWinCutHard()
		
		var startAng = flaccid*START_ANG + erect*ESTART_ANG
		var strokeAng = flaccid*STROKE_ANG + erect*ESTROKE_ANG
		var startPos = flaccid*START_POS + erect*ESTART_POS
		var strokePos = flaccid*STROKE_POS + erect*ESTROKE_POS
		var startPen1Rot = flaccid*START_PEN1_ROT + erect*ESTART_PEN1_ROT
		var strokePen1Rot = flaccid*STROKE_PEN1_ROT + erect*ESTROKE_PEN1_ROT
		var startPen2Rot = flaccid*START_PEN2_ROT + erect*ESTART_PEN2_ROT
		var strokePen2Rot = flaccid*STROKE_PEN2_ROT + erect*ESTROKE_PEN2_ROT
		var startPenShift = flaccid*START_PEN_SHIFT + erect*ESTART_PEN_SHIFT
		var strokePenShift = flaccid*STROKE_PEN_SHIFT + erect*ESTROKE_PEN_SHIFT
		
		winSkeleton.handRot[L] = (1-strokeAmt)*startAng + strokeAmt*strokeAng
		female.targetGlobalHandPos[L] = handLOffset + (1-strokeAmt)*startPos + strokeAmt*strokePos
		winSkeleton.thumbL.transform.origin = erect*Vector2(-12, 6)
		opponent.skeleton.setLayPenPos((1-strokeAmt)*startPen1Rot + strokeAmt*strokePen1Rot, \
					(1-strokeAmt)*startPen2Rot + strokeAmt*strokePen2Rot, \
					(1-strokeAmt)*startPenShift + strokeAmt*strokePenShift,
					getPen1Scale(erect, opponent), getPen2Scale(erect, mlose))
		
		if erectLevel < 3:
			var poly = opponent.get_node("polygons/Lay")
			if erect > ERECT_THRESH2 && strokeAmt < 0.05:
				erectLevel = 3
				poly.get_node("Penis1").set_visible(false)
				poly.get_node("Penis2").set_visible(false)
				poly.get_node("Penis3").set_visible(true)
			elif erect > ERECT_THRESH1:
				var thresh = 0.2 + 0.9*sqrt((erect - ERECT_THRESH1)/(ERECT_THRESH2 - ERECT_THRESH1))
				if thresh > 0.92:
					thresh = 1.0
				if erectLevel == 1 && strokeAmt < thresh:
					erectLevel = 2
					opponent.face.setEyesClosed()
					poly.get_node("Penis1").set_visible(false)
					poly.get_node("Penis2").set_visible(true)
				elif erectLevel == 2 && strokeAmt > thresh:
					erectLevel = 1
					poly.get_node("Penis2").set_visible(false)
					poly.get_node("Penis1").set_visible(true)
		
		if erect > 0.96 && !cryTrigger:
			cryTrigger = true
			opponent.face.setPain(0.45)
			opponent.crySounds.playRandomDb(-3)
		
		if erect >= 0.98:
			mlose.isCumming = true
		
		if erect > 0.1:
			if strokeAmt > 0.8:
				soundTrigger = true
			if soundTrigger && strokeAmt < 0.2:
				soundTrigger = false
				female.owner.clapSounds.playRandomDb(-14 + erect*12)
			
	
	winSkeleton.hip.position = female.pos
	winSkeleton.placeArms([female.handGlobalPos[L] + female.skeleton.handHipOffset[L], \
							female.handGlobalPos[R] + female.skeleton.handHipOffset[R]])
	
	female.approachTargetHandPos(0.5*delta)
	winSkeleton.breathe(delta)
	

static func getPen1Scale(erect, human):
	var scale = human.options.msoftScale*Vector2.ONE + \
				human.options.mhardScale*Vector2(1.55*pow(erect, 1.5), 0.20*erect)
	scale.y *= human.options.mpenWidth
	return scale

static func getPen2Scale(erect, mlose):
	return Vector2(1 + 0.5*erect + 0.07*mlose.pulsation, 1 + 0.2*erect + 0.08*mlose.pulsation)


func cutHard():
	startCutTime = 0.0


func canStop():
	return opponent.erect >= 1


func isDone():
	return false


func stop():
	pass

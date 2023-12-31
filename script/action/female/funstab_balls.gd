extends Action
class_name FUnstabBalls

func get_class():
	return "FUnstabBalls"


const HAND_SHIFT_START_TIME = 1.1
const HAND_SHIFT_TIME = 0.8
const PUSH_TIME = 1.2
const HAND_SHIFT = Vector2(-12, 0)
const BALLS_ROT = 10*PI/180
const ROT_HAND_SHIFT = Vector2(-8, -21)
const PULL_OUT_START_TIME = HAND_SHIFT_START_TIME + 0.5
const PULL_OUT_TIME = HAND_SHIFT_TIME - (PULL_OUT_START_TIME-HAND_SHIFT_START_TIME) + 0.0
const END_SHIFT = Vector2(-30, 0)


var female
var opponent
var handStartPos
var handStartAng
var ballsStartPos
var ballsStartAng
var isOut
var isBleed
var isDone


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	female.setHandLMode(FConst.HANDL_OPEN)
	female.targetGlobalHandPos[L] = null
	handStartPos = female.handGlobalPos[R]
	female.targetGlobalHandPos[R] = handStartPos
	handStartAng = female.handAngles[R]
	opponent.perform(FUnstabBallsRec.new(opponent, 0.6 + PULL_OUT_START_TIME + PULL_OUT_TIME))
	ballsStartPos = opponent.ball[L].position
	ballsStartAng = opponent.ball[L].get_rotation()
	isOut = false
	isDone = false
	isBleed = false


func canStop():
	return false

func isDone():
	return isDone


func perform(time, delta):
	female.targetRelHandPos[L] = Vector2(-110, 60)
	female.approachTargetHandPos(0.5*delta)
	
	var move = clamp((time-HAND_SHIFT_START_TIME)/HAND_SHIFT_TIME, 0, 1)
	move = 0.5*(1 - cos(PI*move))
	var pullOut = clamp((time-PULL_OUT_START_TIME)/PULL_OUT_TIME, 0, 1)
	pullOut = pullOut*pullOut
	pullOut *= 1.2
	var timeSinceOut = time - PULL_OUT_START_TIME - PULL_OUT_TIME
	
	if time - PULL_OUT_START_TIME > 0.05 && !isBleed:
		isBleed = true
		opponent.innard(Vector2(-59, 115), false, female.get_node("polygons/ArmR"))
		opponent.bleed(null, Vector2(-59, 115), false, female.get_node("polygons/ArmR"), 10, 0.1)
		female.game.slideSounds.play(2)
	
	if timeSinceOut > 0 && !isOut:
		isOut = true
		opponent.ball[L].physActive = true
		female.handVel[R] = 0.3*female.handSpeed*Vector2.LEFT
	
	if timeSinceOut > -0.4:
		if timeSinceOut < PUSH_TIME:
			var maleAng = opponent.skeleton.hip.get_rotation() + 0.6*opponent.skeleton.abdomen.get_rotation()
			var maleChestPos = opponent.pos + Vector2(-62, -87).rotated(maleAng)
			female.targetGlobalHandPos[L] = maleChestPos - \
					(female.skeleton.handHipOffset[L] + female.skeleton.heightDiff*Vector2.DOWN)
			female.approachTargetHandAng(delta, L, -1.1 + 0.5*maleAng + 1.1*max(0, timeSinceOut-1.3))
			if timeSinceOut > -0.2:
				female.setHandLMode(FConst.HANDL_PUSH)
		else:
			female.targetGlobalHandPos[L] = null
			female.approachTargetHandAng(delta, L, 0)
			if timeSinceOut > PUSH_TIME + 0.1:
				female.setHandLMode(FConst.HANDL_OPEN)
	
	if !isOut:
		var handShift = HAND_SHIFT*move
		
		female.targetGlobalHandPos[R] = handStartPos + handShift + move*ROT_HAND_SHIFT - pullOut*FStabBalls.PUSH_SHIFT
		female.handAngles[R] = handStartAng + move*BALLS_ROT + pullOut*(FStabBalls.STAB_ANG - FStabBalls.END_ANG)
		
		var ballsAng = ballsStartAng + move*BALLS_ROT
		
		opponent.ball[L].set_rotation(ballsAng)
		opponent.ball[L].position = ballsStartPos + handShift
		
		opponent.pen1.set_rotation(max(0.6 + move*0.3, opponent.pen1.get_rotation()))
		
	else:
		female.setUseGlobalHandAngles(false)
		female.approachTargetHandAng(delta, R, 0.0)
		female.targetGlobalHandPos[R] = null
		female.targetRelHandPos[R] = Vector2(20, -10)
		female.approachTargetHandPos(0.3*delta)
		if timeSinceOut > 0.0:
			female.targetAbAng = 0
			female.approachTargetAbAng(0.5*delta)
			female.targetHeight = 0
			female.approachTargetHeight(0.5*delta)
		if timeSinceOut > 0.35:
			female.setIsTurn(false)
		if timeSinceOut > 0.05:
			var poly = female.get_node("polygons/ArmR")
			poly.get_node("Knife2_blood").z_index = poly.z_index + 1
		if timeSinceOut > 1.5:
			female.targetRelHandPos[L] = Vector2.ZERO
		if timeSinceOut > 2.1:
			isDone = true


func stop():
	female.targetGlobalHandPos[L] = null
	female.targetRelHandPos[L] = Vector2.ZERO


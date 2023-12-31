extends Action
class_name FGrabBallRec

func get_class():
	return "FGrabBallRec"


const BALL_ROTATION = 110*PI/180
const BALL_ROTATION_BOTH = 105*PI/180
const EXPOSED_STRETCH = [Vector2(-10, 13), Vector2(-10, 17)]
const PEN_ROTATION = 45*PI/180
const PUNCH_STAMINA = 0.25

var male
var fgrab
var iball
var ball
var isHoldingArm
var vslack
var hslack
var maxLegsClosed

var isPunchInterrupt
var isPunching
var punchCount
var punchTarget
var punchHigh
var punchTimer
var punchStartPos
var punchSoundTrigger
var yellSoundTrigger


func _init(maleIn, fgrabIn).(maleIn):
	male = maleIn
	fgrab = fgrabIn
	iball = fgrab.iball
	ball = male.ball[iball]


func start():
	isHoldingArm = false
	maxLegsClosed = 0.65
	isPunching = false
	punchTimer = 0.0
	punchCount = 0
	yellSoundTrigger = false
	
	male.retract = 0
	ball.physActive = false
	if fgrab.both:
		ball.set_rotation(BALL_ROTATION_BOTH)
	else:
		ball.set_rotation(BALL_ROTATION)
	
	male.setZOrder([-4,-5,-2,3,4])
	male.get_node("polygons/ArmR/HandR_grab1").set_visible(true)
	male.get_node("polygons/ArmR/HandR_grab2").set_visible(true)
	male.get_node("polygons/ArmR/HandR").set_visible(false)
	var zindexArm = Utility.getAbsZIndex(fgrab.female.get_node("polygons/ArmL/Foreward/ForearmL"))
	male.get_node("polygons/ArmR/HandR_grab1").z_index = zindexArm + 1
	male.get_node("polygons/ArmR/HandR_grab2").z_index = zindexArm - 1
	
	if iball == L:
		male.get_node("polygons/Body/Penis").z_index = zindexArm-1
		male.get_node("polygons/Body/Penis").z_as_relative = false
		male.get_node("polygons/Body/BallR").z_index = zindexArm-2
		male.get_node("polygons/Body/BallR").z_as_relative = false
	
	if fgrab.both:
		male.get_node("polygons/Body/BallR").set_visible(false)
		male.get_node("polygons/Body/BallL").set_visible(false)
		male.get_node("polygons/Body/Balls").set_visible(true)
	
	if fgrab.both:
		vslack = 22
		hslack = 27
	else:
		vslack = 25 if (iball == L) else 20
		hslack = 30 if (iball == L) else 20
		if ball.isExposed:
			vslack += EXPOSED_STRETCH[iball].y
			hslack -= EXPOSED_STRETCH[iball].x


func canStop():
	return !(fgrab.female.isPerforming("FGrabBall") || fgrab.female.isPerforming("FStabBalls")) || fgrab.done

func isDone():
	return fgrab.done


func perform(time, delta):
	var fhandPos = male.femaleGlobalHandPos(L)
	
	male.targetErect = 0.0
	
	if male.isActive:
		punch(delta)
		male.regen(0.19*delta)
	else:
		male.approachTargetHandPos(0.3*delta)
	
	var farmAng = fgrab.female.skeleton.forearmAbsAngle[L]
	var farmVect = Vector2(cos(farmAng), sin(farmAng))
	var farmOrthoVect = Vector2(farmVect.y, -farmVect.x)
	
	var targetHandPos = fhandPos - 60*farmVect + 43*farmOrthoVect \
			- male.skeleton.handHipOffset[R] + Vector2(-10, -10)
	if !isHoldingArm:
		male.targetGlobalHandPos[R] = targetHandPos
		male.approachTargetHandPos(delta)
		if (male.handGlobalPos[R] - targetHandPos).length_squared() < 10:
			isHoldingArm = true
	else:
		male.targetGlobalHandPos[R] = targetHandPos
		male.handGlobalPos[R] = targetHandPos
	
	male.handAngles[R] = farmAng - male.skeleton.forearmAbsAngle[R] + 1.3
	
	var ballPos
	if !ball.isSevered || !ball.isExposed:
		ballPos = fhandPos
		if fgrab.both:
			ballPos += Vector2(46,-9)
		else:
			if iball == L:
				ballPos += Vector2(59,-47) if male.ball[L].isExposed else Vector2(49,-29)
			else:
				ballPos += Vector2(62,-50) if male.ball[R].isExposed else Vector2(51,-39)
			if fgrab.female.isPerforming("FTwist"):
				ballPos += Vector2(-12, -2)
				if ball.isSevered:
					ballPos += Vector2(0, -8)
		ball.position = ballPos - male.pos
	else:
		ball.physActive = true
		ballPos = ball.position
	
	male.targetHeight = max(0, ballPos.y - ball.basePos.y - vslack)
	var targetX = ballPos.x - ball.basePos.x + hslack
	
	male.legsClosedFrac = min(maxLegsClosed, male.legsClosedFrac + 0.3*delta*male.legCloseRate)
	male.setLegsClosed(male.legsClosedFrac)
	
	if fgrab.both:
		male.pen1.set_rotation(max(PEN_ROTATION, male.pen1.get_rotation()))
	
	if !ball.isSevered:
		var moveRate = 1.0 + max(0, (male.pos.x - targetX) - 4)/15
		male.approachTargetPosX(delta*moveRate, targetX)
	
	male.walkThresh(delta, 50)
	male.approachTargetHeight(2.0*delta)
	male.approachTargetAbAng(0.6*delta)
	
	if !yellSoundTrigger && time > 0.25:
		yellSoundTrigger = true
		male.hitSounds.playRandomDb(-2)
		male.face.setPain(-0.2)


const PUNCH_START_TIME = 0.3
const PUNCH_PUNCH_TIME = 0.13
const PUNCH_END_TIME =  0.05
const PUNCH_RESET_TIME = 0.60
func punch(delta):
	punchTimer += delta
	if isPunching:
		if punchTimer < PUNCH_START_TIME:
			male.targetGlobalHandPos[L] = male.pos + punchStartPos
			male.approachTargetHandPos(0.6*delta)
			if punchTimer > PUNCH_START_TIME - 0.1:
				male.setHandLMode(MConst.HANDL_FIST)
		elif punchTimer < PUNCH_START_TIME + PUNCH_PUNCH_TIME:
			var dt = punchTimer - PUNCH_START_TIME
			var amt = dt/PUNCH_PUNCH_TIME
			amt = amt*amt
			male.handGlobalPos[L] = (1-amt)*(male.pos + punchStartPos) + amt*(fgrab.female.pos + punchTarget)
			if amt > 0.2 && !punchSoundTrigger:
				punchSoundTrigger = true
				male.game.swingSounds.playRandom()
		elif punchTimer <  PUNCH_START_TIME + PUNCH_PUNCH_TIME + PUNCH_END_TIME:
			if punchHigh:
				fgrab.female.recPunchFace()
			else:
				fgrab.female.recPunchBreast()
			if isPunchInterrupt == null:
				isPunchInterrupt = male.opponent.isPerforming("FGrabBall") && randf() < (0.35 + 0.20*punchCount)
				if isPunchInterrupt:
					male.opponent.stopAction()
					male.recoil(false, false, Human.GRAB_GROIN)
		elif punchTimer <  PUNCH_START_TIME + PUNCH_PUNCH_TIME + PUNCH_END_TIME + PUNCH_RESET_TIME:
			pass
		else:
			isPunching = false
	if punchTimer > PUNCH_START_TIME + PUNCH_PUNCH_TIME + PUNCH_END_TIME:
		male.targetGlobalHandPos[L] = male.pos
		male.approachTargetHandPos(delta)
		if punchTimer > PUNCH_START_TIME + PUNCH_PUNCH_TIME + 0.25:
			male.setHandLMode(MConst.HANDL_OPEN)


func startPunch():
	if !isPunching && human.stamina > PUNCH_STAMINA:
		punchCount += 1
		isPunching = true
		isPunchInterrupt = null
		human.tire(PUNCH_STAMINA)
		punchSoundTrigger = false
		punchHigh = true#randf() < 0.5
		punchTimer = 0.0
		if punchHigh:
			punchStartPos = Vector2(80, 5)
			punchTarget = Vector2(100, -160)
		else:
			punchTarget = Vector2(60, -10)
			punchStartPos = Vector2(80, 10)


func stop():
	ball.physActive = true
	male.get_node("polygons/ArmR/HandR_grab1").set_visible(false)
	male.get_node("polygons/ArmR/HandR_grab2").set_visible(false)
	male.get_node("polygons/ArmR/HandR").set_visible(true)
	male.targetGlobalHandPos[L] = null
	male.targetGlobalHandPos[R] = null
	male.face.setNeutral()
	male.setHandLMode(MConst.HANDL_OPEN)

extends Action
class_name MGrabArmsPen

func get_class():
	return "MGrabArmsPen"


const FMOVE_RATIO_X = 1.4
const FMOVE_RATIO_Y = 2.0
const CIRCLE_RAD = 37
const CIRCLE_MINANG = 10*PI/180
const CIRCLE_MAXANG = 90*PI/180
const PEN_CONTACT_ANG = 70*PI/180
const PEN_PENIS_ANG = -145*PI/180
const PEN_DEPTH = 3
const SHIFT_DELAY = 0.3
const DRIFT_RAND_CONST = 90.0
const DRIFT_SPRING_CONST = 1.9
const DRIFT_DAMP_CONST = 1.7

const BALL_YI = [0.7, 0.5]
const BALL_YSHIFT = [-0.5, -0.6]


var male
var opponent
var opponentStartPos
var maleStartPos
var armOffset
var isStart
var done
var penetration
var pen : Bone2D
var targetX
var targetY
var driftVel
var driftVect
var penOffset
var kickTime
var releaseTime
var shiftTimer
var deadBall
var rng


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent
	done = false


func start():
	pen = male.skeleton.hip.get_node("Penis_back")
	pen.vel = Vector2.ZERO
	pen.set_rotation_degrees(-145)
	penetration = 0.0
	opponentStartPos = Vector2(male.pos.x - 125, male.pos.y - 215)
	maleStartPos = male.pos
	targetX = 5 + 10*randf()
	targetY = 5*randf()
	targetShifted()
	armOffset = [opponent.handGlobalPos[L] - opponent.pos, opponent.handGlobalPos[R] - opponent.pos]
	kickTime = 0
	deadBall = -1
	releaseTime = 0
	shiftTimer = 0
	penOffset = Vector2.ZERO
	driftVel = Vector2.ZERO
	driftVect = Vector2.ZERO
	rng = RandomNumberGenerator.new()
	rng.randomize()
	male.setHandLMode(MConst.HANDL_LIFT2)
	male.setHandRMode(MConst.HANDR_GRAB_CLOTH)


func canStop():
	return true

func isDone():
	return done


func perform(time, delta):
	male.breathe(delta, true)
	male.targetErect = 1.0
	shiftTimer -= delta
	
	var penAngle = pen.get_rotation()
	var penPos = male.pos + pen.position + Vector2(86, 0).rotated(penAngle)
	var vagPos = Vector2(-38, 23.2) + opponent.pos + opponent.skeleton.heightDiff*Vector2.DOWN
	
	penOffset = penPos - vagPos
	var contactAngle = clamp(atan2(penOffset.y, penOffset.x), CIRCLE_MINANG, CIRCLE_MAXANG)
	var surfTanVect = Vector2(cos(contactAngle), sin(contactAngle))
	var contactDepth = max(0, CIRCLE_RAD - penOffset.dot(surfTanVect))
	
	var dContactAng = (contactAngle - PEN_CONTACT_ANG)/(0.1 + 0.15*penetration)
	var dPenisAng = (penAngle - PEN_PENIS_ANG)/(0.5 + 0.5*penetration)
	var targetPen = exp(-dContactAng*dContactAng - dPenisAng*dPenisAng)
	targetPen *= min(1, sqrt(contactDepth/PEN_DEPTH))
	var dpen = targetPen - penetration
	var change = delta/0.8 if dpen > 0 else -delta/0.3
	if abs(dpen) < abs(change):
		penetration = targetPen
	else:
		penetration += change
	
	pen.contactDepth = contactDepth
	pen.contactVect = surfTanVect
	pen.contactAngle = contactAngle
	pen.penetration = penetration
	
	if releaseTime > 0:
		releaseTime += delta
		targetX = -160
		targetY = -80
		male.pushAway(0.5*delta, -900)
		if releaseTime > 0.15 && opponent.isPerforming("MGrabArmsRec"):
			opponent.action.done = true
			male.setHandLMode(MConst.HANDL_OPEN)
			male.setHandRMode(MConst.HANDR_OPEN)
		if releaseTime > 0.25:
			male.targetAbAng = 0
			male.targetHeight = 0
			male.approachTargetHeight(delta)
			male.targetSpeed = male.walkSpeed
			male.approachTargetSpeed(delta)
			male.walk(delta)
			male.approachTargetHandAng(delta, L, 0)
			male.approachTargetHandAng(delta, R, 0)
			male.approachTargetHandPos(delta)
			if male.isBack:
				male.setIsBack(false)
				male.setDefaultZOrder()
				male.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
				male.targetGlobalHandPos = [null, null]
				male.setHandRMode(MConst.HANDR_OPEN)
		if releaseTime > 0.6:
			if kickTime > 0:
				male.recoilSound(deadBall >= 0, deadBall >= 0, false, Human.GRAB_GROIN)
			else:
				done = true
	
	if opponent.isPerforming("MGrabArmsRec"):
		for i in [L,R]:
			var other = ~i & 1
			
			var farmAng = opponent.skeleton.forearmAbsAngle[other]
			var farmVect = Vector2(cos(farmAng), sin(farmAng))
			var farmOrthoVect = Vector2(-farmVect.y, farmVect.x)
			
			var fwristPos = male.femaleGlobalHandPos(other)
			fwristPos += MGrabArms.HAND_REL_SHIFT_UP[i].x*farmVect + MGrabArms.HAND_REL_SHIFT_UP[i].y*farmOrthoVect
			
			male.handGlobalPos[i] = fwristPos - male.skeleton.handHipOffset[i]
			male.handAngles[i] = MGrabArms.HAND_ANGLE_UP_OFFSET[i] + farmAng - male.skeleton.forearmAbsAngle[i]
		
		driftVel += delta*(DRIFT_RAND_CONST*Vector2(rng.randfn(), 0.5*rng.randfn()) - DRIFT_SPRING_CONST*driftVect)
		driftVel -= delta*DRIFT_DAMP_CONST*driftVel
		
		var separation = male.pos.x - opponent.pos.x
		if separation < MGrabArmsRec.MIN_SEPARATION + 1:
			driftVel.x = max(0, driftVel.x)
		if separation > MGrabArmsRec.MAX_SEPARATION - 1:
			driftVel.x = min(0, driftVel.x)
		
		driftVect += delta*driftVel
		
		var driftedX = targetX + driftVect.x
		var driftedY = targetY + driftVect.y
		
		var mTargetX = driftedX
		var fTargetX = -FMOVE_RATIO_X*driftedX
		var mTargetY = driftedY
		var fTargetY = -FMOVE_RATIO_Y*driftedY
		
		male.targetAbAng = MGrabArms.SHIFT_AB_ANG
		male.targetHeight = maleStartPos.y + mTargetY
		
		for i in [L,R]:
			opponent.targetGlobalHandPos[i] = Vector2( \
					opponentStartPos.x + armOffset[i].x + fTargetX, \
					opponentStartPos.y + armOffset[i].y + fTargetY)
		
		if kickTime > 0:
			kickTime += delta
			for i in [L,R]:
				var ball = male.ball[i]
				if ball.isCrushed:
					ball.transform.origin.y = ball.basePos.y
				else:
					ball.transform.origin.y = ball.basePos.y*(BALL_YI[i] + BALL_YSHIFT[i]*(kickTime - 0.2*kickTime*kickTime*kickTime))
				if deadBall == i && kickTime > 0.2:
					ball.crush()
			if kickTime > 0.4 && releaseTime <= 0:
				release()
		
		opponent.action.setPenetration(delta, penetration, contactAngle, pen.get_rotation())
		male.approachTargetHeight((0.10 if male.targetHeight > male.pos.y else 0.25)*delta)
		male.approachTargetPosX(0.5*delta, maleStartPos.x + mTargetX)
	
	male.approachTargetAbAng(delta)
	male.setArmRUp(false)


func shiftTargetX(dir):
	if shiftTimer <= 0:
		var currentX = male.pos.x - maleStartPos.x
		var currentY = male.pos.y - maleStartPos.y
		targetX = currentX + 6.0*(0.6 + 0.4*randf())*(1 if dir else -1)
		targetY = currentY + 0.3*(2*randf()-1)
		targetShifted()

func shiftTargetY(dir):
	if shiftTimer <= 0:
		var currentX = male.pos.x - maleStartPos.x
		var currentY = male.pos.y - maleStartPos.y
		targetX = currentX + 0.3*(2*randf()-1)
		targetY = currentY + (0.6 + 0.4*randf())*(3 if dir else -5)
		targetShifted()


func targetShifted():
	targetX = clamp(targetX, -17, 14)
	targetY = clamp(targetY, -6, 6)
	shiftTimer = SHIFT_DELAY


func release():
	if releaseTime <= 0:
		releaseTime = 1e-10
		opponent.action.releaseTime = 1e-10
		if kickTime > 0:
			male.loseSounds.playRandom()


func recKick():
	kickTime = 1e-10
	
	var targetBall
	if male.ball[R].health <= 0:
		targetBall = L
	elif male.ball[L].health <= 0:
		targetBall = R
	else:
		targetBall = L if (randf() < 0.5) else R
	male.ball[targetBall].recDamage(0.75)
	if male.ball[targetBall].health <= 0:
		deadBall = targetBall
	male.groin.kick(deadBall, 0, Groin.KICK_BACK)
	male.owner.kickSounds.playRandom()


func stop():
	male.autoArmRUp = true
	male.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
	male.targetGlobalHandPos= [null, null]
	male.setHandRMode(MConst.HANDR_OPEN)
	male.setIsBack(false)
	male.pos.x += 30

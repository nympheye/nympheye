extends Action
class_name FGrabBall

func get_class():
	return "FGrabBall"


const L0 = 0
const R0 = 1

const STAMINA = 0.30
const STAB_STAMINA = 0.15
const REACH = 312
const LEAN = 20*PI/180

const TARGET_SEPARATION = 360
const TUG_SHIFT = Vector2(30, -18)
const TUG_SHIFT_BOTH = Vector2(20, -13)
const BODY_SHIFT = -15
const TUG_LEN = 0.22
const BODY_SHIFT_RATE = 1/TUG_LEN
const RELAX_LEN = 0.1
const TUG_DELAY = 1.5
const SQUEEZE_ANG = 25*PI/180
const SQUEEZE_RATE = 0.8
const SQUEEZE_SCALE = 0.45
const HANDL_ANG = 0.15


var female
var opponent
var grabOffset
var holdPos
var midpointX
var isGrab
var iball
var ball
var both
var done
var tugTime
var tugShift
var squeezeAmt
var squeezeTrigger
var dontStopGrabbing
var isCrushing

var isStabbing
var stabTimer
var stabState


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent
	done = false
	isGrab = false
	dontStopGrabbing = false
	both = false
	isCrushing = false
	stabTimer = 0
	if opponent.ball[L].health <= 0:
		iball = R
	elif opponent.ball[R].health <= 0:
		iball = L
	else:
		if opponent.ball[L].isExposed:
			iball = L
		elif opponent.ball[R].isExposed:
			iball = R
		elif !opponent.hasCloth && randf() < 0.4 - 0.15*opponent.retract:
			both = true
			iball = L
		else:
			iball = L if (randf() < 0.5) else R


static func inReach(human):
	var shoulderPos = human.skeleton.arm[L0].get_global_position()
	var hipPos = human.opponent.skeleton.hip.get_global_position()
	return (shoulderPos - hipPos).length() < REACH


func start():
	ball = opponent.ball[iball]
	human.tire(0.5*STAMINA)
	squeezeAmt = 0
	female.setUseGlobalHandAngles(true)
	tugShift = TUG_SHIFT_BOTH if both else TUG_SHIFT
	
	female.gruntSounds.playRandomDb(-3)
	female.face.setNeutral()
	female.targetRelHandPos[R] = Vector2.ZERO
	
	# female armL z_index = male body z_index = -2
	setFemaleZOrder()
	opponent.setDefaultZOrder()
	
	opponent.setGrabCoverVisible(iball == R)
	
	grabOffset = -female.skeleton.handHipOffset[L] - Vector2.DOWN*female.skeleton.heightDiff
	if both:
		grabOffset += Vector2(-13, 71)
	else:
		grabOffset += Vector2(-19, 80)


func canStop():
	return !isCrushing


func isDone():
	return done


func perform(time, delta):
	stab(delta)
	
	female.approachTargetHandAng(delta, L, HANDL_ANG)
	female.approachDefaultHandAng(delta, R)
	
	if time > 0.22 && !isGrab:
		var reachVect = (opponent.pos + grabOffset) - (female.pos + female.skeleton.hipArmOffset[L])
		reachVect.y = 0.6*reachVect.y
		if time > 0.45 || reachVect.length() > REACH:
			done = true
			return
	
	var handMoveRate = 1.0
	var grabPos = opponent.pos + grabOffset
	
	if !isGrab:
		female.targetAbAng = LEAN
		
		midpointX = 0.5*(opponent.pos.x + female.pos.x)
		female.approachTargetPosX(delta, midpointX - TARGET_SEPARATION/2 + 10)
		
		var dist = (female.handGlobalPos[L] - grabPos).length()
		if dist > 75:
			grabPos += Vector2(-60, 5)
		elif dist < 8:
			setFemaleZOrder()
			if !opponent.perform(FGrabBallRec.new(opponent, self)):
				done = true
				return
			isGrab = true
			human.grabbedBall = true
			human.tire(0.5*STAMINA)
			female.setHandLMode(FConst.HANDL_BOTH if both else FConst.HANDL_GRAB)
			female.setKnifePointUp(true)
			holdPos = grabOffset + Vector2(0, 5)
			if ball.isExposed:
				holdPos += FGrabBallRec.EXPOSED_STRETCH[iball]
			holdPos.x += min(female.pos.x + 205, Game.MAP_LIMIT - 100)
			grabPos = holdPos
			tugTime = TUG_LEN
			if both:
				female.setHandRMode(FConst.HANDR_CLOSED)
	else: # isGrab
		female.targetAbAng = 0
		var bodyShift = 0
		tugTime = tugTime + delta
		if tugTime > 0:
			var thumbRot = female.skeleton.thumbL.get_rotation()
			if tugTime > TUG_DELAY:
				tugTime = 0
			if tugTime < TUG_LEN:
				squeezeAmt = max(0, squeezeAmt - 8*delta*SQUEEZE_RATE)
				grabPos = holdPos + tugShift
				handMoveRate = 0.6
				bodyShift = tugTime*BODY_SHIFT_RATE
			else:
				if tugTime < TUG_LEN + RELAX_LEN:
					grabPos = holdPos - 0.3*tugShift
				else:
					squeezeAmt = min(1, squeezeAmt + delta*SQUEEZE_RATE)
					grabPos = holdPos
					handMoveRate = 0.4
				if tugTime < TUG_LEN + 0.05:
					opponent.pen1.vel.y -= delta*1000
					opponent.pen1.vel.x -= delta*22000
					opponent.pen2.vel.x -= delta*9000
				bodyShift = max(0, 1 - (tugTime - TUG_LEN)*BODY_SHIFT_RATE)
		
		var tgtPosX = max(midpointX - TARGET_SEPARATION/2, opponent.pos.x - TARGET_SEPARATION - 5)
		female.approachTargetPosX(delta, tgtPosX + bodyShift*BODY_SHIFT)
		female.pushAway(delta, female.opponent.pos.x - 250)
	
	grabPos.x = max(grabPos.x, opponent.pos.x - female.skeleton.handHipOffset[L].x - 92)
	female.targetGlobalHandPos[L] = grabPos
	
	if !both:
		female.skeleton.thumbL.set_rotation(female.skeleton.thumbLStartAng + SQUEEZE_ANG*squeezeAmt + (0.1 if isCrushing else 0))
		ball.setScale(1, 1 + squeezeAmt*SQUEEZE_SCALE)
		
		if squeezeAmt < 0.1:
			squeezeTrigger = false
			if isCrushing:
				done = true
				stopGrabbing()
				ball.crush()
				opponent.recoil(true, true, Human.GRAB_GROIN)
		if !squeezeTrigger && squeezeAmt > 0.5:
			squeezeTrigger = true
			ball.recDamage(0.18 if ball.isExposed else 0.10)
			if ball.health <= 0:
				isCrushing = true
				opponent.groin.grab(iball)
				opponent.face.setShock(-0.4)
	
	if isGrab:
		female.regen(1.15*delta)
	
	female.approachTargetAbAng(delta)
	female.approachTargetHandPos(handMoveRate*delta)
	
	female.targetHeight = (0.5 if isGrab else 0.7)*female.downHeight
	female.approachTargetHeight(delta)
	female.updateLegsClosed(delta)
	
	female.breathe(delta, true)
	female.walkThresh(delta, 28)
	female.updateGrabPart()
	


func startStab():
	if !isStabbing:
		isStabbing = true
		stabTimer = 0.0
		stabState = 0
		human.tire(STAB_STAMINA)


const STAB_START_POS = Vector2(-45, 5)
const STAB_TARGET_POS = Vector2(-28, -108)
const STAB_START_TIME = 0.16
const STAB_STAB_TIME = 0.23
const STAB_END_TIME =  0.20
func stab(delta):
	stabTimer += delta
	if isStabbing:
		if stabTimer < STAB_START_TIME:
			female.targetRelHandPos[R] = STAB_START_POS
			female.approachTargetHandPos(0.6*delta)
		elif stabTimer < STAB_START_TIME + STAB_STAB_TIME:
			var dt = stabTimer - STAB_START_TIME
			var amt = dt/STAB_STAB_TIME
			amt = amt*amt
			female.handGlobalPos[R] = (1-amt)*(female.pos + STAB_START_POS) + amt*(opponent.pos + STAB_TARGET_POS)
			if stabState == 0 && amt > 0.2:
				stabState = 1
				female.game.swingSounds.playRandom()
			if stabState == 1 && stabTimer > STAB_START_TIME + STAB_STAB_TIME - 0.05:
				stabState = 2
				opponent.recStabAb()
				opponent.get_node("polygons/Body/StabAb").z_index = 200
				female.game.cutSounds.playRandom()
		elif stabTimer <  STAB_START_TIME + STAB_STAB_TIME + STAB_END_TIME:
			var dt = stabTimer - (STAB_START_TIME + STAB_STAB_TIME)
			var amt = dt/STAB_END_TIME
			female.handGlobalPos[R] = (1-amt)*(opponent.pos + STAB_TARGET_POS) + amt*female.pos
		else:
			isStabbing = false
	else:
		female.targetRelHandPos[R] = Vector2.ZERO
	if stabState == 2 && stabTimer > STAB_START_TIME + STAB_STAB_TIME + STAB_END_TIME + 0.3:
		stabState = 3
		opponent.get_node("polygons/Body/StabAb").z_index = opponent.stabAbBaseIndex
		


func stop():
	female.targetGlobalHandPos = [null, null]
	female.setIsTurn(false)


func setFemaleZOrder():
	female.setZOrder([-2,-1,0,1,2])
	
	var fpoly = female.get_node("polygons/ArmL")
	
	var ballIndex = opponent.get_node("polygons/Body/Ball" + ("R" if iball == R else "L")).z_index
	fpoly.get_node("Foreward/Grab_both").z_index = opponent.get_node("polygons/Body/Balls").z_index - 2
	fpoly.get_node("Foreward/Grab").z_index = ballIndex


func interrupted():
	if !dontStopGrabbing:
		done = true
		stopGrabbing()
		if isGrab:
			opponent.recoil(false, false, Human.GRAB_GROIN)


func stopGrabbing():
	female.setHandLMode(FConst.HANDL_OPEN)
	female.setKnifePointUp(false)
	female.targetAbAng = 0
	female.targetGlobalHandPos[L] = null
	female.setUseGlobalHandAngles(false)
	ball.setScale(1, 1)
	if both:
		opponent.get_node("polygons/Body/BallR").set_visible(true)
		opponent.get_node("polygons/Body/BallL").set_visible(true)
		opponent.get_node("polygons/Body/Balls").set_visible(false)

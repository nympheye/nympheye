extends Action
class_name MGrabArmR

func get_class():
	return "MGrabArmR"


const TEAR = 0
const FEEL = 1
const PUNCH_GUT = 2
const STOP_GRAB = 3

const STAMINA = 0.28
const REACH = 430
const SEPARATION = 295
const SUBACT_STAMINA = [0.2, 0, 0.25, 0]
const SUBACT_DELAY = 0.3


var male
var opponent
var opponentStartPosX
var isGrab
var grabTime
var grabOffset
var isStart
var subact
var subactTime
var felt
var done

var soundTrigger
var punchStartPos
var punchDelivered


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent
	done = false


func start():
	isGrab = false
	isStart = true
	soundTrigger = false
	felt = false
	grabTime = 0
	grabOffset = Vector2.ZERO
	subact = -1
	subactTime = 0
	setZOrder()
	var separation = male.pos.x - opponent.pos.x
	opponentStartPosX = opponent.pos.x \
			+ opponent.vel.x*abs(opponent.vel.x)/(2*opponent.getAccel()) \
			+ clamp(0.6*(separation - SEPARATION), -250, 80)
	male.tire(0.5*STAMINA)
	male.gruntSounds.playRandomDb(-2)


func canStop():
	return true

func isDone():
	return done


func perform(time, delta):
	male.breathe(delta, true)
	
	var fwristPos = male.femaleGlobalHandPos(R) + Vector2(-27, -30 - 0.05*male.pos.y + 0.18*opponent.pos.y)
	
	if !isGrab:
		var shoulderPos = male.pos + male.skeleton.torsoBasePos + male.skeleton.shoulderBasePos[R]
		var reachVect = fwristPos - shoulderPos
		var reachVectLen = reachVect.length()
		var outOfReach = reachVectLen > REACH
		var outOfReachX = abs(reachVect.x) > 0.9*REACH
		if (time > 0.25 && outOfReachX) || (time > 0.43 && outOfReach) || opponent.isTurn:
			done = true
			return
			
		if outOfReach:
			male.targetGlobalHandPos[R] = shoulderPos + 0.90*REACH*reachVect/reachVectLen - male.skeleton.handHipOffset[R]
		else:
			male.targetGlobalHandPos[R] = fwristPos - male.skeleton.handHipOffset[R]
		male.targetRelHandPos[L] = Vector2(40, 30)
		
		male.approachTargetHandPos(0.5*delta if outOfReach else delta)
		male.approachTargetPosX(delta, opponentStartPosX + SEPARATION - 20)
		male.walk(delta)
		male.regen(0.6*delta)
		male.targetHeight = 80 + opponent.pos.y
		male.approachTargetHeight(delta)
		male.targetAbAng = -0.30
		male.approachTargetAbAng(delta)
		
		var separation = (male.pos.x - opponent.pos.x - SEPARATION)/InputController.MIN_SEPARATION
		if separation < 0:
			opponent.approachTargetPosX(delta*1.2*abs(separation), opponentStartPosX)
		
		if (male.handGlobalPos[R] + male.skeleton.handHipOffset[R] - fwristPos).length() < 30:
			isGrab = true
			if !opponent.perform(MGrabArmRRec.new(opponent)):
				done = true
				return
			male.tire(0.5*STAMINA)
			setZOrder()
			male.face.setOpen(-0.28)
			opponent.perform(MGrabArmRRec.new(opponent))
			male.get_node("polygons/ArmR/HandR_grab_armr").set_visible(true)
			male.get_node("polygons/ArmR/HandR").set_visible(false)
			var zindex = opponent.get_node("polygons/ArmR").z_index + opponent.get_node("polygons/ArmR/ForearmR").z_index
			male.get_node("polygons/ArmR/HandR_grab_armr").z_index = zindex + 3
		
	else: #isGrab
		grabTime += delta
		
		male.handGlobalPos[R] = fwristPos - male.skeleton.handHipOffset[R]
		
		var farmAng = opponent.skeleton.forearmAbsAngle[R]
		male.handAngles[R] = farmAng - male.skeleton.forearmAbsAngle[R] + 2.25
		opponent.targetRelHandPos[R] = Vector2(180, -68 + 0.06*male.pos.y - 0.7*opponent.pos.y) + grabOffset
		
		if grabTime > 0.3:
			opponent.setIsTurn(true)
		
		if grabTime > 0.7 && isStart:
			isStart = false
			male.setZOrder([-2,-6,-1,3,4])
			opponent.setZOrder([-5,-4,0,5,2])
		
		if isStart:
			male.walk(delta)
		else:
			subactTime += delta
			if subact == TEAR:
				tear(subactTime, delta)
			elif subact == FEEL:
				feel(subactTime, delta)
			elif subact == PUNCH_GUT:
				puchGut(subactTime, delta)
			elif subact == STOP_GRAB:
				stopGrab(subactTime, delta)
		
		if subact < 0:
			var targetPosX = opponentStartPosX + SEPARATION
			var dpos = male.pos.x - targetPosX
			var moveRateX = 1.2 + pow(dpos/100, 2)
			male.approachTargetPosX(moveRateX*delta, targetPosX)
			male.pushAway(delta, opponent.pos.x + 250)
			
			var dposF = opponent.pos.x - opponentStartPosX
			var moveRateXF = 1.2 + pow(dposF/100, 2)
			opponent.approachTargetPosX(moveRateXF*delta, opponentStartPosX)
			
			male.targetHeight = 40 + opponent.pos.y
			var dheight = male.pos.y - male.targetHeight
			var moveRateY = 1.0 + pow(dheight/50, 2)
			male.approachTargetHeight(moveRateY*delta)
			
			male.targetAbAng = 0.0
			male.approachTargetAbAng(delta)
			
			male.targetRelHandPos[L] = Vector2(40, 30)
			male.approachTargetHandPos(delta)
			
			male.regen(delta)
			
	
	if subact != STOP_GRAB:
		opponent.walkThresh(delta, 30)
		male.walkThresh(delta, 40)


func startSubaction(actType):
	var stamina = SUBACT_STAMINA[actType]
	if male.stamina < stamina && stamina > 0:
		return false
	if time < SUBACT_DELAY:
		return false
	if actType == TEAR:
		if !opponent.hasBottom || subact >= 0 || time < 0.2:
			return false
	elif actType == FEEL:
		if opponent.hasBottom || subact >= 0 || time < 0.2:
			return false
	elif actType == PUNCH_GUT:
		if subact >= 0:
			return false
		punchDelivered = false
	elif actType == STOP_GRAB:
		if subact >= 0 && subact != FEEL:
			return false
		male.gruntSounds.playRandomDb(-6)
	
	male.tire(SUBACT_STAMINA[actType])
	stopSubaction()
	subact = actType
	subactTime = 0
	soundTrigger = false
	
	return true


func stopSubaction():
	male.setHandLMode(MConst.HANDL_OPEN)
	male.setIsTurn(false)
	male.targetGlobalHandPos[L] = null
	subact = -1


const TEAR_REACH_TIME = 0.6
const TEAR_TEAR1_TIME = 0.5
const TEAR_RETURN_TIME = 0.2
const TEAR_TEAR2_TIME = 0.2
const TEAR_POS = Vector2(78, -73)
const TEAR_PULL_SHIFT = Vector2(12, 0)
func tear(time, delta):
	male.targetHeight = 130
	male.approachTargetHeight(delta)
	male.targetAbAng = -0.06
	male.approachTargetAbAng(delta)
	male.approachTargetPosX(delta, opponentStartPosX + SEPARATION)
	
	grabOffset = Vector2(0, 0.0*male.pos.y)
	
	if time < TEAR_REACH_TIME:
		male.targetGlobalHandPos[L] = male.handFemalePos(L) + TEAR_POS
		male.approachTargetHandPos(delta)
		var diff = male.targetGlobalHandPos[L] - male.handGlobalPos[L]
		if diff.length_squared() < 100:
			male.setHandLMode(MConst.HANDL_GRAB_CLOTH)
		if time > 0.1:
			male.setIsTurn(true)
	elif time < TEAR_REACH_TIME + TEAR_TEAR1_TIME:
		male.targetGlobalHandPos[L] = male.handFemalePos(L) + TEAR_POS + TEAR_PULL_SHIFT
		male.approachTargetHandPos(delta)
		opponent.approachTargetPosX(delta, opponentStartPosX + TEAR_PULL_SHIFT.x)
		if !soundTrigger:
			soundTrigger = true
			male.owner.tearSounds.playRandom()
	elif time < TEAR_REACH_TIME + TEAR_TEAR1_TIME + TEAR_RETURN_TIME:
		male.targetGlobalHandPos[L] = male.handFemalePos(L) + TEAR_POS
		male.approachTargetHandPos(delta)
		opponent.approachTargetPosX(delta, opponentStartPosX)
		soundTrigger = false
	elif time < TEAR_REACH_TIME + TEAR_TEAR1_TIME + TEAR_RETURN_TIME + TEAR_TEAR2_TIME:
		var dt = time - (TEAR_REACH_TIME + TEAR_TEAR1_TIME + TEAR_RETURN_TIME)
		male.targetGlobalHandPos[L] = male.handFemalePos(L) + TEAR_POS + Vector2(30, 0)
		male.approachTargetHandPos(delta)
		opponent.approachTargetPosX(delta, opponentStartPosX + 10)
		if !soundTrigger:
			soundTrigger = true
			male.owner.tearSounds.playRandom()
		if dt > 0.1:
			opponent.removeBottom()
	else:
		stopSubaction()
		opponent.hitSounds.playRandom()
		opponent.setLegsClosing(true)
		opponent.face.setPain(0)
		opponent.targetAbAng = 0.12
		


const FEEL_POS = Vector2(60, 19)
const FEEL_REACH_TIME = 0.7
const FEEL_FEEL_TIME = 10.0
const FEEL_END_TIME = 0.5
const FEEL_HAND_ANG = 0.3
func feel(time, delta):
	male.targetHeight = 175
	male.approachTargetHeight(delta)
	male.targetAbAng = -0.1
	male.approachTargetAbAng(delta)
	male.approachTargetPosX(delta, opponentStartPosX + SEPARATION + 20)
	opponent.approachTargetPosX(1.3*delta, opponentStartPosX)
	
	grabOffset = Vector2(0, 0.28*male.pos.y)
	
	if time < FEEL_REACH_TIME:
		var amt = time/FEEL_REACH_TIME
		male.targetGlobalHandPos[L] = male.handFemalePos(L) + FEEL_POS
		male.approachTargetHandPos(delta)
		if time > 0.1:
			male.setIsTurn(true)
		if time > 0.3:
			male.setHandLMode(MConst.HANDL_FEEL)
		male.handAngles[L] = amt*FEEL_HAND_ANG
	elif time < FEEL_REACH_TIME + FEEL_FEEL_TIME:
		var dt = time - FEEL_REACH_TIME
		var cycle = fmod(dt, 2.0)
		
		var handMove = Vector2.ZERO
		if cycle < 1.4:
			handMove = (1 - pow(cos(PI*cycle/1.4), 4))*Vector2(-8, -2)
		male.handGlobalPos[L] = male.handFemalePos(L) + FEEL_POS + handMove
		
		if cycle < 0.1 && soundTrigger:
			soundTrigger = false
		if cycle > 0.5 && !soundTrigger:
			soundTrigger = true
			opponent.action.recFeel(true)
			felt = true
		if cycle > 0.9:
			opponent.action.recFeel(false)
			opponent.targetHeight = 0
	
	elif time < FEEL_REACH_TIME + FEEL_FEEL_TIME + FEEL_END_TIME:
		var dt = time - (FEEL_REACH_TIME + FEEL_FEEL_TIME)
		var amt = dt/FEEL_END_TIME
		male.handAngles[L] = (1-amt)*FEEL_HAND_ANG
		male.targetGlobalHandPos[L] = null
		male.approachTargetHandPos(0.4*delta)
		male.targetHeight = 80
	else:
		male.targetHeight = 80
		stopSubaction()
	
	if time > FEEL_REACH_TIME + 0.3:
		opponent.targetAbAng = 0.24


const PUNCH_START_POS = Vector2(400, -160)
const PUNCH_PUNCH_POS = Vector2(50, -80)
const PUNCH_START_TIME = 0.20
const PUNCH_PUNCH_TIME = 0.12
const PUNCH_STILL_TIME = 0.1
const PUNCH_END_TIME = 0.15
func puchGut(time, delta):
	male.targetHeight = 60
	male.approachTargetHeight(delta)
	male.approachTargetPosX(delta, opponentStartPosX + SEPARATION)
	opponent.approachTargetPosX(1.3*delta, opponentStartPosX)
	
	if time < PUNCH_START_TIME:
		male.targetGlobalHandPos[L] = male.handFemalePos(L) + PUNCH_START_POS
		male.approachTargetHandPos(delta)
		punchStartPos = male.handGlobalPos[L]
	elif time < PUNCH_START_TIME + PUNCH_PUNCH_TIME:
		var dt = time - PUNCH_START_TIME
		var amt = dt/PUNCH_PUNCH_TIME
		amt = 0.2*amt + 0.8*amt*amt
		male.handGlobalPos[L] = (1-amt)*punchStartPos + amt*(male.handFemalePos(L) + PUNCH_PUNCH_POS)
		if dt > 0.1:
			male.setIsTurn(true)
			male.setHandLMode(MConst.HANDL_FIST)
	elif time < PUNCH_START_TIME + PUNCH_PUNCH_TIME + PUNCH_STILL_TIME:
		if !punchDelivered:
			punchDelivered = true
			opponent.recPunchGut()
	elif time < PUNCH_START_TIME + PUNCH_PUNCH_TIME + PUNCH_STILL_TIME + PUNCH_END_TIME:
		male.targetGlobalHandPos[L] = null
		male.approachTargetHandPos(delta)
	else:
		stopSubaction()


const STOP_TIME = 0.32
func stopGrab(time, delta):
	var ratio = time/STOP_TIME
	var ratio2 = ratio*ratio
	
	var pushAmt = 0.4*ratio + 0.6*ratio2
	grabOffset = pushAmt*Vector2(-160, 0)
	
	male.targetHeight = 40 + 0.5*opponent.pos.y
	male.approachTargetHeight(delta)
	male.targetAbAng = -0.2*ratio
	male.approachTargetAbAng(delta)
	
	opponent.targetSpeed = -1.5*opponent.walkSpeed
	opponent.approachTargetSpeed(1.7*delta)
	opponent.walk(delta)
	opponent.targetAbAng = -0.08
	
	if ratio > 0.95:
		done = true
		opponent.action.done = true
		if felt:
			opponent.perform(FRecoil.new(opponent))


func setZOrder():
	male.setZOrder([-2,-6,0,3,4])
	opponent.setZOrder([-5,-4,-3,5,2])


func stop():
	stopSubaction()
	male.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
	male.targetGlobalHandPos = [null, null]
	male.get_node("polygons/ArmR/HandR_grab_armr").set_visible(false)
	male.get_node("polygons/ArmR/HandR").set_visible(true)
	male.setIsTurn(false)



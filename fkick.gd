extends Action
class_name FKick

func get_class():
	return "FKick"


const FRONT = 1
const HIGH = 2
const KNEE = 3

const LEN0 = 1.0
const HIGHLEN = 1.10

const INITLEN = 0.11*LEN0
const LIFTLEN = 0.19*LEN0
const TURNLEN = 0.09*LEN0
const IMPACTLEN0 = 0.23*LEN0
const UNTURNLEN = 0.17*LEN0
const FINISHLEN = 0.21*LEN0

const ACCELLEN = INITLEN + LIFTLEN + TURNLEN

const STAMINA = 0.4
const RANGE = 1040
const KNEE_RANGE = 660
const TELEPORT_DIST = 180
const HIPDIST = 0.18*RANGE
const FRONT_LIFT = 305
const KNEE_LIFT = 70
const FRONT_MISS_LIFT = 320
const KNEE_MISS_LIFT = 190
const BLOCK_LIFT = 20
const HIT_LIFT = 70
const TELEPORT_LIFT = 30
const HIPLIFT = 45
const BODY_ROT = 9*PI/180
const BODY_ROT_HIGH = 18*PI/180
const BODY_ROT_KNEE = 2*PI/180
const BASE_ROT = 17*PI/180
const BASE_START = -10*PI/180
const HIGH_BASE_ROT = 21*PI/180
const HIGH_LIFT = 200
const HIGH_START_DIST = 760
const HIGH_RANGE = 1020
const HIGH_KICK_ANGLE = -33*PI/180
const HIGH_KICK_VECT = (HIGH_RANGE - HIGH_START_DIST)*Vector2(cos(HIGH_KICK_ANGLE), sin(HIGH_KICK_ANGLE))
const MALE_HEAD_KICK_HEIGHT = 95
const MIN_SEPARATION = 515
const MIN_SEPARATION_HIGH = 640
const ABORT_RANGE = 420
const ABORT_RANGE_HIGH = 650
const MAX_KNEE_RANGE = 525


var female
var opponent
var turnSkeleton : FKickSkeleton
var isTurn
var isImpact
var isBlock
var isPenImpact
var isHighImpact
var type
var impactLen
var length
var liftR
var accelLift
var soundTrigger
var isUnhigh
var isTooClose
var impactShiftR


func _init(femaleIn, isHighIn).(female):
	female = femaleIn
	opponent = female.opponent
	type = HIGH if isHighIn else FRONT
	turnSkeleton = female.get_node("Skeleton2D_turn")
	isImpact = null
	isBlock = null
	isPenImpact = false
	isHighImpact = null
	isTooClose = null
	isUnhigh = !(type == HIGH)
	impactLen = IMPACTLEN0
	length = LEN0
	if type == HIGH:
		length = HIGHLEN
		impactLen += HIGHLEN - LEN0
	soundTrigger = false


func canStop():
	return !isTurn

func isDone():
	return time > length


func start():
	female.tire(0.5*STAMINA)
	isTurn = false
	female.pos.y = 0
	turnSkeleton.head.set_rotation(0)
	setZOrder()
	female.setHandLMode(FConst.HANDL_OPEN)


func perform(time, delta):
	var shiftHip
	var liftHip
	var shiftR
	var handShiftR = 0
	var handShiftL = 0
	var thighScale = 1
	var calfScale = 1
	
	female.targetHeight = 0
	female.slideFeet(delta, 0, 0)
	
	var closeness = max(0, 1 - getRange()/150)
	var hipDist = HIPDIST - 10*closeness
	
	if type == KNEE:
		accelLift = KNEE_LIFT + 0.8*min(0, opponent.pos.x - female.slidePos.x - MAX_KNEE_RANGE)
	else:
		accelLift = FRONT_LIFT
	var missLift = KNEE_MISS_LIFT if type == KNEE else FRONT_MISS_LIFT
	
	if time > INITLEN + LIFTLEN && isTooClose == null:
		isTooClose = checkTooClose()
		if !isTooClose && type == FRONT && checkKnee():
			type = KNEE
		if !isTooClose:
			female.tire(0.5*STAMINA)
	if isTooClose:
		var dt = time - (INITLEN + LIFTLEN)
		var ratio = (1 - dt/FINISHLEN)*0.5
		shiftR = (RANGE - TELEPORT_DIST)*ratio
		liftR = (accelLift - TELEPORT_LIFT)*ratio
		shiftHip = hipDist*ratio
		liftHip = HIPLIFT*ratio
		female.setIsTurn(false)
		length = INITLEN + LIFTLEN + FINISHLEN
	else:
		
		if time < INITLEN:
			liftR = 0
			shiftR = 0
		else:
			var footExtend = (time - INITLEN)/(LIFTLEN + TURNLEN + 0.10*impactLen)
			var footRetract = (time - ACCELLEN - 0.83*impactLen)/(0.17*impactLen + UNTURNLEN + FINISHLEN)
			var footRatio = min(1, footExtend) - max(0, footRetract)
			if type != HIGH && footExtend < 1:
				footRatio = 0.2*footRatio + 0.8*pow(0.5*(1 - cos(footRatio*PI)), 2)
			else:
				footRatio = 0.2*footRatio + 0.8*0.5*(1 - cos(footRatio*PI))
			var reach
			if type == HIGH:
				reach = HIGH_START_DIST
			elif type == FRONT:
				reach = RANGE*clamp(1 + (opponent.pos.x - female.pos.x - 750)/800, 0.9, 1)
			else:
				reach = KNEE_RANGE
			shiftR = (reach - TELEPORT_DIST)*footRatio
			if time > INITLEN + LIFTLEN && time < ACCELLEN + impactLen + UNTURNLEN:
				shiftR += TELEPORT_DIST
			
			if type == FRONT:
				if isImpact && impactShiftR == null:
					impactShiftR = shiftR
				if isImpact && shiftR > impactShiftR:
					shiftR = impactShiftR + 0.30*(shiftR - impactShiftR)
				if !isImpact && !isBlock && time > ACCELLEN && time < ACCELLEN + impactLen:
					var ratio = (time - ACCELLEN)/impactLen
					shiftR -= 50*0.5*(1 - cos(ratio*2*PI))
		
		if time < ACCELLEN:
			var ratio = time/ACCELLEN
			var hipMove = 0.5*(1 - cos(0.5*ratio*2*PI))
			shiftHip = hipDist*hipMove
			liftHip = HIPLIFT*hipMove
			if time > INITLEN:
				liftR = (accelLift - TELEPORT_LIFT)*pow((time - INITLEN)/(LIFTLEN + TURNLEN), 4)
				if !female.isTurn && time > INITLEN + 0.08:
					female.setIsTurn(true)
					female.game.swingSounds.playRandomDb(4)
				if time > INITLEN + LIFTLEN:
					liftR += TELEPORT_LIFT
			
		elif time < ACCELLEN + impactLen:
			var ratio = (time - ACCELLEN)/impactLen
			shiftHip = hipDist
			liftHip = HIPLIFT
			
			if type == HIGH:
				var liftFact = pow(0.5*(1 - cos(ratio*2*PI)), 0.25)
				liftR = accelLift + HIGH_LIFT*liftFact
				if isImpact == null && time > ACCELLEN + 0.5*impactLen:
					isImpact = checkHighImpact()
					if isImpact:
						if !opponent.perform(FKickHighRec.new(opponent)):
							if opponent.pos.y > MALE_HEAD_KICK_HEIGHT:
								opponent.recHitHead()
			elif type == FRONT || type == KNEE:
				var liftFact = pow(0.5*(1 - cos(ratio*2*PI)), 0.5)
				if isImpact == null:
					isBlock = checkBallBlock()
					if isBlock:
						isImpact = false
						opponent.recBlockedKick()
					else:
						isImpact = checkBallImpact()
						if isImpact:
							if !opponent.perform(FKickRec.new(opponent, self)):
								if opponent.pos.y > MALE_HEAD_KICK_HEIGHT:
									opponent.recHitHead()
							else:
								setZOrder()
						else:
							isPenImpact = checkPenImpact()
							var speedup = -0.1*IMPACTLEN0
							impactLen -= speedup
							length -= speedup
							if isPenImpact:
								opponent.recPenHit()
								female.game.clapSounds.playRandomDb(0)
				
				if isBlock:
					liftR = accelLift + BLOCK_LIFT*liftFact
				elif isImpact:
					liftR = accelLift + HIT_LIFT*liftFact
				else:
					liftR = accelLift + missLift*liftFact
					if isHighImpact == null && liftFact > 0.9 && opponent.pos.y > MALE_HEAD_KICK_HEIGHT:
						isHighImpact = checkHeadImpact()
						if isHighImpact:
							opponent.recHitHead()
				
		else:
			var dt = time - (ACCELLEN + impactLen)
			var ratio = dt/(UNTURNLEN + FINISHLEN)
			var hipRatio = max(0, (ratio - 0.3)/0.7)
			var hipMove = 0.5*(1 + cos(0.5*hipRatio*2*PI))
			shiftHip = hipDist*hipMove
			liftHip = HIPLIFT*hipMove
			liftR = (accelLift - TELEPORT_LIFT)*(1 - ratio)
			if dt < UNTURNLEN:
				liftR += TELEPORT_LIFT - 0.70*ratio*accelLift
			if dt > UNTURNLEN + 0.045:
				female.setIsTurn(false)
		
	if time < ACCELLEN:
		handShiftR = 3.3*shiftHip - 0.02*shiftHip*shiftHip
	
	handShiftL = -0.3*shiftHip
	
	female.pos.x = female.slidePos.x + shiftHip
	female.pos.y = -liftHip
	female.footGlobalPos[R] = Vector2(female.slidePos.x + shiftR, -liftR)
	female.handGlobalPos = [female.pos + Vector2.RIGHT*handShiftL, female.pos + Vector2.RIGHT*handShiftR]
	
	if time > INITLEN + LIFTLEN:
		if time > length - FINISHLEN:
			if isTurn:
				isTurn = false
				female.get_node("polygons").set_visible(true)
				female.get_node("polygons_turn").set_visible(false)
		else:
			if !isTurn:
				isTurn = true
				female.get_node("polygons").set_visible(false)
				var poly = female.get_node("polygons_turn")
				poly.set_visible(true)
				poly.z_index = opponent.get_node("polygons/Body").z_index
				poly.get_node("CalfR_high/FootR_high").z_index = Utility.getAbsZIndex(opponent.get_node("polygons/LegL/ClothF2"))
				poly.get_node("CalfR").set_visible(type != HIGH)
				poly.get_node("FootR").set_visible(type != HIGH)
				poly.get_node("CalfR_high").set_visible(type == HIGH)
		if type == HIGH && !isUnhigh && time > ACCELLEN + impactLen + 0.13:
			isUnhigh = true
			var poly = female.get_node("polygons_turn")
			poly.get_node("CalfR").set_visible(true)
			poly.get_node("FootR").set_visible(true)
			poly.get_node("CalfR_high").set_visible(false)
	
	if type == HIGH:
		var highKickAmt = clamp((time - ACCELLEN + 0.02)/(0.45*impactLen), 0, 1)
		var highKickAmt2 = highKickAmt*highKickAmt
		highKickAmt = 0.1*highKickAmt + 1.9*highKickAmt2 - 0.7*highKickAmt2*highKickAmt2
		var kickVect = HIGH_KICK_VECT*highKickAmt
		var shrinkAmt = (1-highKickAmt)*liftR/(FRONT_LIFT + HIGH_LIFT)
		thighScale = 1 - 0.18*shrinkAmt
		calfScale = 1 - 0.3*shrinkAmt
		shiftR += kickVect.x
		liftR -= kickVect.y
	
	if isTurn:
		if type == HIGH:
			female.slidePos.x = Utility.approach1D(female.slidePos.x, min(female.slidePos.x, opponent.pos.x - MIN_SEPARATION_HIGH), 160*delta)
		else:
			female.slidePos.x = min(female.slidePos.x, opponent.pos.x - MIN_SEPARATION)
		var ratio = (time - INITLEN - LIFTLEN)/(TURNLEN + impactLen + UNTURNLEN)
		var bodyMove = pow(sin(ratio*PI), 0.5) #0.5*(1 - cos(ratio*2*PI))
		var hipRot = -bodyMove*(BODY_ROT_HIGH if type == HIGH else (BODY_ROT_KNEE if type == KNEE else BODY_ROT))
		var maxBodyRot = HIGH_BASE_ROT if type == HIGH else BASE_ROT
		var baseRot = BASE_START + (1 - 0.65*closeness)*bodyMove*maxBodyRot
		var footDelta = female.slidePos + female.skeleton.footBasePos[R] - \
					(female.footGlobalPos[L] + female.skeleton.footBasePos[L])
		turnSkeleton.footL.position = female.pos + female.skeleton.footPos[L] + Vector2(-47, -25)
		turnSkeleton.setConfig(Vector2(shiftR, -liftR) + footDelta, baseRot, hipRot, thighScale, calfScale)
		if !female.hasTop:
			var breastAmt = 1.1*max(0, ratio - 0.1)
			var breastAmt2 = breastAmt*breastAmt
			var breastAmt4 = breastAmt2*breastAmt2
			breastAmt = (1.5*breastAmt2 - 6.0*breastAmt4)*exp(-8*breastAmt2)
			turnSkeleton.setBreastPos(breastAmt/0.04*Vector2(-5, -30))
		turnSkeleton.armL.position = bodyMove*Vector2(-12, 0)
	else:
		var ratio = time/length
		var bodyMove = 0.5*(1 - cos(ratio*2*PI))
		var bodyRot = -bodyMove*(20 if type == HIGH else 10)*PI/180
		female.skeleton.abdomen.set_rotation(bodyRot)
	
	var hairAmt = (time - INITLEN - LIFTLEN - 0.08)
	hairAmt = hairAmt/0.29 - 1
	hairAmt = 1 - hairAmt*hairAmt
	turnSkeleton.hair.set_rotation(0.3 + 0.7*hairAmt)
	
	if time < INITLEN + LIFTLEN + 0.5:
		female.skeleton.hairB1.vel.x -= delta*500;
		female.skeleton.hairB2.vel.x -= delta*800;
		female.skeleton.hairB3.vel.x -= delta*1100;
	
	if !soundTrigger && time > 0.0:
		soundTrigger = true
		female.gruntSounds.playRandom()
	


func stop():
	female.setIsTurn(false)


func getRange():
	var stopDist = female.vel.x*abs(female.vel.x)/(4*female.getAccel())
	var femX = female.pos.x + stopDist
	var targetX = opponent.pos.x
	return targetX - femX - (MIN_SEPARATION_HIGH if type == HIGH else MIN_SEPARATION)


func checkBallBlock():
	if !opponent.isBlockingLow():
		return false
	var toeX = turnSkeleton.toeR.get_global_position().x
	var targetX = opponent.skeleton.hip.get_global_position().x
	return toeX > targetX - 115


func checkBallImpact():
	if opponent.isRecoiling() || opponent.pos.y > 80:
		return false
	var targetX = opponent.skeleton.hip.get_global_position().x
	if type == FRONT:
		var toeX = turnSkeleton.toeR.get_global_position().x
		return toeX > targetX - 57
	else:
		var kneeX = turnSkeleton.calfR.get_global_position().x
		return kneeX > targetX - 50


func checkPenImpact():
	if opponent.isRecoiling() || opponent.pos.y > 80:
		return false
	var targetX = opponent.pen2.get_global_position().x
	if type == FRONT:
		var toeX = turnSkeleton.toeR.get_global_position().x
		return toeX > targetX - 105
	else:
		var kneeX = turnSkeleton.calfR.get_global_position().x
		return kneeX > targetX - 88


func checkKnee():
	var stopDist = female.vel.x*abs(female.vel.x)/(4*female.getAccel())
	var femX = female.skeleton.hip.get_global_position().x + stopDist
	var targetX = opponent.skeleton.hip.get_global_position().x
	return femX > targetX - MAX_KNEE_RANGE


func checkTooClose():
	return getRange() < ABORT_RANGE-MIN_SEPARATION


func checkHighImpact():
	var toeX = turnSkeleton.toeR.get_global_position().x
	var targetX = opponent.skeleton.torso.get_global_position().x
	return toeX > targetX + 5


func checkHeadImpact():
	var toeX = turnSkeleton.toeR.get_global_position().x
	var targetX = opponent.skeleton.torso.get_global_position().x
	return toeX > targetX - 15


func setZOrder():
	female.setDefaultZOrder()
	if opponent.isActive && !opponent.isRecoiling():
		opponent.setDefaultZOrder()


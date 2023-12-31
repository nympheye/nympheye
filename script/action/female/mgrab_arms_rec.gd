extends Action
class_name MGrabArmsRec

func get_class():
	return "MGrabArmsRec"


const RUB = 0
const PEN = 1
const DEEP = 2

const KICK_STAMINA = 0.5
const KICK_SHIFT_TIME = 0.75
const KICK_START_TIME = 0.55
const KICK_KICK_TIME = 0.22
const KICK_IMPACT_TIME = 0.18
const KICK_END_TIME = 0.25
const KICK_SHIFT = Vector2(-145, -170)
const KICK_START_FOOT_POS = Vector2(-10, -170)
const KICK_START_THIGH_SCALE = 1.25
const KICK_START_CALF_SCALE = 1.0
const KICK_KICK_FOOT_POS = Vector2(150, -290)
const KICK_IMPACT_FOOT_POS = KICK_KICK_FOOT_POS + Vector2(1, -10)
const KICK_KICK_THIGH_SCALE = 1.25
const KICK_KICK_CALF_SCALE = 0.70
const KICK_END_THIGH_SCALE = 1.05
const KICK_END_CALF_SCALE = 1.0
const FSHIFT_LEFT_SLACK = 10
const FSHIFT_RIGHT_SLACK = 10
const MIN_SEPARATION = 86
const MAX_SEPARATION = 215


var female
var opponent
var done
var startPos
var basePosX
var kickTime
var releaseTime
var kickStartPos
var kickFootRStartPos
var isFootKick
var kickStartThighScale
var kickStartCalfScale
var doneKick

var grabPen
var reaction
var reactionTimer
var isPen
var isDeep
var prevContactAng
var contactAngSpeed
var soundTrigger


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	done = false
	kickTime = 0
	releaseTime = 0
	isFootKick = false
	startPos = female.pos
	basePosX = female.pos.x
	reaction = -1
	reactionTimer = [99999, 99999, 99999]
	isPen = false
	isDeep = false
	grabPen = false
	prevContactAng = 0
	contactAngSpeed = 0
	soundTrigger = false
	doneKick = false
	female.setZOrder([-7,-6,-1,4,5])
	female.isIgnoringMapLimit = true
	female.setDefaultHandRMode()
	
	female.tire(min(female.stamina - 0.15, 0.55))
	female.stamina = max(female.stamina, -0.1)


func canStop():
	return done

func isDone():
	return done


func perform(time, delta):
	female.breathe(delta, true)
	female.regen(0.23*delta)
	female.footAngles = female.getFootAngles(female.skeleton.footPos)
	
	if time < 0.6:
		female.targetSpeed = -female.walkSpeed
		female.walk(delta)
	elif time < 0.8 && female.vel.x < 0:
		female.vel.x += 3*delta*female.getAccel()
		
	
	var footLShift = female.pos.x - female.footGlobalPos[L].x
	female.legScale[L] = [1.0 - 0.0007*footLShift, 1.0 - 0.0003*footLShift]
	female.footAngles[L] -= 0.0015*footLShift
	
	var footRShift = female.footGlobalPos[R].x - female.pos.x
	female.legScale[R] = [1.0 - 0.0012*footRShift, 1.0]
	
	if kickTime <= 0 || doneKick:
		var lift = max(0, -female.handGlobalPos[L].y - 300)
		
		if lift > 10 && !soundTrigger:
			soundTrigger = true
			female.hitSounds.playRandomDb(-4)
			female.face.setPain(0)
		
		if lift > 40 || time > 2.0:
			var handPosX = 70 + 0.5*(female.handGlobalPos[L].x + female.handGlobalPos[R].x)
			var dx = handPosX-basePosX
			var targetPosX = basePosX
			var dxMag
			if dx > 0:
				dxMag = abs(dx)/FSHIFT_RIGHT_SLACK
				targetPosX += FSHIFT_RIGHT_SLACK*pow(dxMag, 2)
			else:
				dxMag = abs(dx)/FSHIFT_LEFT_SLACK
				targetPosX -= FSHIFT_LEFT_SLACK*pow(dxMag, 2)
			basePosX += basePosX + dxMag*delta*female.vel.x
			basePosX -= 0.3*opponent.vel.x
			basePosX = clamp(basePosX, handPosX-FSHIFT_RIGHT_SLACK, handPosX+FSHIFT_LEFT_SLACK)
			targetPosX = clamp(targetPosX, handPosX-FSHIFT_RIGHT_SLACK, handPosX+FSHIFT_LEFT_SLACK)
			targetPosX = min(targetPosX, opponent.pos.x - 84)
			targetPosX -= releaseTime*150
			var shiftSpeed = 0.2 + 0.4*dxMag*dxMag
			if releaseTime > 0:
				shiftSpeed *= 8
			female.approachTargetPosX(shiftSpeed*delta, targetPosX) 
			female.pos.x = clamp(female.pos.x, targetPosX-40, targetPosX+40)
			female.pos.x = clamp(female.pos.x, opponent.pos.x-MAX_SEPARATION, opponent.pos.x-MIN_SEPARATION)
			female.targetAbAng = 0.004*(handPosX - female.pos.x)
			female.approachTargetAbAng(0.6*delta)
			
			if releaseTime <= 0:
				female.footGlobalPos[L] = Utility.approach2D( \
						female.footGlobalPos[L], startPos + Vector2(-170, -10), delta*400.0)
				if female.isLegROpen:
					female.footGlobalPos[R] = Vector2(0.5*opponent.pos.x + 0.5*female.pos.x + 150, \
													0.3*opponent.pos.y + 0.7*female.pos.y - 75)
				else:
					female.footGlobalPos[R] = Utility.approach2D( \
							female.footGlobalPos[R], female.pos + Vector2(150, 0), delta*250.0)
			else:
				for i in [L,R]:
					female.footGlobalPos[i] = Utility.approach2D( \
							female.footGlobalPos[i], female.pos, delta*500.0)
			
			if female.isLegROpen:
				var dpos = female.pos - opponent.pos
				var thighRAngle = atan2(-dpos.y - 80, -70) - 0.2
				kickStartThighScale = 1 - 0.6*(thighRAngle - 1.8)
				kickStartCalfScale = 1.0
				female.skeleton.placeLegROpen(female.footGlobalPos[R], kickStartThighScale, kickStartCalfScale, 1.0)
			else:
				if footRShift > 100:
					female.setLegROpen(true)
		
		female.pos.y = -lift
		
		var handSpeed = 2.0 if doneKick else (0.2 if opponent.isPerforming("MGrabArmsPen") else 0.6)
		female.approachTargetHandPos(delta*handSpeed)
		
	else:
		
		kickTime += delta
		
		var shiftAmt = min(1, kickTime/KICK_SHIFT_TIME)
		if shiftAmt < 1:
			var shiftAmt2 = shiftAmt*shiftAmt
			var shiftAmt3 = shiftAmt2*shiftAmt
			var shiftAmt4 = shiftAmt3*shiftAmt
			var shiftAmt8 = shiftAmt4*shiftAmt4
			var shiftAmtX = -0.2*shiftAmt + 2.3*shiftAmt4 - 1.1*shiftAmt8
			var shiftAmtY = -0.6*shiftAmt - 0.8*shiftAmt2 + 7.2*shiftAmt3 - 4.8*shiftAmt4
			var shift = Vector2(shiftAmtX*(-kickStartPos.x + (opponent.pos.x + KICK_SHIFT.x)), \
								shiftAmtY*(-kickStartPos.y + (opponent.pos.y + KICK_SHIFT.y)))
			female.pos = kickStartPos + shift
			for i in [L,R]:
				female.handGlobalPos[i] = female.targetGlobalHandPos[i] + shift
		
		var calfScale
		var thighScale
		var footScale = 1.0
		
		if kickTime < KICK_START_TIME:
			var amt = kickTime/KICK_START_TIME
			var amt2 = amt*amt
			var amt3 = amt2*amt
			var amt4 = amt3*amt
			
			var kickAmtX = 0.3*amt + 1.6*amt2 - 0.9*amt4
			var kickAmtY = -0.6*amt - 0.8*amt2 + 7.2*amt3 - 4.8*amt4
			
			female.footGlobalPos[R] = opponent.pos + Vector2( \
					(1-kickAmtX)*kickFootRStartPos.x + kickAmtX*KICK_START_FOOT_POS.x, \
					(1-kickAmtY)*kickFootRStartPos.y + kickAmtY*KICK_START_FOOT_POS.y)
			thighScale = (1-amt)*kickStartThighScale + amt*KICK_START_THIGH_SCALE
			calfScale = (1-kickAmtY)*kickStartCalfScale + kickAmtY*KICK_START_CALF_SCALE
		
		elif kickTime < KICK_START_TIME + KICK_KICK_TIME:
			var amt = (kickTime - KICK_START_TIME)/KICK_KICK_TIME
			
			if amt > 0.5 && !isFootKick:
				isFootKick = true
				female.gruntSounds.play(4)
				female.get_node("polygons/LegR/CalfR_open").set_visible(false)
				female.get_node("polygons/LegR/CalfR_open_kick").set_visible(true)
				female.get_node("polygons/LegR/CalfR_open_kick/CalfR_open_kick_foot").z_index = \
						Utility.getAbsZIndex(opponent.get_node("polygons/Back/Body")) - 1
				female.owner.swingSounds.play(2)
			
			var footX = 0.2*amt + 0.8*0.5*(1 - cos(amt*PI))
			var footY = pow(amt, 2)
			female.footGlobalPos[R] = opponent.pos + KICK_START_FOOT_POS + \
					Vector2(footX*(KICK_KICK_FOOT_POS.x - KICK_START_FOOT_POS.x), footY*(KICK_KICK_FOOT_POS.y - KICK_START_FOOT_POS.y))
			thighScale = (1-amt)*KICK_START_THIGH_SCALE + amt*KICK_KICK_THIGH_SCALE
			calfScale = (1-amt)*KICK_START_CALF_SCALE + amt*KICK_KICK_CALF_SCALE
		
		elif kickTime < KICK_START_TIME + KICK_KICK_TIME + KICK_IMPACT_TIME:
			var amt = (kickTime - KICK_START_TIME - KICK_KICK_TIME)/KICK_IMPACT_TIME
			var amt2 = amt*amt
			var amt4 = amt2*amt2
			
			var footX = amt
			var footY = 8.0*amt - 9.8*amt2 + 2.8*amt4
			female.footGlobalPos[R] = opponent.pos + KICK_KICK_FOOT_POS + \
					Vector2(footX*(KICK_IMPACT_FOOT_POS.x - KICK_KICK_FOOT_POS.x), footY*(KICK_IMPACT_FOOT_POS.y - KICK_KICK_FOOT_POS.y))
			thighScale = KICK_KICK_THIGH_SCALE
			calfScale = KICK_KICK_CALF_SCALE
			
			if opponent.action.kickTime <= 0:
				opponent.action.recKick()
		elif kickTime < KICK_START_TIME + KICK_KICK_TIME + KICK_IMPACT_TIME + KICK_END_TIME:
			var amt = (kickTime - KICK_START_TIME - KICK_KICK_TIME - KICK_IMPACT_TIME)/KICK_END_TIME
			
			if amt > 0.5 && isFootKick:
				isFootKick = false
				female.get_node("polygons/LegR/CalfR_open").set_visible(true)
				female.get_node("polygons/LegR/CalfR_open_kick").set_visible(false)
			
			var footX = amt
			var footY = amt
			female.footGlobalPos[R] = opponent.pos + KICK_IMPACT_FOOT_POS + \
					Vector2(footX*(kickFootRStartPos.x - KICK_IMPACT_FOOT_POS.x), footY*(kickFootRStartPos.y - KICK_IMPACT_FOOT_POS.y))
			thighScale = (1-amt)*KICK_KICK_THIGH_SCALE + amt*KICK_END_THIGH_SCALE
			calfScale = (1-amt)*KICK_KICK_CALF_SCALE + amt*KICK_END_CALF_SCALE
		else:
			thighScale = KICK_END_THIGH_SCALE
			calfScale = KICK_END_CALF_SCALE
			doneKick = true
		
		female.skeleton.placeLegROpen(female.footGlobalPos[R], thighScale, calfScale, footScale)
	
	if grabPen:
		for i in [L,R]:
			female.handVel[i].y = clamp(female.handVel[i].y, -5, 100)
		performReaction(delta)
	
	if releaseTime > 0:
		releaseTime += delta
	
	if done:
		female.perform(FRecoil.new(female))
	


const RUB_THRESH = 0.005
const PEN_THRESH = 0.85
const EXIT_THRESH = 0.4
const DEEP_THRESH = 1.8
const RUB_MINANG = 15*PI/180
const RUB_MAXANG = 65*PI/180
func setPenetration(delta, pen, contactAng, penisAng):
	grabPen = true
	
	contactAngSpeed = (contactAng - prevContactAng)/delta
	prevContactAng = contactAng
	
	if isPen && (pen < EXIT_THRESH || reactionTimer[PEN] > 4.0):
		isPen = false
	if isDeep && (pen < PEN_THRESH || reactionTimer[DEEP] > 4.0):
		isDeep = false
	
	if pen > RUB_THRESH && contactAng > RUB_MINANG && contactAng < RUB_MAXANG:
		if reactionTimer[RUB] > 3.0 && reaction != DEEP && reaction != PEN:
			startReaction(RUB, contactAng, contactAngSpeed, penisAng)
	if !isPen && pen > PEN_THRESH:
		if reactionTimer[PEN] > 1.5 && reaction != DEEP:
			startReaction(PEN, contactAng, contactAngSpeed, penisAng)
	if !isDeep && pen > DEEP_THRESH:
		if reactionTimer[DEEP] > 3.0 && reactionTimer[PEN] > 1.0:
			startReaction(DEEP, contactAng, contactAngSpeed, penisAng)


func startReaction(type, contactAng, contactAngSpeed, penisAng):
	if kickTime > 0:
		return
	
	reactionTimer[type] = 0
	reaction = type
	if type == RUB:
		female.crySounds.playRandom()
		female.targetHeadAng = -0.2
		female.face.setEyesClosed()
		female.recMoraleDamage(0.05)
		female.tire(0.05)
	elif type == PEN:
		isPen = true
		female.crySounds.playRandomDb(3)
		female.targetHeadAng = -0.5
		female.face.setShock(0.1)
		female.recMoraleDamage(0.33)
		female.tire(0.10)
	elif type == DEEP:
		isDeep = true
		female.crySounds.playRandomDb(3)
		female.targetHeadAng = -0.5
		female.face.setShock(-0.1)
		female.recMoraleDamage(0.33)
		female.tire(0.25)


func performReaction(delta):
	if reaction == RUB:
		if reactionTimer[RUB] > 1.0:
			reaction = -1
			female.face.setPain(0)
	elif reaction == PEN:
		if reactionTimer[PEN] > 2.0:
			reaction = -1
			female.face.setPain(0)
	female.approachTargetHeadAng(delta)
	for i in [RUB, PEN, DEEP]:
		reactionTimer[i] += delta


func startKick():
	if female.isLegROpen && kickTime <= 0 && female.getHealth() > 0:
		female.tire(KICK_STAMINA)
		kickTime = 0.01
		kickStartPos = female.pos
		kickFootRStartPos = female.footGlobalPos[R] - opponent.pos
		female.gruntSounds.play(5)
		female.face.setAngry(0.4)


func stop():
	female.stopGrabPart()
	female.setLegsClosing(true)
	female.setIsTurn(false)
	female.setArmsUp(false)
	female.setLegROpen(false)
	female.targetGlobalHandPos = [null, null]
	female.isPunchedGut = false
	female.isIgnoringMapLimit = false



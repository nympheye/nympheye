extends Node2D
class_name Human

func get_class():
	return "Human"

const L = 0
const R = 1
const M = 0
const F = 1

const GRAB_GROIN = 0
const GRAB_FACE = 1

const NECK_ROT_FRAC = 0.8

const BREATH_HEIGHT = 4.5
const BREATH_CHEST_DX = 1.3
const BREATH_CHEST_DY = 0.35
const BREATH_TIME = 0.8

var game : Game
var commandList: CommandList
var input : InputController
var aiPlayer : AIPlayer
var gui : Gui
var options
var skeleton : HumanSkeleton
var face : Face
var shadow : Shadow
var blood : Particles2D
var bloodSpray : BloodSpray
var opponent

var sex
var pos : Vector2
var vel : Vector2
var footGlobalPos : Array
var liftedFoot
var footAngles : Array
var legScale : Array
var armScale : Array
var footVel : Vector2
var footLandTime : Array
var handGlobalPos : Array
var handAngles : Array
var useGlobalHandAngles
var handVel : Array
var abVel
var direction
var breath
var stamina
var action : Action
var targetHeight
var walkHeightShift
var targetSpeed
var targetGlobalHandPos : Array
var targetRelHandPos : Array
var defaultHandPos : Array
var defaultHandPosVertShift : Array
var targetAbAng
var targetHeadAng
var footLandPos
var legsClosedAbAng
var closingLegs
var legsClosedFrac
var grabbingPart
var partGrabFrac
var isGrabbingPart
var freezeLegs
var runningFrac
var isRunning
var targetRunningFrac
var strideCycle
var slideCounter
var slidePos
var pushAwayCounter
var isIgnoringMapLimit
var isAi
var aiDifficulty
var isDefaultZOrder
var isActive
var isSurrender
var bloodParent
var bloodOffset

var walkSpeed
var runSpeed
var walkAccel
var runAccel
var maxLean
var minHeight
var maxHeight
var downHeight
var upHeight
var runHeight
var walkBobHeight
var vertPos
var vertSpeed
var vertAccel
var minPlantDist
var footSpeed
var footRunSpeed
var footAccel
var footRunAccel
var handSpeed
var handAccel
var abSpeed
var abAccel
var walkLift
var minWalkStride : Array
var maxWalkStride : Array
var minRunStride : Array
var maxRunStride : Array
var legCloseRate
var handRotSpeed
var headRotSpeed
var staminaRegenRate
var regenRateMult
var shoulderRad
var minStamina
var minStaminaRegen


func _init(directionIn):
	direction = directionIn
	vel = Vector2(0, 0)
	pos = Vector2(0, 0)
	footGlobalPos = [Vector2(0, 0), Vector2(0, 0)]
	liftedFoot = -1
	footAngles = [0, 0]
	legScale = [null, null]
	armScale = [null, null]
	footVel = Vector2(0, 0)
	footLandTime = [0, 0]
	handGlobalPos = [Vector2(0,0), Vector2(0,0)]
	handVel = [Vector2(0,0), Vector2(0,0)]
	handAngles = [0, 0]
	useGlobalHandAngles = false
	breath = 0
	targetHeight = 0
	walkHeightShift = 0
	targetSpeed = 0
	targetGlobalHandPos = [null, null]
	targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
	defaultHandPos = [Vector2.ZERO, Vector2.ZERO]
	defaultHandPosVertShift = [0.3, 0.3]
	abVel = 0
	targetAbAng = 0
	targetHeadAng = 0
	footLandPos = [0, 0]
	legsClosedAbAng = 0
	closingLegs = false
	legsClosedFrac = 0
	grabbingPart = 0
	isGrabbingPart = false
	partGrabFrac = 0
	freezeLegs = false
	runningFrac = 0
	isRunning = false
	targetRunningFrac = 0
	strideCycle = 0
	slideCounter = 0
	pushAwayCounter = 0
	stamina = 1.0
	isIgnoringMapLimit = false
	isDefaultZOrder = true
	isActive = true
	isSurrender = false


func _ready():
	options = get_node("/root/Options")
	game = get_owner()
	game.options = options
	
	skeleton = get_node("Skeleton2D")
	face = skeleton.head
	face.human = self
	shadow = get_node("Shadow")
	shadow.human = self
	blood = skeleton.get_node("Hip/Blood")
	bloodSpray = get_node("BloodSpray")
	bloodSpray.shaderDisabled = options.shadersDisabled
	minPlantDist = (abs(skeleton.footBasePos[L].x) + abs(skeleton.footBasePos[R].x))/4
	
	isAi = !options.isPlayer[sex]
	aiDifficulty = options.difficulty[sex]
	
	handSpeed = 1200
	handAccel = 10000
	abSpeed = 180*PI/180
	abAccel = 500*PI/180
	legCloseRate = 4.0
	handRotSpeed = 180*PI/180
	headRotSpeed = 60*PI/180
	shoulderRad = 150
	minStamina = 0.55
	regenRateMult = 1.0


func isPerforming(actionClass):
	return action != null && action.get_class() == actionClass


func stopActionClass(actionClass):
	if isPerforming(actionClass):
		stopAction()


func stopAction():
	if action != null && action.canStop():
		var a = action
		action = null
		a.stop()
		a.interrupted()


func perform(newAction):
	stopAction()
	if action == null:
		newAction.start()
		action = newAction
		return true
	return false


func _physics_process(delta):
	
	commandList.step(delta)
	if isAi:
		aiPlayer.actionStep(delta)
	else:
		input.actionStep(commandList)
	
	strideCycle = getStrideCycle()
	runningFrac = clamp((abs(vel.x) - walkSpeed)/(runSpeed - walkSpeed), 0, 1)
	targetRunningFrac = clamp((abs(targetSpeed) - walkSpeed)/(runSpeed - walkSpeed), 0, 1)
	footAngles = getFootAngles(skeleton.footPos)
	legScale = [null, null]
	armScale = [null, null]
	if legsClosedAbAng != 0:
		targetAbAng = legsClosedAbAng
	walkHeightShift = walkHeightShift - max(abs(walkHeightShift), delta*3.0)*sign(walkHeightShift)
	
	updateGrabbingPart(delta)
	
	if action != null:
		action.process(delta)
		if action.isDone():
			var a = action
			action = null
			breath = 0
			a.stop()
	else:
		defaultProcess(delta)
	
	skeleton.setRunningFrac(runningFrac, strideCycle)
	
	stamina = min(getMaxStamina(), stamina)
	
	skeleton.hip.position = pos
	
	skeleton.place_legs(footGlobalPos, footAngles, legScale)
	skeleton.place_arms(handGlobalPos, handAngles, useGlobalHandAngles, armScale)
	
	shadow.process()
	
	slideCounter -= 1
	pushAwayCounter -= 1
	
	if blood.emitting:
		setBloodPos()
	


func defaultProcess(delta):
	if !isDefaultZOrder:
		setDefaultZOrder()
	
	targetHeight = getBreatheHeight()
	targetSpeed = 0
	targetAbAng = 0
	targetHeadAng = 0
	targetGlobalHandPos = [null, null]
	isIgnoringMapLimit = false
	
	if isAi:
		aiPlayer.movementStep(delta)
	else:
		input.movementStep()
	
	if runningFrac > 0:
		targetHeight = -runningFrac*runHeight
		targetRelHandPos = [defaultHandPos[L] + runningFrac*strideCycle*Vector2(-20,0), \
							defaultHandPos[R] + runningFrac*strideCycle*Vector2(20,0)]
	else:
		var vertSpeedY = vel.y/vertSpeed
		var velMove = -45*abs(vertSpeedY)*vertSpeedY
		for i in [L,R]:
			var netMove = Vector2(0, velMove - defaultHandPosVertShift[i]*pos.y)
			targetRelHandPos[i] = netMove + defaultHandPos[i]
	
	
	skeleton.hip.set_rotation(runningFrac*(1 if direction else -1)*0.08)
	
	breathe(delta, true)
	approachTargetSpeed(delta)
	walk(delta)
	approachTargetHeight(delta)
	regen(delta)
	
	approachTargetAbAng(delta)
	approachTargetHeadAng(delta)
	approachTargetHandPos(delta)
	
	useGlobalHandAngles = false
	approachDefaultHandAngs(delta)
	
	setLegsClosing(false)
	updateLegsClosed(delta)
	updateGrabPart()
	
	pushAway(delta, opponent.pos.x + (InputController.MIN_SEPARATION+10)*(-1 if direction else 1))
	


func approachDefaultHandAngs(delta):
	approachDefaultHandAng(delta, L)
	approachDefaultHandAng(delta, R)

func approachDefaultHandAng(delta, index):
	approachTargetHandAng(delta, index, skeleton.zeroAbsHandAngle[index] if useGlobalHandAngles else 0.0)

func approachTargetHandAng(delta, index, targetAng):
	var diff = targetAng - handAngles[index]
	var change = delta*handRotSpeed
	if change > abs(diff):
		handAngles[index] = targetAng
	else:
		handAngles[index] += change*sign(diff)


func approachTargetHeight(delta):
	pos.y = varApproachHeight(delta, pos.y)

func varApproachHeight(delta, yvar):
	var netTargetHeight = targetHeight + walkHeightShift
	var diff = netTargetHeight - yvar
	
	var accelMag = (1.2 if diff > 0 else 1.0)*vertAccel
	
	if abs(diff) < 2*delta*delta*accelMag && abs(vel.y) < 2*delta*accelMag:
		vel.y = 0
		return netTargetHeight
	
	var accel = 0
	if sign(vel.y) != sign(diff):
		accel = accelMag*sign(diff)
	else:
		var newVelY = vel.y + delta*accelMag*sign(vel.y)
		var stopDist = newVelY*newVelY/(2*accelMag)
		if abs(diff) > stopDist:
			if abs(vel.y) < vertSpeed && abs(diff) > 1.2*stopDist:
				accel = accelMag*sign(vel.y)
		else:
			accel = -accelMag*sign(vel.y)
	
	yvar += delta*vel.y + 0.5*delta*delta*accel
	vel.y += delta*accel
	
	return yvar


func approachTargetPosX(delta, targetX):
	var deltaPos = targetX - pos.x
	var stopSpeed = sqrt(2*getAccel()*abs(deltaPos))
	if abs(vel.x) < delta*getAccel() && abs(deltaPos) < delta*delta*getAccel()/2:
		targetSpeed = 0
		pos.x = targetX
		vel.x = 0
	else:
		targetSpeed = sign(deltaPos)*min(walkSpeed, 0.8*stopSpeed)
		approachTargetSpeed(delta)


func approachTargetSpeed(delta):
	if !isIgnoringMapLimit && sign(vel.x) == sign(pos.x) && abs(pos.x) > Game.MAP_LIMIT:
		var accel = -2*getAccel()*sign(pos.x)
		vel.x += delta*accel
	else:
		var diff = targetSpeed - vel.x
		var plantedDist = -minPlantDist
		for i in [L,R]:
			if footGlobalPos[i].y >= 0:
				plantedDist = max(plantedDist, sign(diff)*skeleton.footPos[i].x)
		plantedDist = min(plantedDist, minPlantDist)
		var accel = getAccel()*(1 + 0.5*plantedDist/minPlantDist)
		vel.x += clamp(diff, -delta*accel, delta*accel)
	pos.x += vel.x*delta


func slideFeet(delta, footPosXL, footPosXR):
	if slideCounter <= 0:
		slidePos = pos
	slideCounter = 2
	slidePos += delta*vel
	
	footAngles = getFootAngles(skeleton.footPos)
	
	var speedChange = delta*getAccel()*1.4
	if abs(vel.x) < speedChange:
		vel.x = 0
	else:
		vel.x -= speedChange*sign(vel.x)
	
	slidePos.y = varApproachHeight(delta, slidePos.y)
	
	for i in [L,R]:
		var diff = skeleton.footBasePos[i] - skeleton.footBasePos0[i]
		var diffMag = diff.length()
		var changeMag = delta*200.0 + 0.08*diffMag
		if diffMag < changeMag:
			skeleton.footBasePos[i] = skeleton.footBasePos0[i]
		else:
			skeleton.footBasePos[i] -= changeMag*diff/diffMag
	
	for i in [L,R]:
		var targetPosX = slidePos.x
		targetPosX += (footPosXL if i == L else footPosXR)
		var diffX = footGlobalPos[i].x - targetPosX
		var diffMag = abs(diffX)
		var changeMag = delta*200.0 + 0.08*diffMag
		if diffMag < changeMag:
			footGlobalPos[i].x = targetPosX
		else:
			footGlobalPos[i].x -= changeMag*sign(diffX)
		
		var targetPosY = 0
		var diffY = footGlobalPos[i].y - targetPosY
		var changeY = clamp(-diffY, -delta*500, delta*500)
		footGlobalPos[i].y += changeY
	
	footVel = Vector2.ZERO
	pos = slidePos


func walk(delta):
	walkThresh(delta, 20)

func walkThresh(delta, footImpetusTresh):
	walkHeightShift = walkBobHeight*(1 + 0.3*runningFrac)*(-0.5 + pow(0.5*(1 + strideCycle), 2.0))
	
	var minStride = [0, 0]
	var maxStride = [0, 0]
	var exceedance = [0, 0]
	for i in [L,R]:
		var limFrac = min(runningFrac, targetRunningFrac)
		minStride[i] = (1-limFrac)*minWalkStride[i] + limFrac*minRunStride[i]
		maxStride[i] = (1-limFrac)*maxWalkStride[i] + limFrac*maxRunStride[i]
		exceedance[i] = max(pos.x+minStride[i] - footGlobalPos[i].x, footGlobalPos[i].x - (pos.x+maxStride[i]))
		
		if exceedance[i] > 0:
			footGlobalPos[i].x += 50.0*delta*min(exceedance[i], 10)*sign(pos.x - footGlobalPos[i].x)
	
	var stopDist = vel.x*abs(vel.x)/(2*getAccel())
	
	for i in [L,R]:
		var otherIndex = ~i & 1
		if liftedFoot == i:
			var targetFootPosX
			if targetSpeed == 0:
				targetFootPosX = pos.x + 0.6*stopDist
			else:
				if sign(targetSpeed) == sign(vel.x):
					var speedRatio = abs(vel.x)/abs(targetSpeed)
					var strideFact = 0.35 + 0.35*speedRatio
					if vel.x > 0:
						targetFootPosX = footGlobalPos[otherIndex].x + strideFact*(maxStride[i] - minStride[otherIndex])
					else:
						targetFootPosX = footGlobalPos[otherIndex].x + strideFact*(minStride[i] - maxStride[otherIndex])
				else:
					targetFootPosX = footGlobalPos[i].x
				var minX = minStride[i] + max(0, stopDist)
				var maxX = maxStride[i] + min(0, stopDist)
				targetFootPosX = clamp(targetFootPosX, pos.x+minX, pos.x+maxX)
			
			moveFoot(delta, i, targetFootPosX)
			
			if exceedance[otherIndex] > 0:
				if exceedance[i] < -30:
					landFoot(i)
			return
	
	# Both feet on ground
	var moveImpetus = [0, 0]
	for i in [L,R]:
		moveImpetus[i] = abs(pos.x + stopDist - footGlobalPos[i].x)
		var landTime = game.time - footLandTime[i]
		moveImpetus[i] -= max(0, 120 - 300*landTime)
	var maxIndex = L
	if moveImpetus[R] > moveImpetus[L]:
		maxIndex = R
	if moveImpetus[maxIndex] > footImpetusTresh:
		liftedFoot = maxIndex


func moveFoot(delta, index, targetPosX):
	var accel = footAccel
	var speed = footSpeed
	if isRunning:
		accel = footRunAccel
		speed = footRunSpeed
	
	var dx = targetPosX - footGlobalPos[index].x
	var targetHeight = -min(walkLift, abs(dx)) + footLandPos[index]
	var dy = targetHeight - footGlobalPos[index].y
	var targetVel = Vector2(sign(dx)*sqrt(accel*abs(dx)), sign(dy)*sqrt(accel*abs(dy)));
	
	var dvTargetMag = (targetVel - footVel).length()
	if dvTargetMag > 0:
		var dv = min(delta*accel, dvTargetMag)
		footVel += dv*(targetVel - footVel)/dvTargetMag
	
	var deltaVel = footVel - vel
	if deltaVel.length() > speed:
		footVel = vel + speed*deltaVel.normalized()
	
	footGlobalPos[index] += delta*footVel
	if footVel.length() < 2*accel*delta && dx*dx + dy*dy < 4*delta*delta*accel*delta*delta*accel:
		if dy != 0:
			landFoot(index)
		footGlobalPos[index].x = targetPosX


func landFoot(index):
	footVel[0] = 0
	footVel[1] = 0
	footGlobalPos[index].y = footLandPos[index]
	liftedFoot = -1
	footLandTime[index] = game.time
	game.stepSounds.playRandom()


func pushAway(delta, absPosX):
	var diff = pos.x - absPosX
	var sgn = 1 if direction else -1
	if diff*sgn > 0:
		pushAwayCounter = 2
		var force = min(1, abs(diff)/120.0)
		var minVel = force*500.0
		var velAway = -sgn*vel.x
		var accelRate = clamp((minVel - velAway)/400.0, 0, 1)*3000.0
		pos.x += force*vel.x*delta
		vel.x -= sgn*delta*accelRate
		var ang = skeleton.abdomen.get_rotation()
		if direction:
			skeleton.abdomen.set_rotation(min(ang, -0.0017*diff))
		else:
			skeleton.abdomen.set_rotation(max(ang, -0.0017*diff))


func approachTargetHandPos(delta):
	for i in [L,R]:
		var targetPos
		if targetGlobalHandPos[i] == null:
			targetPos = pos + targetRelHandPos[i]
			if targetRelHandPos[i] == Vector2.ZERO:
				targetPos += defaultHandPos[i]
		else:
			targetPos = targetGlobalHandPos[i]
		var diff = targetPos - handGlobalPos[i]
		var diffMag = diff.length()
		if diffMag < 1e-5:
			continue
		
		var diffUnit = diff/diffMag
		var shoulderDPos = -skeleton.handShoulderVect[i]
		var reachLen = shoulderDPos.length()
		var dot = shoulderDPos.dot(diffUnit)
		var dotNorm = dot/reachLen
		if dotNorm > 0.2 && diffMag > reachLen:
			# Avoid going through shoulder
			var shoulderTanVect = diffUnit*dot
			var shoulderRadVect = shoulderTanVect - shoulderDPos
			var closestDist = shoulderRadVect.length()
			if closestDist < shoulderRad:
				targetPos += (shoulderRad - closestDist)*(4*Vector2.RIGHT if direction else 7*Vector2.LEFT)
				diff = targetPos - handGlobalPos[i]
		
		var targetSpeed = 0.9*sqrt(2*handAccel*diffMag)
		var targetVel = targetSpeed*diff/diffMag
		var deltaV = targetVel - handVel[i]
		var deltaVMag = deltaV.length()
		var accel = Vector2.ZERO
		if deltaVMag > 1e-5:
			var maxAccel = min(delta*handAccel, 0.5*deltaVMag)
			accel = deltaV*maxAccel/deltaVMag
		
		if !isSurrender && !opponent.isSurrender:
			var reach = 0.93*skeleton.totalArmLen[i]
			if reachLen > reach && diffMag > 30:
				if dotNorm > 0.3 && shoulderDPos.dot(handVel[i]) > 0:
					# Accel faster back if arms overstreched
					var speedup = 1 + pow(dotNorm, 2)*min(12, 18*(pow(reachLen/reach, 8) - 1))
					accel *= speedup
					delta *= sqrt(speedup)
		
		handVel[i] += accel
		var velMag = handVel[i].length()
		if velMag > handSpeed:
			handVel[i] = handVel[i]*handSpeed/velMag
		
		handGlobalPos[i] += delta*(handVel[i] + 0.5*delta*accel)


func approachTargetAbAng(delta):
	var abAng = skeleton.abdomen.get_rotation()
	var targetAng = targetAbAng
	var diff = targetAng - abAng
	if abs(diff) < 2*delta*delta*abAccel && abs(abVel) < 2*delta*abAccel:
		abVel = 0
		skeleton.abdomen.set_rotation(targetAng)
		return
	
	var targetVel = 0.8*sign(diff)*sqrt(2*abAccel*abs(diff))
	abVel += sign(targetVel - abVel)*delta*abAccel
	abVel = clamp(abVel, -abSpeed, abSpeed)
	skeleton.abdomen.set_rotation(abAng + delta*abVel)


func getHeadAng():
	return skeleton.neck.get_rotation() + skeleton.head.get_rotation()

func setHeadAng(ang):
	skeleton.neck.set_rotation(NECK_ROT_FRAC*ang)
	skeleton.head.set_rotation((1-NECK_ROT_FRAC)*ang)

func approachTargetHeadAng(delta):
	setHeadAng(Utility.approach1D(getHeadAng(), targetHeadAng, delta*headRotSpeed))


func updateLegsClosed(delta):
	if closingLegs:
		legsClosedFrac = min(1, legsClosedFrac + legCloseRate*delta)
	else:
		legsClosedFrac = max(0, legsClosedFrac - legCloseRate*delta)
	setLegsClosed(legsClosedFrac)
	approachTargetHeadAng(delta)


func updateGrabbingPart(delta):
	if isGrabbingPart:
		partGrabFrac = min(1, partGrabFrac + legCloseRate*delta)
	else:
		partGrabFrac = max(0, partGrabFrac - legCloseRate*delta)


func updateGrabPart():
	setGrabPart(partGrabFrac, grabbingPart)


const DIR_SIGN = [1, -1]
func getStrideCycle():
	var sum = 0
	for i in [L,R]:
		var deltaPos = footGlobalPos[i].x - pos.x
		var limit
		if deltaPos > 0:
			limit = runningFrac*maxRunStride[i] + (1-runningFrac)*maxWalkStride[i]
		else:
			limit = runningFrac*minRunStride[i] + (1-runningFrac)*minWalkStride[i]
		sum += 0.5*DIR_SIGN[i]*deltaPos/abs(limit)
	return clamp(sum, -1, 1)


func getBreatheHeight():
	var vertShift
	if pos.y > 0:
		vertShift = pos.y/minHeight
	else:
		vertShift = -pos.y/maxHeight
	var breatheHeight = BREATH_HEIGHT*sin(2*PI*breath)*(1 - vertShift)*max(0, 1 - abs(vel.x)/walkSpeed)
	return breatheHeight


func getFootAngles(footPos):
	return [0, 0]


func getStamina():
	return stamina


func getAccel():
	return runningFrac*runAccel + (1-runningFrac)*walkAccel


func regen(delta):
	var rate = staminaRegenRate if !isAi || aiDifficulty >= 2 else 0.7*staminaRegenRate
	stamina += delta*rate*regenRateMult*(minStaminaRegen + getStaminaHealth()*(1 - minStaminaRegen))


func getStaminaHealth():
	return getPhysicalHealth()


func tire(amt):
	if amt <= 0:
		return
	if stamina > amt:
		stamina -= amt
	else:
		stamina = max(-0.1, stamina - (max(0, stamina) + 0.5*(amt - max(0, stamina))))


func getMaxStamina():
	var health = getPhysicalHealth()
	if health <= 0:
		return 0.0
	else:
		return minStamina + (1-minStamina)*health


func getEyePos():
	return null


func canRun():
	return !closingLegs


func isUp():
	var isUp = pos.y < 10 && vel.y < 100
	if !isAi:
		isUp = isUp && targetHeight < -10
	return isUp

func isDown():
	var isDown = pos.y > -20 && vel.y > -100
	if !isAi:
		isDown = isDown && targetHeight > 50
	return isDown


func setLegsClosing(closing):
	closingLegs = closing


func setLegsClosed(frac):
	pass


func startGrabPart(part):
	grabbingPart = part
	isGrabbingPart = true


func stopGrabPart():
	isGrabbingPart = false
	targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]


func setUseGlobalHandAngles(use):
	if use != useGlobalHandAngles:
		for i in [L,R]:
			var diff = skeleton.hip.get_rotation() + skeleton.abdomen.get_rotation() + \
					skeleton.arm[i].get_rotation() + skeleton.forearm[i].get_rotation()
			handAngles[i] += diff if use else -diff
		useGlobalHandAngles = use


func setGrabPart(frac, part):
	pass


func setIsTurn(isTurn):
	pass


func setDefaultZOrder():
	pass


func getHealth():
	return 1.0

	
func getPhysicalHealth():
	return 1.0


func recBolt(bolt):
	return false


func place(posX):
	pos.x = posX
	handGlobalPos = [pos, pos]
	footGlobalPos = [pos, pos]


func bleed(parent, offset, direction, backPoly, bloodAmount, spraySize):
	bloodParent = parent
	bloodOffset = offset
	setBloodPos()
	
	if bloodAmount > 0:
		blood.z_index = Utility.getAbsZIndex(backPoly) + 1
		blood.set_rotation(-skeleton.hip.get_rotation())
		blood.process_material.direction = Vector3(1 if direction else -1, 0, 0)
		blood.amount = bloodAmount
		blood.emitting = true
	
	bloodSpray.z_index = blood.z_index
	bloodSpray.spray(getBloodGlobalPos(), spraySize)

func setBloodPos():
	if bloodParent == null:
		blood.position = bloodOffset
	else:
		blood.set_global_position(bloodParent.get_global_position() + bloodOffset)

func getBloodGlobalPos():
	if bloodParent == null:
		return pos + blood.position
	else:
		return blood.get_global_position()


func breathe(delta, moveMouth):
	breath += delta/BREATH_TIME
	if moveMouth:
		face.setJawOpen(0.3 - 0.075*sin(2*PI*breath))
	skeleton.setChestOffset(cos(2*PI*breath)*Vector2(BREATH_CHEST_DX, -BREATH_CHEST_DY))


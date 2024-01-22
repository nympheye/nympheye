extends Node
class_name AIPlayer

func get_class():
	return "AIPlayer"

const L = 0
const R = 1
const M = 0
const F = 1

const MIN_REACTION_TIME = 0.35
const MAX_REACTION_TIME = MIN_REACTION_TIME + 0.40
const MIN_REACTION_TIME_EASY = 1.5
const MAX_REACTION_TIME_EASY = MIN_REACTION_TIME_EASY + 0.5

var human
var opponent

var difficulty
var disabled
var reactionTimer
var moveReactionTimer
var direction
var moveState
var defaultTargetSeparation
var distTimer
var retreatAmt
var stopSeparation
var retreatSprintBias

var minRange
var maxRange
var impactDelay
var repeatTime

var tryExecuteTime


func _init(humanIn):
	human = humanIn
	opponent = human.opponent
	difficulty = human.options.difficulty[human.sex]
	disabled = difficulty == 0
	distTimer = 0
	defaultTargetSeparation = 0
	moveState = 0
	reactionTimer = 0
	moveReactionTimer = 0
	retreatAmt = 0
	stopSeparation = 0
	
	minRange = []
	maxRange = []
	impactDelay = []
	repeatTime = []
	for i in range(human.commandList.isValid.size()):
		minRange.append(-9999.9)
		maxRange.append(9999.9)
		impactDelay.append(0)
		repeatTime.append(1.0)
	
	tryExecuteTime = []
	for i in range(human.commandList.isValid.size()):
		tryExecuteTime.append(0)
	


func actionStep(delta):
	if disabled:
		return
	
	var separation = human.opponent.pos.x - human.pos.x
	var stopTime = human.vel.x/human.getAccel()
	var stopDist = 1.1*human.vel.x*stopTime/2
	stopSeparation = max(InputController.MIN_SEPARATION, abs(separation + stopDist + predictedOpponentMove(stopTime)))
	
	reactionTimer -= delta
	if reactionTimer <= 0:
		if difficulty == 2:
			reactionTimer = MIN_REACTION_TIME + randf()*(MAX_REACTION_TIME - MIN_REACTION_TIME)
		else:
			reactionTimer = MIN_REACTION_TIME_EASY + randf()*(MAX_REACTION_TIME_EASY - MIN_REACTION_TIME_EASY)
		reactionTimer *= getReactionTimeMult()
		
		var commandWeight = []
		var weightSum = 0.0
		for type in human.commandList.list:
			var impactSeparation = max(InputController.MIN_SEPARATION, abs(separation + stopDist + predictedOpponentMove(impactDelay[type])))
			var weight = 0.0
			if impactSeparation > minRange[type] && impactSeparation < maxRange[type]:
				if human.commandList.canExecute(type):
					var priority = getPriority(type, impactSeparation, retreatAmt)
					if priority > 0:
						if repeatTime[type] > 0:
							priority -= 1.0*exp(-(human.game.time - tryExecuteTime[type])/repeatTime[type])
						weight = pow(2, 10.0*max(0.0, priority)) - 1.0
			commandWeight.append(weight)
			weightSum += weight
		
		if weightSum > 1e-10:
			var choice = randf()*weightSum
			var sum = 0.0
			for itype in range(human.commandList.list.size()):
				if commandWeight[itype] > 0:
					sum += commandWeight[itype]
					if sum >= choice:
						var type = human.commandList.list[itype]
						tryExecuteTime[type] = human.game.time
						if human.commandList.executeCommand(type):
							commandExecuted(type)
						break
			


func movementStep(delta):
	if disabled:
		return
	
	# -1 to 1
	var humanStamina = min(human.getMaxStamina(), human.stamina + human.staminaRegenRate*max(0, abs(human.opponent.pos.x - human.pos.x) - 500)/human.walkSpeed)
	var opponentStamina = min(human.opponent.getMaxStamina(), human.opponent.stamina + human.opponent.staminaRegenRate*max(0, abs(human.opponent.pos.x - human.pos.x) - 500)/human.walkSpeed)
	retreatAmt = clamp((1.1 if difficulty >= 2 else -0.2)*(opponentStamina - humanStamina) + getRetreatOffset(), -1, 1)
	
	if !human.opponent.isActive:
		human.targetSpeed = 0
		return
	
	updateDefaultTargetSeparation(delta)
	
	moveReactionTimer -= delta
	if moveReactionTimer <= 0:
		moveReactionTimer = MIN_REACTION_TIME + randf()*(MAX_REACTION_TIME - MIN_REACTION_TIME)
		
		var targetSeparation = getTargetSeparation()
		if moveState > 0 && stopSeparation < targetSeparation:
			moveState = 0
		if moveState < 0 && stopSeparation > targetSeparation:
			moveState = 0
		if stopSeparation < targetSeparation - 30:
			moveState = -1
		if stopSeparation > targetSeparation + 20:
			moveState = 1
			if opponent.isActive && retreatAmt < retreatSprintBias && stopSeparation < targetSeparation + 400:
				moveState = 2
	
	var speed = 0
	if moveState == 1:
		speed = human.walkSpeed
	elif moveState == 2:
		speed = human.runSpeed
	elif moveState == -1:
		speed = -human.walkSpeed
	human.targetSpeed = speed*direction
	
	human.isRunning = moveState == 2


func updateDefaultTargetSeparation(delta):
	distTimer -= delta
	if distTimer <= 0:
		distTimer = 0.6 if difficulty >= 2 else 1.0
		var farWeight = clamp(0.1 + 2.0*retreatAmt, 0, 1)
		var closeWeight = clamp(0.2 - 1.5*retreatAmt, 0, 1)
		var midWeight = 1 - farWeight - closeWeight
		var randVal = randf()
		if randVal < closeWeight:
			defaultTargetSeparation = min(human.pos.x - opponent.pos.x, InputController.MIN_SEPARATION + 50)
		elif  randVal < closeWeight + midWeight:
			defaultTargetSeparation = InputController.MIN_SEPARATION + (200 if randf() < 0.5 else 300)
		else:
			defaultTargetSeparation = InputController.MIN_SEPARATION + 800


func predictedOpponentMove(time):
	var vel = human.opponent.vel.x
	var tgt = human.opponent.targetSpeed
	var accel = human.opponent.walkAccel*(1 if tgt > vel else -1)
	var accelTime = min(time, abs((tgt - vel)/accel))
	var avgVel = vel + 0.5*accelTime*accel
	if time > accelTime:
		avgVel = (accelTime*avgVel + (time-accelTime)*tgt)/time
	return time*avgVel


func getRetreatOffset():
	return 0.0


func getReactionTimeMult():
	return 1.0


func getTargetSeparation():
	return defaultTargetSeparation


func getPriority(type, separation, retreatAmt):
	pass

func commandExecuted(type):
	pass

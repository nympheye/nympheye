extends AIPlayer
class_name FemaleAIPlayer

func get_class():
	return "FemaleAIPlayer"


const BASE_RETREAT_SPRINT_BIAS = -0.40


var suppressKick
var cumCount


func _init(humanIn).(humanIn):
	direction = 1
	suppressKick = false
	cumCount = randi() % 4
	
	maxRange[FemaleCommandList.KICK] = 890
	maxRange[FemaleCommandList.KICK_HIGH] = 725
	maxRange[FemaleCommandList.KICK_LOW] = 505
	maxRange[FemaleCommandList.STAB] = 545
	maxRange[FemaleCommandList.GRAB_CLOTH] = 495
	maxRange[FemaleCommandList.GRAB] = 500
	maxRange[FemaleCommandList.SLASH] = 495
	maxRange[FemaleCommandList.BOLT_LOW] = 1800
	maxRange[FemaleCommandList.BOLT_HIGH] = 1800
	
	minRange[FemaleCommandList.KICK] = 610
	minRange[FemaleCommandList.KICK_HIGH] = 690
	minRange[FemaleCommandList.BOLT_LOW] = 650
	minRange[FemaleCommandList.BOLT_HIGH] = 700
	
	impactDelay[FemaleCommandList.KICK] = 0.4
	impactDelay[FemaleCommandList.KICK_HIGH] = 0.3
	impactDelay[FemaleCommandList.KICK_LOW] = 0.4
	impactDelay[FemaleCommandList.STAB] = 0.2
	impactDelay[FemaleCommandList.GRAB_CLOTH] = 0.3
	impactDelay[FemaleCommandList.GRAB] = 0.3
	impactDelay[FemaleCommandList.SLASH] = 0.3
	impactDelay[FemaleCommandList.BOLT_LOW] = 0.6
	impactDelay[FemaleCommandList.BOLT_HIGH] = 0.6
	
	repeatTime[FemaleCommandList.PASS] = 0.0
	repeatTime[FemaleCommandList.BOLT_LOW] = 1.0
	repeatTime[FemaleCommandList.BOLT_HIGH] = 1.0
	
	retreatSprintBias = BASE_RETREAT_SPRINT_BIAS


func getTargetSeparation():
	return 730 if opponent.isRecoiling() else defaultTargetSeparation


func getPriority(type, separation, retreatAmt):
	var recoiling = opponent.isRecoiling()
	var blocking = opponent.isBlockingLow()
	
	if type == FemaleCommandList.PASS:
		return 0.2 + 0.5*(1 - human.getStamina())
	elif type == FemaleCommandList.KICK:
		if recoiling || (suppressKick && human.getStamina() < 0.95):
			return 0.0
		var shouldntTerm = 0
		if difficulty >= 2:
			if blocking:
				shouldntTerm = -0.5
			shouldntTerm -= 0.5*clamp((separation - 630)/20, 0, 1)*clamp((670 - separation)/20, 0, 1)
		else:
			if blocking:
				shouldntTerm = -0.1
		var kneeRangeTerm = min(0, 0.03*(separation - 625)) + min(0, 0.03*(625 - separation))
		var frontRangeTerm = min(0, 0.03*(separation - 780)) + min(0, 0.03*(870 - separation))
		return 0.55 + shouldntTerm + max(kneeRangeTerm, frontRangeTerm) - 0.7*max(0, retreatAmt)
	elif type == FemaleCommandList.KICK_LOW:
		var ballDamage = min(1-opponent.ball[L].health, 1-opponent.ball[R].health)
		return 0.0 if recoiling else 0.30 + 0.5*clamp(retreatAmt, -1, 0.2) - 0.8*max(0, ballDamage - 0.5)
	elif type == FemaleCommandList.KICK_HIGH:
		return opponent.stamina - 0.1
	elif type == FemaleCommandList.STAB:
		return retreatAmt - 0.1
	elif type == FemaleCommandList.SLASH:
		return 0.3 if !human.options.goreEnabled || human.opponent.isBlockingLow() else (0.41 if opponent.erect < 0.8 else 0.6)
	elif type == FemaleCommandList.GRAB:
		return 0.0 if (opponent.hasCloth && human.grabbedBall) else 0.6
	elif type == FemaleCommandList.GRAB_CLOTH:
		return 0.3 - 0.3*retreatAmt
	elif type == FemaleCommandList.STAB_BALLS:
		return 0.5
	elif type == FemaleCommandList.PUNCH_BALLS:
		return 0.5
	elif type == FemaleCommandList.UNSTAB_BALLS:
		return 0.5
	elif type == FemaleCommandList.WIN:
		return 0.5
	elif type == FemaleCommandList.WIN_GRAB:
		return 0.5
	elif type == FemaleCommandList.WIN_STROKE:
		return 0.5
	elif type == FemaleCommandList.WIN_CUT_SOFT:
		return 0.35
	elif type == FemaleCommandList.WIN_CUT_HARD:
		return 0.5 if opponent.action.cumCount > cumCount else 0.0
	elif type == FemaleCommandList.GRAB_STAB:
		return opponent.stamina - 0.6
	elif type == FemaleCommandList.GRAB_TWIST:
		return 0.5
	elif type == FemaleCommandList.GRAB_PULL:
		return 0.5
	elif type == FemaleCommandList.GRAB_REC_GRAB:
		return 0.5
	elif type == FemaleCommandList.GRAB_REC_KICK:
		return 0.5
	elif type == FemaleCommandList.STOP_GRAB:
		return retreatAmt - 0.7
	elif type == FemaleCommandList.BOLT_LOW:
		return (0.3 if !human.options.goreEnabled || human.opponent.isBlockingLow() else 0.41) \
				- 0.5*(1-human.stamina)
	elif type == FemaleCommandList.BOLT_HIGH:
		return (0.27 if human.opponent.isBlockingHigh() else 0.32) \
				- 0.5*(1-human.stamina)
	
	return 0.0


func commandExecuted(type):
	suppressKick = randf() < 0.30
	retreatSprintBias = BASE_RETREAT_SPRINT_BIAS + (0.1 if opponent.isImpotent else 0.0)


func getRetreatOffset():
	return .getRetreatOffset() + (0.1 if opponent.isImpotent else 0.0) + (0.2 if human.weapon == FConst.WEAPON_CAST else 0.0)

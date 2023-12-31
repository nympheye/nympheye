extends Action
class_name MBlock

func get_class():
	return "MBlock"


const STAMINA = 0.03


var male : Human
var recTimer
var blockLow
var blockHigh


func _init(maleIn, startBlockLow, startBlockHigh).(maleIn):
	male = maleIn
	blockLow = startBlockLow
	blockHigh = startBlockHigh


func start():
	recTimer = 9999
	male.targetAbAng = -0.1
	human.tire(STAMINA)


func isBlockingLow():
	return blockLow && (male.handGlobalPos[L] - (male.pos + male.targetRelHandPos[L])).length() < 6

func isBlockingHigh():
	return blockHigh && (male.handGlobalPos[R] - (male.pos + male.targetRelHandPos[R])).length() < 6


func canStop():
	return true

func isDone():
	return false


func perform(time, delta):
	recTimer += delta
	male.targetHeight = -30 if recTimer < 0.14 else 0
	
	male.targetRelHandPos[R] = Vector2(10, -180) if blockHigh else Vector2.ZERO
	male.targetRelHandPos[L] = Vector2(5, 100) if blockLow else Vector2.ZERO
	
	male.slideFeet(delta, -110, 50)
	male.breathe(delta, true)
	male.approachTargetHandPos(1.1*delta)
	male.approachTargetAbAng(delta)
	male.approachTargetHeight(delta)
	
	var move = min(1, time/0.3)
	male.footAngles[L] = -0.3*move
	
	if time > 0.16 && blockLow:
		male.setHandLMode(MConst.HANDL_FIST)
	
	if time > 0.33:
		var blockableLow = male.opponent.isKicking()
		var blockableHigh = false
		if male.opponent.isCasting():
			blockableLow = blockableLow || male.opponent.bolt.targetClass == FCast.TGT_CLASS_LOW
			blockableHigh = male.opponent.bolt.targetClass == FCast.TGT_CLASS_HIGH
		if blockableLow:
			blockLow = true
		if blockableHigh:
			blockHigh = true


func recBlockedKick():
	recTimer = 0


func stop():
	male.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]

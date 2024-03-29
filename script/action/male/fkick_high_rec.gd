extends Action
class_name FKickHighRec

func get_class():
	return "FKickHighRec"


const LEN = 0.4
const MAX_PUSH_DIST = 590


var male
var soundTrigger


func _init(maleIn).(male):
	male = maleIn


func start():
	soundTrigger = false
	male.game.kickSounds.playRandom()
	male.face.setEyesClosed()
	male.tire(0.8)


func canStop():
	return isDone()

func isDone():
	return time > LEN


func perform(time, delta):
	
	if time > 0.2 && !soundTrigger:
		soundTrigger = true
		male.hitSounds.playRandom()
	
	var dist = male.pos.x - male.opponent.pos.x
	var pushDist = max(0, MAX_PUSH_DIST - dist)
	var pushAmt = min(pushDist/32, 2.0)
	
	male.targetSpeed = male.walkSpeed*(1 + min(0.5, pushAmt))
	male.vel.x += delta*3.0*male.walkAccel*pushAmt*max(0, -male.vel.x/male.walkSpeed)
	male.approachTargetSpeed(delta*(1 + pushAmt))
	
	male.targetAbAng = -0.2
	male.approachTargetHeight(delta)
	male.walk(delta)
	male.approachTargetHandPos(delta)
	male.approachTargetAbAng(delta)
	male.breathe(delta, true)


func stop():
	male.face.setNeutral()

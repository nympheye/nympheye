extends Action
class_name MRecoil1

func get_class():
	return "MRecoil1"


const PUSH_DIST = 430
const SHOCK_TIME = 1.3


var opponent
var isDeath
var grabPart
var blockingHigh


func _init(humanIn, isDeathIn, grabPartIn).(humanIn):
	opponent = humanIn.opponent
	isDeath = isDeathIn
	grabPart = grabPartIn
	blockingHigh = false


func start():
	human.closingLegs = true
	human.targetGlobalHandPos = [null, null]
	human.setZOrder([-5,-4,-3,4,3])
	if human.getHealth() > 0:
		if grabPart == Human.GRAB_FACE:
			human.face.setEyesClosed()
		else:
			human.face.setPain(0.0)
	else:
		human.face.setShock(-0.2)
	human.startGrabPart(grabPart)


func canStop():
	return !isDeath

func isDone():
	return time > 2.0


func perform(time, delta):
	if time < 1.2:
		human.targetSpeed = 0.7*human.walkSpeed
	else:
		human.targetSpeed = 0.0
	
	if !isDeath && time > SHOCK_TIME:
		human.face.setPain(0.0)
		if opponent.isCasting() && opponent.bolt.targetClass == FCast.TGT_CLASS_HIGH:
			blockingHigh = true
	
	if blockingHigh:
		human.targetRelHandPos[R] = Vector2(-30, -180)
	
	human.targetGlobalHandPos = [null, null]
	human.targetHeight = 10
	
	human.opponent.pushAway(delta, human.handGlobalPos[R].x - PUSH_DIST)
	
	human.approachTargetHeight(delta)
	human.approachTargetSpeed(delta)
	human.walk(delta)
	human.approachTargetHandPos(delta)
	human.approachTargetAbAng(delta)
	human.updateLegsClosed(delta)
	human.updateGrabPart()
	
	if time > 1.8 && isDeath:
		isDeath = false
		human.perform(MFallBack.new(human))
	


func stop():
	human.closingLegs = false
	human.targetRelHandPos[L] = Vector2.ZERO
	human.targetRelHandPos[R] = Vector2.ZERO
	human.face.setNeutral()
	human.stopGrabPart()


func isBlockingHigh():
	return time > SHOCK_TIME


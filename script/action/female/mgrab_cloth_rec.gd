extends Action
class_name MGrabClothRec

func get_class():
	return "MGrabClothRec"


const TIME = 2.0
const START_BACKUP_TIME = 0.2
const END_BACKUP_TIME = 2.0


var female : Human
var soundTrigger


func _init(femaleIn).(femaleIn):
	female = femaleIn


func start():
	soundTrigger = false
	female.face.setPain(0)
	female.startGrabPart(Human.GRAB_GROIN)
	female.setLegsClosing(true)
	female.setHandRMode(FConst.HANDR_CLOSED)


func canStop():
	return false

func isDone():
	return time > TIME


func perform(time, delta):
	female.approachTargetSpeed(delta)
	female.walk(delta)
	female.approachTargetHandPos(delta)
	female.breathe(delta, true)
	female.approachTargetAbAng(delta)
	female.updateGrabPart()
	female.updateLegsClosed(delta)
	female.regen(0.5*delta)
	
	female.approachTargetHeight(delta)
	
	if time > 0.2 && !soundTrigger:
		soundTrigger = true
		female.hitSounds.play(14)
	
	if time > START_BACKUP_TIME && time < END_BACKUP_TIME:
		female.targetSpeed = -female.walkSpeed
		female.targetHeight = 10
	else:
		female.targetSpeed = 0


func stop():
	female.face.setNeutral()
	female.setLegsClosing(false)
	female.stopGrabPart()

extends Action
class_name MGrabArmRRec

func get_class():
	return "MGrabArmRRec"


const GRAB = 0

const GRAB_STAMINA = 0.45


var female
var opponent
var done
var subact
var subactTime
var isFeel


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	done = false
	isFeel = false
	subact = -1
	subactTime = 0
	female.targetHeight = 0
	female.tire(min(female.stamina, 0.13))
	female.face.setNeutral()


func canStop():
	return done


func isDone():
	return done


func perform(time, delta):
	female.breathe(delta, true)
	female.updateGrabPart()
	female.updateLegsClosed(delta)
	female.footAngles = female.getFootAngles(female.skeleton.footPos)
	female.approachTargetAbAng(0.6*delta)
	female.approachTargetHandPos(delta)
	female.isIgnoringMapLimit = true
	
	subactTime += delta
	if subact < 0:
		female.regen(0.35*delta)
		female.approachTargetHeight(0.6*delta)
		female.approachDefaultHandAngs(delta)
	elif subact == GRAB:
		grab(subactTime, delta)


func recFeel(newFeel):
	isFeel = newFeel
	if subact != GRAB:
		if isFeel:
			female.setHandRMode(FConst.HANDR_CLOSED)
			female.setLegsClosing(true)
			female.targetHeight = -15
			female.crySounds.playRandom()
			female.face.setShock(0.3)
			female.recMoraleDamage(0.075)
		else:
			female.targetHeight = 0


func startSubaction(actType):
	if actType == GRAB:
		female.tire(0.5*GRAB_STAMINA)
		female.stopGrabPart()
		female.face.setNeutral()
		female.gruntSounds.playRandom()
	
	stopSubaction()
	subact = actType
	subactTime = 0

func stopSubaction():
	female.targetGlobalHandPos[L] = null
	subact = -1


func grab(time, delta):
	female.targetHeight = female.downHeight
	female.approachTargetHeight(delta)
	if female.pos.y > opponent.pos.y - 70:
		var grabPos = Vector2(-20, 80) + opponent.pos \
				- female.skeleton.handHipOffset[L] - Vector2.DOWN*female.skeleton.heightDiff
		female.targetGlobalHandPos[L] = grabPos
		if (female.handGlobalPos[L] - grabPos).length() < 20:
			done = true
			female.tire(0.5*GRAB_STAMINA)
			human.perform(FGrabBall.new(human))
			opponent.stopAction()


func stop():
	female.stopGrabPart()
	female.setLegsClosing(false)
	female.setIsTurn(false)
	female.isPunchedGut = false
	female.isIgnoringMapLimit = false

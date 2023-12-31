extends Action
class_name FTwist

func get_class():
	return "FTwist"


const STAMINA = 0.54


var female
var male
var iball
var pullPos
var isTwist


func _init(fgrab).(fgrab.female):
	female = fgrab.female
	male = fgrab.opponent
	iball = fgrab.iball
	pullPos = fgrab.holdPos + Vector2(15, 40)
	fgrab.stopGrabbing()


func start():
	female.tire(STAMINA)
	male.groin.twist(iball)
	male.face.setShock(-0.35)
	female.handAngles[L] = -0.5
	female.gruntSounds.playRandom()
	female.face.setAngry(0.1)
	isTwist = false
	female.setHandLMode(FConst.HANDL_GRAB)


func canStop():
	return false

func isDone():
	return time > 0.8


func perform(time, delta):
	if time > 0.01:
		female.targetGlobalHandPos[L] = pullPos
	female.approachTargetHandPos(0.6*delta)
	female.targetHeight = 1.0*female.downHeight
	female.approachTargetHeight(delta)
	female.targetAbAng = 0.1
	female.approachTargetAbAng(delta)
	female.approachTargetPosX(delta, male.pos.x - 330)
	
	if !isTwist && time > 0.01:
		isTwist = true
		var label = "R" if iball == R else "L"
		var ballIndex = male.get_node("polygons/Body/Ball" + label).z_index
		female.get_node("polygons/ArmL/Foreward/Twist").z_index = ballIndex - 1
		female.setHandLMode(FConst.HANDL_TWIST)
	
	if time > 0.18:
		male.ball[iball].sever()


func stop():
	female.setHandLMode(FConst.HANDL_OPEN)
	male.recoil(true, true, Human.GRAB_GROIN)
	female.targetGlobalHandPos = [null, null]
	female.face.setNeutral()


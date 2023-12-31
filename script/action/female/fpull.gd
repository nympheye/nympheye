extends Action
class_name FPull

func get_class():
	return "FPull"


const STAMINA = 0.2
const PULL_TIME = 0.25
const WAIT_TIME = 0.15
const MOVE_TIME = 1.7
const THROW1_TIME = 0.15
const THROW2_TIME = 0.2
const END_TIME = 0.1

const SEVERED_HOLD_POS = Vector2(-20, 80)
const SEVERED_BALL_POS = Vector2(38, 4)


var female
var male
var iball
var pullPos


func _init(fgrab).(fgrab.female):
	female = fgrab.female
	male = fgrab.opponent
	iball = fgrab.iball
	pullPos = fgrab.holdPos + Vector2(0, 40)

func start():
	female.tire(STAMINA)
	male.game.setSlowmo(0.2)
	male.face.setShock(-0.35)


func canStop():
	return false

func isDone():
	return time > PULL_TIME + WAIT_TIME + MOVE_TIME + THROW1_TIME + THROW2_TIME + END_TIME


func perform(time, delta):
	var severedBall = male.ball[iball].severedBall.get_node("Skeleton2D/Ball")
	
	if time < PULL_TIME:
		var amt = time/PULL_TIME
		female.handAngles[L] = FGrabBall.HANDL_ANG - 0.15*amt
		female.targetGlobalHandPos[L] = pullPos
		female.approachTargetHandPos(0.6*delta)
		female.targetHeight = 0.6*female.downHeight
		female.approachTargetHeight(delta)
	elif time < PULL_TIME + WAIT_TIME:
		if !male.ball[iball].isSevered:
			male.ball[iball].sever()
			male.groin.snapSounds.playRandom()
		severedBall.position = getSeveredPos(delta)
		female.targetGlobalHandPos[L] = pullPos + Vector2(-15, 10)
		female.approachTargetHandPos(delta)
	elif time < PULL_TIME + WAIT_TIME + MOVE_TIME:
		male.game.setSlowmo(1.0)
		male.recoil(true, true, Human.GRAB_GROIN)
		
		female.targetGlobalHandPos[L] = null
		female.targetRelHandPos[L] = SEVERED_HOLD_POS
		female.approachTargetHandPos(0.4*delta)
		female.targetHeight = 0.0
		female.approachTargetHeight(0.6*delta)
		female.targetSpeed = -0.8*female.walkSpeed if time < MOVE_TIME-0.3 else 0
		female.approachTargetSpeed(delta)
		female.walk(delta)
		female.targetAbAng = 0.0
		female.approachTargetAbAng(delta)
		
		severedBall.position = getSeveredPos(delta)
	elif time < PULL_TIME + WAIT_TIME + MOVE_TIME + THROW1_TIME:
		female.targetRelHandPos[L] = SEVERED_HOLD_POS + Vector2(-30, 10)
		female.approachTargetHandPos(0.4*delta)
		severedBall.position = getSeveredPos(delta)
		female.setDefaultHandRMode()
	elif time < PULL_TIME + WAIT_TIME + MOVE_TIME + THROW1_TIME + THROW2_TIME:
		female.targetRelHandPos[L] = SEVERED_HOLD_POS + Vector2(30, 0)
		female.approachTargetHandPos(0.7*delta)
		severedBall.position = getSeveredPos(delta)
	else:
		severedBall.fall(Vector2(200, 0), 2.0*(2*randf() - 1))
		female.setHandLMode(FConst.HANDL_OPEN)
		male.ball[iball].severedBall.get_node("polygons").get_child(0).z_index = 100


func getSeveredPos(delta):
	return male.femaleGlobalHandPos(L) + SEVERED_BALL_POS + 0.85*delta*female.handVel[L]


func stop():
	female.targetGlobalHandPos = [null, null]
	female.targetRelHandPos[L] = Vector2.ZERO
	female.setKnifePointUp(false)
	female.targetAbAng = 0
	female.targetGlobalHandPos[L] = null
	female.setUseGlobalHandAngles(false)
	female.handAngles[L] = 0


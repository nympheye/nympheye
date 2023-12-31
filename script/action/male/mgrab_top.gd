extends Action
class_name MGrabTop

func get_class():
	return "MGrabTop"


const L0 = 0
const R0 = 1

const STAMINA = 0.28
const REACH = 350
const LEAN = 20*PI/180

const TUG_FORWARD_TIME = 1.1
const TUG_BACK_TIME = TUG_FORWARD_TIME + 0.24
const DROP_TIME = TUG_BACK_TIME + 0.28
const END_TIME = DROP_TIME + 0.12
const FHOLD_TIME = 0.3
const HORIZ_SLACK = 120


var male
var opponent
var grabOffset
var holdOffset
var missed
var hold
var tear
var holdTime

var topL
var topLMid : Bone2D
var topLL : Bone2D
var topLR : Bone2D


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent
	missed = false
	hold = false
	tear = false
	holdTime = 0


static func canPerform(human):
	if human.stamina < STAMINA || !human.opponent.hasTop:
		return false
	var shoulderPos = human.skeleton.arm[R0].get_global_position()
	var topPos = human.opponent.skeleton.chest.get_global_position()
	return (shoulderPos - topPos).length() < REACH


func start():
	setZOrder()
	grabOffset = opponent.skeleton.heightDiff*Vector2.DOWN + opponent.skeleton.torsoBasePos + \
				opponent.skeleton.chestBasePos + Vector2(60, -80)
	holdOffset = grabOffset + Vector2(145, 65)
	male.tire(0.5*STAMINA)
	
	topL = opponent.game.get_node("TopL")
	topLMid = topL.get_node("Skeleton2D/Middle")
	topLL = topLMid.get_node("Left")
	topLR = topLMid.get_node("Right")
	topL.transform.origin = opponent.transform.origin


func canStop():
	return !hold

func isDone():
	return missed || holdTime > END_TIME


func perform(time, delta):
	
	var outOfReach = ((opponent.pos + grabOffset) - (male.pos + male.skeleton.hipArmOffset[R])).length() > REACH
	if time > 0.23 && !hold && outOfReach:
		missed = true
	if time > 0.5 && !hold:
		missed = true
	if missed:
		return
	
	if !hold:
		male.targetAbAng = -LEAN
		male.targetGlobalHandPos[R] = opponent.pos + grabOffset - male.skeleton.handHipOffset[R]
	elif !tear:
		male.targetAbAng = -LEAN/2
		male.targetGlobalHandPos[R] = opponent.pos + holdOffset - male.skeleton.handHipOffset[R]
		if time > TUG_FORWARD_TIME && time < TUG_BACK_TIME:
			male.targetGlobalHandPos[R] += Vector2(-80, 10)
	else:
		male.targetAbAng = 0
		male.targetGlobalHandPos[R] = null
	
	male.slideFeet(delta, 0, 0)
	male.approachTargetAbAng(delta)
	
	male.approachTargetHandPos((0.6 if outOfReach else 1.0)*delta)
	
	male.targetHeight = 0 if time > DROP_TIME  else 20
	male.approachTargetHeight(delta)
	
	var ang = 0
	if hold && !tear:
		var pullLen = opponent.maleGlobalHandPos(R).x - opponent.pos.x - HORIZ_SLACK
		if pullLen > 0:
			ang = 0.002*pullLen
	opponent.targetAbAng = ang
	opponent.skeleton.neck.set_rotation(-0.6*opponent.skeleton.abdomen.get_rotation())
	
	if hold:
		holdTime += delta
		var holdPos = opponent.maleGlobalHandPos(R) + Vector2(-45, 16)
		topLMid.transform.origin = holdPos
		topLMid.vel = male.handVel[R]
		if !tear:
			var leftPos = opponent.pos + Vector2(0, -130) - holdPos
			topLL.set_rotation(atan2(leftPos.y, leftPos.x))
	
	if !hold && (male.handGlobalPos[R] - male.targetGlobalHandPos[R]).length() < 25:
		if opponent.perform(MGrabTopRec.new(opponent)):
			male.tire(0.5*STAMINA)
			setZOrder()
			opponent.removeTop()
			hold = true
			tearLeft()
			opponent.game.tearSounds.playRandom()
		else:
			missed = true
			return
	
	if holdTime > 0.3:
		male.get_node("polygons/ArmR/HandR_grab_cloth1").z_index = male.get_node("polygons/ArmR/HandR_grab_cloth2").z_index - 3
	
	if holdTime > FHOLD_TIME && !(opponent.grabbingPart == Female.GRAB_BREAST):
		opponent.startGrabPart(Female.GRAB_BREAST)
		opponent.hitSounds.play(14)
		opponent.face.setShock(0.2)
	
	if !tear && holdTime > TUG_BACK_TIME:
		tear = true
		topLR.physActive = true
		opponent.action.tearRight()
		opponent.game.tearSounds.playRandom()


func tearLeft():
	var body = opponent.get_node("polygons/Body")
	body.get_node("TopR").set_visible(true)
	
	var poly = topL.get_node("polygons")
	poly.set_visible(true)
	poly.get_node("TopL_tearL").z_index = body.z_index - 1
	poly.get_node("TopL_tearR").z_index = body.z_index + 1
	
	topLL.physActive = true
	topLL.set_rotation(220*PI/180)
	
	male.setHandRMode(MConst.HANDR_GRAB_CLOTH)
	male.get_node("polygons/ArmR/HandR_grab_cloth1").z_index = body.z_index + 1
	male.get_node("polygons/ArmR/HandR_grab_cloth2").z_index = body.z_index + 2


func setZOrder():
	male.setZOrder([0,-4,1,3,4])
	opponent.setZOrder([-5,-2,-1,1,2])


func stop():
	male.targetAbAng = 0
	male.targetGlobalHandPos[R] = null
	topLMid.fall()
	male.setHandRMode(MConst.HANDR_OPEN)
	male.setIsTurn(false)

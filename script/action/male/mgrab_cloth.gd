extends Action
class_name MGrabCloth

func get_class():
	return "MGrabCloth"


const STAMINA = 0.3
const REACH = 420
const LEAN = 28*PI/180
const CROUCH = 60


var male
var opponent
var grabOffset : Vector2
var missed
var isGrab
var grabTime


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent


func start():
	missed = false
	isGrab = false
	grabTime = 0.0
	male.tire(0.5*STAMINA)
	
	setZOrder()
	
	grabOffset = opponent.skeleton.heightDiff*Vector2.DOWN + Vector2(60, -80)


func canStop():
	return opponent.hasBottom

func isDone():
	return missed || grabTime > 0.6


func perform(time, delta):
	var deltaPos = (opponent.pos + grabOffset) - (male.pos + male.skeleton.hipArmOffset[R])
	var outOfReach = deltaPos.length() > REACH
	var outOfReachX = abs(deltaPos.x) > 0.9*REACH
	if time > 0.20 && outOfReachX || time > 0.4 && outOfReach:
		missed = true
	if missed:
		return
	
	if !isGrab:
		male.targetGlobalHandPos[R] = opponent.pos + grabOffset - male.skeleton.handHipOffset[R]
	else:
		grabTime += delta
		if grabTime < 0.3:
			male.targetGlobalHandPos[R] = opponent.pos + grabOffset - male.skeleton.handHipOffset[R] + Vector2(5, -5)
		else:
			opponent.removeBottom()
			male.targetGlobalHandPos[R] = opponent.pos + grabOffset - male.skeleton.handHipOffset[R] + Vector2(70, -25)
			opponent.game.tearSounds.playRandom()
			if opponent.perform(MGrabClothRec.new(opponent)):
				setZOrder()
			else:
				missed = true
				return
	
	male.targetHeight = CROUCH + 0.75*opponent.targetHeight
	male.targetAbAng = -LEAN
	
	if !isGrab && (male.handGlobalPos[R] - male.targetGlobalHandPos[R]).length() < 30:
		isGrab = true
		male.tire(0.5*STAMINA)
		male.setHandRMode(MConst.HANDR_GRAB_CLOTH)
	
	male.approachTargetHandPos((0.5 if outOfReach else 0.7)*delta)
	male.approachTargetHeight(delta)
	male.approachTargetAbAng(delta)
	


func setZOrder():
	male.setZOrder([-3,-4,1,3,4])
	opponent.setZOrder([-5,-2,-1,1,2])
	
	var handPoly1 = male.get_node("polygons/ArmR/HandR_grab_cloth1")
	var handPoly2 = male.get_node("polygons/ArmR/HandR_grab_cloth2")
	handPoly1.z_index = handPoly1.get_parent().z_index + 1
	handPoly2.z_index = handPoly1.z_index + 1


func stop():
	male.targetAbAng = 0
	male.targetGlobalHandPos[R] = null
	male.setHandRMode(MConst.HANDR_OPEN)
	male.setIsTurn(false)


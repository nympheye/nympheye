extends Action
class_name MGrabTopRec

func get_class():
	return "MGrabTopRec"


const BACKUP_TIME = 1.5
const HOLD_TIME = BACKUP_TIME + 0.8
const TIME = HOLD_TIME + 0.15
const FACE1_TIME = 0.7


var female
var iface
var tearTime
var isTorn

var topR
var topRMid : Bone2D
var topRL : Bone2D
var topRR : Bone2D


func _init(femaleIn).(femaleIn):
	female = femaleIn
	tearTime = 0


func start():
	female.targetSpeed = 0
	female.targetAbAng = 0
	female.targetHeight = 0
	iface = 0
	isTorn = false
	
	female.setHandRMode(FConst.HANDR_CLOSED)
	
	topR = female.game.get_node("TopR")
	topRMid = topR.get_node("Skeleton2D/Middle")
	topRL = topRMid.get_node("Left")
	topRR = topRMid.get_node("Right")


func canStop():
	return false

func isDone():
	return tearTime > TIME


func perform(time, delta):
	female.walk(delta)
	female.approachTargetHandPos(delta)
	female.approachTargetHandAng(delta, R, 0)
	female.breathe(delta, true)
	female.approachTargetAbAng(delta)
	female.updateGrabPart()
	female.regen(0.6*delta)
	female.targetRelHandPos[R] = Vector2(-10, 0)
	
	if !isTorn:
		var targetX = female.opponent.pos.x - 400
		female.approachTargetPosX(delta, targetX)
		female.approachTargetHeight(delta)
		female.pushAway(delta, female.opponent.pos.x - 300)
	else:
		tearTime += delta
	
		if tearTime < BACKUP_TIME:
			female.targetSpeed = -female.walkSpeed
			female.targetHeight = 10
			female.approachTargetHeight(delta)
			
			if tearTime > 1.0:
				female.setDefaultHandRMode()
		else:
			female.targetSpeed = 0
		female.approachTargetSpeed(delta)
		
		if iface == 0 && tearTime > FACE1_TIME:
			iface = 1
			female.face.setPain(0)
		
		if tearTime > HOLD_TIME && female.grabbingPart == Female.GRAB_BREAST:
			female.stopGrabPart()
			topRMid.fall()
			topRMid.vel.x = 500
		
		if tearTime < HOLD_TIME:
			var breastRPos = female.pos + Vector2(-30, -155)
			topRMid.transform.origin = breastRPos
			topRMid.vel = female.vel


func tearRight():
	isTorn = true
	topR.transform.origin = female.transform.origin
	
	var body = female.get_node("polygons/Body")
	body.get_node("TopR").set_visible(false)
	
	var poly = topR.get_node("polygons")
	poly.set_visible(true)
	poly.get_node("TopR_tearL").z_index = body.z_index + 1
	poly.get_node("TopR_tearR").z_index = female.get_node("polygons/ArmL/Back").z_index + 3
	
	topRL.physActive = true
	topRR.physActive = true


func stop():
	female.face.setNeutral()


extends Action
class_name FDie

func get_class():
	return "FDie"


const START_TIME = 0.7
const FALL_TIME = 1.0
const AB_ANG = 0.52
const FOOTL_SHIFT = Vector2(-295, 110)
const FOOTR_SHIFT = Vector2(65, 27)
const HANDL_START_POS = Vector2(-30, 130)
const HANDR_START_POS = Vector2(0, 20)
const HANDL_FALL_POS = Vector2(-220, 130)
const HANDR_FALL_POS = Vector2(60, 0)


var female
var startPos
var isDown
var loseHip
var blood
var blood2
var footStartPos


func _init(humanIn).(humanIn):
	female = humanIn


func start():
	isDown = false
	loseHip = female.get_node("Skeleton2D_lose/Hip")
	blood = loseHip.get_node("Blood")
	blood2 = loseHip.get_node("Blood2")
	startPos = female.pos
	female.dieSounds.playRandom()
	footStartPos = [female.footGlobalPos[L] - startPos, female.footGlobalPos[R] - startPos]


func perform(time, delta):
	
	if time < START_TIME:
		female.targetAbAng = AB_ANG
		female.targetRelHandPos[L] = HANDL_START_POS
		female.targetRelHandPos[R] = HANDR_START_POS
		female.approachTargetHandPos(0.4*delta)
		female.face.setPain(0)
		
		if time > 0.4:
			female.dropWeapon()
	elif time < START_TIME + FALL_TIME:
		var dt = time - START_TIME
		var amt = dt/FALL_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		
		female.face.setEyesClosed()
		
		var footXAmt = 0.5*amt + 0.9*amt2 - 0.4*amt4
		var footYAmt = 1.2*amt2 - 0.2*amt4
		female.skeleton.footBasePos[L] = female.skeleton.footBasePos0[L] + Vector2(footXAmt*FOOTL_SHIFT.x, footYAmt*FOOTL_SHIFT.y)
		female.skeleton.footBasePos[R] = female.skeleton.footBasePos0[R] + Vector2(footXAmt*FOOTR_SHIFT.x, footYAmt*FOOTR_SHIFT.y)
		
		var rotAmt = 0.9*amt2 + 0.1*amt4
		female.skeleton.hip.set_rotation(-1.35*rotAmt)
		
		var moveXAmt = 0.0*amt + 1.4*amt2 - 0.6*amt4
		var moveYAmt = 0.0*amt + 1.0*amt2
		female.pos = Vector2(-205*moveXAmt + startPos.x, \
								250*moveYAmt + (1 - rotAmt)*startPos.y)
		
		female.targetAbAng = (1-amt)*AB_ANG
		
		female.targetRelHandPos[L] = (1-amt)*HANDL_START_POS + amt*HANDL_FALL_POS
		female.targetRelHandPos[R] = (1-amt)*HANDR_START_POS + amt*HANDR_FALL_POS
		female.approachTargetHandPos(0.8*delta)
		
		female.footAngles[L] += rotAmt*0.55
		female.footAngles[R] += rotAmt*0.2
		
		for i in [L,R]:
			female.footGlobalPos[i] = startPos + (1 - moveXAmt)*footStartPos[i]
	else:
		if !isDown:
			isDown = true
			human.game.isFinished = true
			female.get_node("polygons").set_visible(false)
			female.get_node("polygons_lose").set_visible(true)
			female.get_node("polygons_lose/Blood").set_visible(true)
			female.get_node("polygons_lose/Blood2").set_visible(true)
			female.game.fallSounds.playRandom()
			female.pos = startPos + Vector2(-210, 300)
	
	var bloodTime = time - (FALL_TIME + 0.8)
	var bloodAmt = clamp(bloodTime/10.0, 0, 1)
	bloodAmt = 1.9*bloodAmt - 0.9*bloodAmt*bloodAmt
	blood.position = bloodAmt*Vector2(15, -15)
	blood2.position = bloodAmt*Vector2(-4, 8)
	
	loseHip.position = female.skeleton.hip.position
	female.approachTargetAbAng(0.6*delta)
	female.updateGrabPart()
	female.approachDefaultHandAngs(delta)
	


func canStop():
	return false


func isDone():
	return false


func stop():
	pass

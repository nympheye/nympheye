extends Action
class_name FGrabCloth

func get_class():
	return "FGrabCloth"


const L0 = 0
const R0 = 1

const STAMINA = 0.2
const REACH = 325
const LEAN = 21*PI/180
const REACH_DOWN_LEN = 0.22
const HANDL_ANG = -0.2
const PULL2_START_TIME = 0.2
const PULL2_DURATION = 0.3
const END_DURATION = 0.3
const GRAB_OFFSET = Vector2(-23, 68)
const REACH_X_LIM = 420


var female : Human
var opponent : Human
var cloth
var isGrab
var isTear1
var isTear2
var grabTime
var done


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent
	

static func inReach(human):
	var grabOffset = GRAB_OFFSET - human.skeleton.handHipOffset[L0] - Vector2.DOWN*human.skeleton.heightDiff
	var deltaPos = human.opponent.pos - human.pos + grabOffset
	return (deltaPos - human.skeleton.handBasePos[L0]).length() < REACH


func start():
	female.tire(0.5*STAMINA)
	female.setUseGlobalHandAngles(true)
	female.gruntSounds.playRandomDb(-3)
	isGrab = false
	isTear1 = false
	isTear2 = false
	grabTime = 0
	cloth = opponent.skeleton.hip.get_node("ClothF1")
	
	female.gruntSounds.playRandomDb(-3)
	
	setZOrder()


func canStop():
	return !isGrab


func isDone():
	return done


func perform(time, delta):
	female.slideFeet(delta, 0, 0)
	
	female.handAngles[L] = HANDL_ANG
	female.approachDefaultHandAng(delta, R)#handAngles[R] = 0.80
	
	var grabOffset = GRAB_OFFSET - female.skeleton.handHipOffset[L] - Vector2.DOWN*female.skeleton.heightDiff
	
	var outOfReach = ((opponent.pos + grabOffset) - (female.pos + female.skeleton.hipArmOffset[L])).length() > REACH
	if time > 0.17 && !isGrab && outOfReach:
		done = true
	if done:
		return
	
	if !isGrab:
		female.targetHeight = 0.72*female.downHeight
		female.targetAbAng = LEAN
		var handPos
		if time < REACH_DOWN_LEN:
			handPos = grabOffset + Vector2(-60, 5)
		else:
			handPos = grabOffset
			if (female.handGlobalPos[L] - female.targetGlobalHandPos[L]).length_squared() < 50:
				if opponent.perform(FGrabClothRec.new(opponent, self)):
					setZOrder()
				else:
					done = true
					return
				female.tire(0.5*STAMINA)
				female.setHandLMode(FConst.HANDL_TWIST)
				var mpoly = opponent.get_node("polygons/Body")
				mpoly.get_node("ClothF").set_visible(false)
				mpoly.get_node("Bulge").set_visible(false)
				mpoly.get_node("ClothF_grab").set_visible(true)
				isGrab = true
				cloth.physActive = false
				cloth.get_node("ClothF2").physActive = false
				cloth.get_node("ClothF2/ClothF3").physActive = false
		handPos.y += opponent.pos.y
		handPos.x += female.pos.x + min(REACH_X_LIM, opponent.pos.x - female.pos.x)
		female.targetGlobalHandPos[L] = handPos
		
	else:
		grabTime += delta
		
		female.pushAway(delta, female.opponent.pos.x - 250)
		
		if !isTear2:
			female.targetAbAng = 0
			cloth.position = opponent.femaleGlobalHandPos(L) - opponent.pos + Vector2(25, -30)
			
			if grabTime > 0.2 && !isTear1:
				isTear1 = true
				female.game.tearSounds.playRandom()
			
			if grabTime > PULL2_START_TIME + PULL2_DURATION && !isTear2:
				isTear2 = true
				female.game.tearSounds.playRandom()
				opponent.removeCloth()
				female.setHandLMode(FConst.HANDL_OPEN)
			
			var holdPos = grabOffset + Vector2(-125, -20)
			holdPos.x += female.pos.x + min(REACH_X_LIM, opponent.pos.x - female.pos.x)
			
			if grabTime > PULL2_START_TIME:
				var dt = grabTime - PULL2_START_TIME
				var amt = dt/PULL2_DURATION
				holdPos += (amt - 3.0*amt*amt)*Vector2(25, 3)
			
			female.targetGlobalHandPos[L] = holdPos
			female.targetHeight = 0
		else:
			female.targetGlobalHandPos[L] = null
			if grabTime > PULL2_START_TIME + PULL2_DURATION + END_DURATION:
				done = true
	
	if grabTime > PULL2_START_TIME + 0.2:
		female.targetSpeed = -0.8*female.walkSpeed
		female.approachTargetSpeed(delta)
		female.walk(delta)
	
	
	#female.approachTargetHandPos(delta)
	female.approachTargetHandPos((0.6 if outOfReach else 1.0)*delta)
	
	female.approachTargetHeight(delta)
	female.approachTargetAbAng(delta)
	
	female.breathe(delta, true)


func stop():
	female.targetGlobalHandPos = [null, null]
	female.targetAbAng = 0
	female.targetGlobalHandPos[L] = null
	female.setUseGlobalHandAngles(false)
	female.handAngles[L] = 0
	female.handAngles[R] = 0
	female.setIsTurn(false)


func setZOrder():
	female.setZOrder([-2,-1,0,1,2])
	opponent.setZOrder([-4,-5,-2,3,4])
	var clothIndex = opponent.get_node("polygons/LegL").z_index + 5
	opponent.get_node("polygons/Body/ClothF_grab").z_index = clothIndex
	female.get_node("polygons/ArmL/Foreward/Twist").z_index = clothIndex


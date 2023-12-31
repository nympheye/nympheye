extends Action
class_name MGrabArms

func get_class():
	return "MGrabArms"


const STAMINA = 0.35
const LIFT_TIME = 1.1
const SHIFT_TIME = 0.7
const REACH = [460, 380]
const GRAB_SEPARATION = 280
const HOLD_SEPARATION = 235
const GRAB_START_POS = [Vector2(10, -70), Vector2(180, -50)]
const UP_POS = [Vector2(-110, -350), Vector2(-70, -490)]
const LIFT_MHEIGHT = 130
const FSHIFT = Vector2(40, -35)
const MSHIFT = Vector2(-70, 0)
const HAND_ANGLE_UP_OFFSET = [0.5, -0.8]
const HAND_ANGLE_DOWN_OFFSET = [-3.0, -2.5]
const SHIFT_AB_ANG = 0.3
const HAND_REL_SHIFT_UP = [Vector2(-30, 25), Vector2(-20, 27)]
const HAND_REL_SHIFT_DOWN = [Vector2(-30, 20), Vector2(-30, 10)]


var male
var opponent
var opponentStartPos
var isGrab
var grabTime
var isStart
var done


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent
	done = false


func start():
	isGrab = [false, false]
	isStart = true
	grabTime = 0
	setZOrder()
	opponentStartPos = opponent.pos
	male.tire(0.5*STAMINA)
	male.gruntSounds.playRandomDb(-2)
	var pen = male.skeleton.hip.get_node("Penis_back")
	pen.vel = Vector2.ZERO
	pen.set_rotation_degrees(-145)


func canStop():
	return true

func isDone():
	return done


func perform(time, delta):
	if done:
		return
	
	male.breathe(delta, true)
	male.targetErect = 1.0
	male.targetAbAng = 0
	male.targetHeight = 0
	
	if isGrab[L] && isGrab[R]:
		grabTime += delta
	
	if grabTime <= 0 && time > 0.7:
		done = true
		return
	
	var fwristPos = [0, 0]
	for i in [L,R]:
		var other = ~i & 1
		
		fwristPos[i] = male.femaleGlobalHandPos(other)
		
		if isGrab[i]:
			var farmAng = opponent.skeleton.forearmAbsAngle[other]
			var farmVect = Vector2(cos(farmAng), sin(farmAng))
			var farmOrthoVect = Vector2(-farmVect.y, farmVect.x)
			
			var handAngle
			if !opponent.isArmsUp:
				handAngle = HAND_ANGLE_DOWN_OFFSET[i]
				if male.isBack:
					handAngle += 0.9
			else:
				handAngle = HAND_ANGLE_UP_OFFSET[i]
			
			if opponent.isArmsUp:
				fwristPos[i] += HAND_REL_SHIFT_UP[i].x*farmVect + HAND_REL_SHIFT_UP[i].y*farmOrthoVect
			else:
				fwristPos[i] += HAND_REL_SHIFT_DOWN[i].x*farmVect + HAND_REL_SHIFT_DOWN[i].y*farmOrthoVect
			
			male.handGlobalPos[i] = fwristPos[i] - male.skeleton.handHipOffset[i]
			male.handAngles[i] = handAngle + farmAng - male.skeleton.forearmAbsAngle[i]
	
	var outOfReach = false
	for i in [L,R]:
		var other = ~i & 1
		if !isGrab[i]:
			if (male.handGlobalPos[i] + male.skeleton.handHipOffset[i] - fwristPos[i]).length() < 60:
				isGrab[i] = true
				if isGrab[other]:
					male.tire(0.5*STAMINA)
					male.autoArmRUp = false
				else: 
					if !opponent.perform(MGrabArmsRec.new(opponent)):
						terminate()
						return
					setZOrder()
				if i == L:
					male.setHandLMode(MConst.HANDL_LIFT1)
					var zindex = opponent.get_node("polygons/ArmR").z_index + opponent.get_node("polygons/ArmR/ForearmR").z_index
					male.get_node("polygons/Back/HandL_grab_lift0").z_index = zindex + 3
					male.get_node("polygons/ArmL/HandL_grab_lift0").z_index = zindex + 3
				else:
					male.setHandRMode(MConst.HANDR_GRAB_CLOTH)
					var zindex = Utility.getAbsZIndex(opponent.get_node("polygons/ArmL/ForearmL"))
					male.get_node("polygons/ArmR/HandR_grab_cloth1").z_index = zindex - 10
					male.get_node("polygons/ArmR/HandR_grab_cloth2").z_index = zindex + 10
			
			var shoulderPos = male.pos + male.skeleton.torsoBasePos + male.skeleton.shoulderBasePos[i]
			var reachVect = fwristPos[i] - shoulderPos
			var reachVectLen = reachVect.length()
			male.targetGlobalHandPos[i] = shoulderPos + 0.88*min(REACH[i], reachVectLen)*reachVect/reachVectLen - male.skeleton.handHipOffset[i]
			outOfReach = reachVectLen > REACH[i]
			if time > 0.4 && outOfReach:
				done = true
				terminate()
				return
	
	var separation
	var fPosX
	
	if !isGrab[L] || !isGrab[R]:
		male.walk(delta*(0.3 if isGrab[L] || isGrab[R] else 0.8))
	else:
		var targetFootPosL = Vector2(opponentStartPos.x - 200, 40)
		var targetFootPosR = Vector2(opponentStartPos.x + 435, -14)
		if grabTime > 0.2:
			male.moveFoot(delta, L, targetFootPosL.x)
			male.footLandPos[L] = targetFootPosL.y
		if grabTime > 0.64:
			male.moveFoot(1.8*delta, R, targetFootPosR.x)
			male.footLandPos[R] = targetFootPosR.y
			
			
	
	if grabTime < LIFT_TIME:
		if grabTime > 0.2 && !male.isBack:
			male.setIsTurn(false)
			male.setIsBack(true)
			male.get_node("polygons/Back/Penis").z_index = Utility.getAbsZIndex(opponent.get_node("polygons/Body/Body/VagR")) - 1
		
		fPosX = 0
		
		if grabTime < 0.1:
			separation = GRAB_SEPARATION
			male.targetHeight = 40 + 0.8*opponent.pos.y
		else:
			separation = HOLD_SEPARATION
			male.targetHeight = LIFT_MHEIGHT
		
		if time > 0.15 && !male.isBack:
			male.setIsTurn(true)
		
		for i in [L,R]:
			if isGrab[i]:
				var raiseAmt = min(1, grabTime/1.2)
				opponent.targetGlobalHandPos[i] = opponentStartPos + (1-raiseAmt)*GRAB_START_POS[i] + raiseAmt*(UP_POS[i] - Female.UP_SHIFT)
				if opponent.isArmsUp:
					opponent.targetGlobalHandPos[i] += Female.UP_SHIFT
				if raiseAmt > 0.32 && !opponent.isArmsUp:
					opponent.setArmsUp(true)
					opponent.setZOrder([-7,-6,-1,4,0])
					male.setHandLMode(MConst.HANDL_LIFT2)
					var zindex = male.get_node("polygons/Back/HandL_grab_lift0").z_index
					male.get_node("polygons/Back/HandL_grab_lift").z_index = zindex + 3
					
		
	else:
		var dt = grabTime - LIFT_TIME
		var amt = min(1, dt/SHIFT_TIME)
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		
		male.targetAbAng = SHIFT_AB_ANG*amt
		male.targetHeight = LIFT_MHEIGHT + amt*MSHIFT.y
		separation = HOLD_SEPARATION + amt*MSHIFT.x
		
		fPosX = amt*FSHIFT.x
		for i in [L,R]:
			opponent.targetGlobalHandPos[i] = Vector2(UP_POS[i].x + opponentStartPos.x + fPosX, UP_POS[i].y + amt*FSHIFT.y)
	
	if !isGrab[L] || !isGrab[R]:
		male.approachTargetHandPos(0.5*delta if outOfReach else delta)
		opponentStartPos = opponent.pos
	male.approachTargetHeight(delta)
	male.approachTargetAbAng(delta)
	male.approachTargetPosX(1.5*delta, opponent.pos.x + separation)
	
	if grabTime > LIFT_TIME + SHIFT_TIME + 0.2:
		male.performMGrabArmsPen(male)


func setZOrder():
	male.setZOrder([-5,-4,1,2,3])
	opponent.setZOrder([-7,-6,-1,4,5])


func terminate():
	male.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
	male.targetGlobalHandPos= [null, null]
	male.setHandRMode(MConst.HANDR_OPEN)
	male.setIsBack(false)
	male.setIsTurn(false)
	if opponent.isPerforming("MGrabArmsRec"):
		opponent.action.done = true
		opponent.stopAction()


func stop():
	male.footLandPos = [0, 0]
	if !done:
		terminate()


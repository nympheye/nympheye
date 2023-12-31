extends Action
class_name FPunchBalls

func get_class():
	return "FPunchBalls"


const STAMINA = 0.45
const PUNCH_ACCEL = 15000
const DECEL_DIST = 45
const START_TIME = 0.5
const HANDL_START_SHIFT = Vector2(-25, -15)
const PUSH_TIME = START_TIME + 1.8
const END_TIME = PUSH_TIME + 1.0
const PUSH_DURATION = 0.65
const START_POS = Vector2(-190, 130)
const PUNCH_POS = Vector2(22, 99)
const PUSH_SHIFT = Vector2(6, -2)
const TURNDIST = 10
const LEAN_ANG = 13*PI/180
const START_HANDR_ANG = 0.3
const PUNCH_HANDR_ANG = -0.1
const END_HANDR_ANG = -0.3


var female
var opponent
var fhandStartPos
var opponentHandEndPos
var decelTime
var isStuck
var isDecel
var isDone
var isPushSound


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	female.tire(STAMINA)
	female.stabbedBalls = true
	female.handVel[R] = Vector2.ZERO
	female.face.setAngry(0.5)
	
	decelTime = 0.0
	isStuck = false
	isDone = false
	isDecel = false
	isPushSound = false
	fhandStartPos = [female.handGlobalPos[L], female.handGlobalPos[R]]
	
	female.setZOrder([-2,-1,0,1,2]) # -2 == -2
	opponent.setZOrder([-3,-4,-2,3,4])
	female.get_node("polygons/ArmR/Knife2").z_index = female.get_node("polygons/ArmR").z_index
	


func canStop():
	return isDone

func isDone():
	return isDone


func perform(time, delta):
	
	female.approachTargetPosX(delta, opponent.pos.x - (280 if time < START_TIME else 260))
	
	female.targetHeight = 120
	female.approachTargetHeight(delta)
	
	if time > START_TIME - 0.12:
		female.targetAbAng = LEAN_ANG
		female.approachTargetAbAng(delta)
	
	if isDecel:
		decelTime += delta
		var crushAmt = min(1.0, decelTime/0.2)
		opponent.ball[L].setScale(1 - 0.11*crushAmt, 1 + 0.40*crushAmt)
	
	var punchPos = female.handGlobalPos[L] + female.skeleton.handHipOffset[L] + PUNCH_POS
	
	if time < START_TIME:
		var amt = time/START_TIME
		var amt2 = amt*amt
		var amt3 = amt2*amt
		
		var handAmt = 0.5*amt + 0.5*(3.0*amt2 - 2.0*amt3)
		
		female.targetGlobalHandPos[L] = fhandStartPos[L] + handAmt*HANDL_START_SHIFT
		
		var startPos = punchPos + (START_POS - PUNCH_POS)#female.handGlobalPos[L] + female.skeleton.handHipOffset[L] + START_POS
		female.targetGlobalHandPos[R] = (1-handAmt)*fhandStartPos[R] + handAmt*startPos
		
		female.approachTargetHandPos(0.6*delta)
		
		female.setUseGlobalHandAngles(true)
		female.approachTargetHandAng(0.5*delta, R, START_HANDR_ANG)
		
		if amt > 0.5:
			female.setHandRMode(FConst.HANDR_KNIFE)
		
	elif time < PUSH_TIME:
		female.approachTargetHandAng(delta, R, PUNCH_HANDR_ANG)
		
		if !isStuck:
			var shift = punchPos - female.handGlobalPos[R]
			var shiftLen = shift.length()
			var shiftDir = shift/shiftLen
			if !isDecel && shiftLen < DECEL_DIST:
				isDecel = true
				female.game.punchSounds.play(2)
				opponent.gaspSounds.play(1)
				opponent.face.setShock(0.0)
				opponent.ball[R].recDamage(1.0)
				opponent.ball[L].recDamage(1.0)
				opponent.tire(1.0)
				opponent.targetGlobalHandPos[L] = opponent.pos + Vector2(10, 70)
			if !isDecel:
				female.handVel[R] += delta*PUNCH_ACCEL*shiftDir
				female.handGlobalPos[R] += delta*female.handVel[R]
				if !female.isTurn && female.handGlobalPos[R].x - female.pos.x > TURNDIST:
					female.setIsTurn(true)
			else:
				var speed = female.handVel[R].length()
				var accelRate = 1.2*speed*speed/(2*shiftLen)
				if speed > delta*accelRate && shiftLen-6 > delta*speed:
					female.handVel[R] -= delta*accelRate*female.handVel[R]/speed
					female.handGlobalPos[R] += delta*female.handVel[R]
				else:
					female.handVel[R] = Vector2.ZERO
					female.handGlobalPos[R] = punchPos
					isStuck = true
					opponent.targetAbAng = -0.14
					female.game.kickKillSounds.playRandom()
					opponent.groin.crushSounds.playRandomDb(2)
				
	elif time < END_TIME:
		var amt = (time - PUSH_TIME)/PUSH_DURATION
		amt = min(1.0, amt)
		var amt2 = amt*amt
		
		if amt > 0.6 && !isPushSound:
			isPushSound = true
			opponent.gaspSounds.play(3)
			
		
		if amt > 0.2:
			opponent.targetGlobalHandPos[L] = opponentHandEndPos
		else:
			opponentHandEndPos = opponent.targetGlobalHandPos[L] + Vector2(0, 8)
		
		if amt > 0.3:
			opponent.targetAbAng = -0.25
			opponent.action.maxLegsClosed = 1.0
		
		if amt > 0.8:
			opponent.setHandLMode(MConst.HANDL_OPEN)
		
		var push = 2.6*amt - 2.0*amt2 + 0.4*amt2*amt2
		female.handGlobalPos[R] = punchPos + push*PUSH_SHIFT
		female.handAngles[R] = (1-push)*PUNCH_HANDR_ANG + push*END_HANDR_ANG
	else:
		isDone = true
	
	


func stop():
	female.setUseGlobalHandAngles(false)
	opponent.perform(FUnstabBallsRec.new(opponent, 1.4))
	opponent.ball[L].physActive = true
	opponent.get_node("polygons/Body/Balls").set_visible(false)
	opponent.ball[L].crush()
	opponent.ball[R].crush()


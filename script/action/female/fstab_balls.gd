extends Action
class_name FStabBalls

func get_class():
	return "FStabBalls"


const STAMINA = 0.45
const STAB_ACCEL = 15000
const DECEL_DIST = 25
const STAB_DELAY = 0.5
const PUSH_DELAY = STAB_DELAY + 1.8
const PUSH_TIME = 0.60
const STAB_POS = Vector2(-35, 82)
const PUSH_SHIFT = Vector2(28, 8)
const PUSH_RATE = 1.0/PUSH_TIME
const TURNDIST = 10
const LEAN_ANG = 13*PI/180
const STAB_ANG = 13*PI/180
const END_ANG = -4*PI/180


var female
var opponent
var isStuck
var isDecel
var isBloodKnife
var isBlood2
var isSetKnifeZ
var isDone
var startKnifeAng
var linePoly


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent


func start():
	female.tire(STAMINA)
	linePoly = opponent.get_node("polygons/Body/Balls/Balls_line")
	female.handVel[R] = Vector2.ZERO
	female.handGlobalPos[R] = female.pos
	female.face.setAngry(0.5)
	startKnifeAng = female.handAngles[R]
	isStuck = false
	isBloodKnife = false
	isBlood2 = false
	isSetKnifeZ = false
	isDone = false
	isDecel = false
	female.setZOrder([-2,-1,3,4,5]) # -2 == -2
	opponent.setZOrder([-4,-5,-2,1,2])
	female.get_node("polygons/ArmR/Knife2").z_index = female.get_node("polygons/ArmR").z_index
	female.stabbedBalls = true


func canStop():
	return isDone

func isDone():
	return false


func perform(time, delta):
	
	female.approachTargetPosX(delta, opponent.pos.x - (280 if time < PUSH_DELAY else 270))
	
	if time > STAB_DELAY - 0.12:
		female.targetAbAng = LEAN_ANG
		female.approachTargetAbAng(delta)
	
	if time > STAB_DELAY:
		female.handAngles[R] = startKnifeAng + min(STAB_ANG, (time-STAB_DELAY)*5.0)
		
		if !isSetKnifeZ && time-STAB_DELAY > 0.1:
			isSetKnifeZ = true
			var ballIndex = opponent.get_node("polygons/Body").z_index + \
				opponent.get_node("polygons/Body/Balls").z_index
			var poly = female.get_node("polygons/ArmR")
			poly.get_node("Knife2").z_index = ballIndex - 1
			poly.get_node("Knife2_blood").z_index = ballIndex - 1
		
		var stabPos = female.handGlobalPos[L] + female.skeleton.handHipOffset[L] + STAB_POS
		
		if time < PUSH_DELAY:
			if !isStuck:
				var shift = stabPos - female.handGlobalPos[R]
				var shiftLen = shift.length()
				var shiftDir = shift/shiftLen
				if !isDecel && shift.x < DECEL_DIST:
					isDecel = true
					female.game.cutSounds.playRandom()
					opponent.gaspSounds.play(1)
					opponent.face.setShock(0.0)
					opponent.ball[R].recDamage(1.0)
					opponent.ball[L].recDamage(1.0)
					opponent.tire(1.0)
					opponent.targetGlobalHandPos[L] = opponent.pos + Vector2(10, 70)
				if !isDecel:
					female.handVel[R] += delta*STAB_ACCEL*shiftDir
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
						female.handGlobalPos[R] = stabPos
						isStuck = true
						opponent.bleed(null, Vector2(-50, 123), false, female.get_node("polygons/ArmR"), 100, 0.15)
						opponent.targetAbAng = -0.14
					
		else:
			var push = min(1, PUSH_RATE*(time-PUSH_DELAY))
			if push == 1:
				isDone = true
			if !isBloodKnife && push > 0.2:
				isBloodKnife = true
				female.bloodyKnife()
				female.game.slideSounds.play(1)
				opponent.targetGlobalHandPos[L] = opponent.targetGlobalHandPos[L] + Vector2(0, 8)
			if !isBlood2 && push > 0.8:
				isBlood2 = true
				opponent.bleed(null, Vector2(-16, 104), true, female.get_node("polygons/ArmR/Knife2"), 50, 0.0)
				opponent.gaspSounds.play(3)
				opponent.setHandLMode(MConst.HANDL_OPEN)
			var lineOpacity = max(0, min(1, 4.0*(push-0.4)))
			if lineOpacity > 0:
				linePoly.set_visible(true)
				linePoly.color.a = lineOpacity
			if push > 0.3:
				opponent.targetAbAng = -0.25
				opponent.action.maxLegsClosed = 1.0
			var push2 = push*push
			push = 2.6*push - 2.0*push2 + 0.4*push2*push2
			female.handGlobalPos[R] = stabPos + push*PUSH_SHIFT
			female.handAngles[R] = startKnifeAng + STAB_ANG + push*(END_ANG - STAB_ANG)


func stop():
	pass


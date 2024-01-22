extends Action
class_name FStab

func get_class():
	return "FStab"


const AB = 0
const ARMR = 1

const STARTLEN = 0.27
const STABLEN = 0.07
const ENDLEN = 0.21
const LEN = STARTLEN + STABLEN + ENDLEN

const STAMINA = 0.25
const MAXDIST = 395
const MAXHIPDIST = 125
const LIFT = 0
const MAXHIPDROP = 60
const OFFHANDDIST = -55
const MAXLEANANG = 20*PI/180
const TURNDIST = 0.40*MAXDIST
const SLASHMOVE = Vector2(-10, 3)
const TURNSHIFTL = Vector2(-10, 0)
const TURNSHIFTR = Vector2(20, 5)
const HANDANG = 40*PI/180


var female
var opponent

var target
var dist
var lift
var hipDist
var hipDrop
var leanAng

var isTurn
var isHit
var sound1


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent
	isHit = null
	sound1 = false


func canStop():
	return true

func isDone():
	return time > LEN


func start():
	isTurn = false
	female.tire(STAMINA)
	female.setHandLMode(FConst.HANDL_OPEN)
	
	setZOrder()
	
	if opponent.isRecoiling() || getTargetBasePos(AB).x > female.pos.x + 450:
		target = ARMR
	else:
		target = AB
	
	female.setKnifeZOrder(opponent.get_node("polygons/Body").z_index)


func perform(time, delta):
	female.setIsTurn(time > 0.4*STARTLEN && time < LEN-0.1)
	female.slideFeet(delta, 0, 0)
	
	var deltaPos = getTargetBasePos(target)
	deltaPos -= female.slidePos + TURNSHIFTR + \
			female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN
	dist = min(MAXDIST, deltaPos.x)
	lift = -deltaPos.y
	hipDist = min(MAXHIPDIST, 0.5*(deltaPos.x - 150))
	hipDrop = min(MAXHIPDROP, 0.3*(deltaPos.x - 100))
	leanAng = min(MAXLEANANG, 0.001*(deltaPos.x - 130))
	
	var handShift = Vector2(0, 0)
	var hipShift = Vector2(0, 0)
	var bodyAng = 0
	var offhandShift = Vector2(0, 0)
	
	if time < STARTLEN:
		var ratio = time/STARTLEN
		var cosTerm = 0.5*(1 - cos(0.5*ratio*2*PI))
		handShift = Vector2(dist*ratio*ratio, -lift*ratio*ratio)
		hipShift = Vector2(hipDist*cosTerm, hipDrop*cosTerm)
		offhandShift = Vector2(OFFHANDDIST*cosTerm, 0)
		bodyAng = leanAng*cosTerm
		female.handAngles[R] = cosTerm*HANDANG
		if ratio > 0.3 && !sound1:
			sound1 = true
			female.game.swingSounds.playRandom()
	elif time < STARTLEN + STABLEN:
		if isHit == null:
			isHit = checkHit()
			if isHit:
				if opponent.perform(FStabRec.new(opponent, self)):
					setZOrder()
				else:
					if target == AB:
						opponent.recStabAb()
					elif target == ARMR:
						opponent.recStabArmR()
		
		var ratio = (time - STARTLEN)/STABLEN
		handShift = Vector2(dist, -lift) + ratio*SLASHMOVE
		hipShift = Vector2(hipDist, hipDrop)
		offhandShift = Vector2(OFFHANDDIST, 0)
		bodyAng = leanAng
		female.handAngles[R] = HANDANG
	else:
		var dt = time - (STARTLEN + STABLEN)
		var ratio = dt/ENDLEN
		var cosTerm = 0.5*(1 + cos(0.5*ratio*2*PI))
		handShift = (1 - ratio)*(Vector2(dist, -lift) + SLASHMOVE)
		hipShift = Vector2(hipDist*cosTerm, hipDrop*cosTerm)
		offhandShift = Vector2(OFFHANDDIST*cosTerm, 0)
		bodyAng = leanAng*cosTerm
		if ratio > 0.4:
			female.approachDefaultHandAng(delta, R)
	
	if female.isTurn:
		offhandShift += TURNSHIFTL
		handShift += TURNSHIFTR
	
	female.pos = female.slidePos + hipShift
	female.handGlobalPos = [female.pos + offhandShift, female.slidePos + handShift]
	female.skeleton.abdomen.set_rotation(bodyAng)
	female.skeleton.neck.set_rotation(-bodyAng/2)


func stop():
	female.setIsTurn(false)


func getTargetBasePos(targetType):
	if targetType == AB:
		return opponent.pos + Vector2(-56, -18)
	elif targetType == ARMR:
		var separation = clamp(0.006*(opponent.handGlobalPos[R].x - female.pos.x - 560), 0, 1)
		var armAng = opponent.skeleton.forearmAbsAngle[R]
		var armVect = Vector2(cos(armAng), sin(armAng))
		return opponent.handGlobalPos[R] + opponent.skeleton.handHipOffset[R] + (-30 + 100*separation)*armVect


func checkHit():
	var delta = opponent.femaleGlobalHandPos(R) - getTargetBasePos(target)
	return delta.length() < 35


func setZOrder():
	opponent.setZOrder([-5,-4,0,3,4])
	female.setZOrder([-2,-1,0,1,2])

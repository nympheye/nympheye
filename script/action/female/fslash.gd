extends Action
class_name FSlash

func get_class():
	return "FSlash"


const LEN = 0.6
const STARTLEN = 0.45*LEN
const SLASHLEN = 0.2*LEN
const ENDLEN = 0.35*LEN

const STAMINA = 0.30
const REACH = 455
const MAXDIST = 395
const MAXHIPDIST = 125
const LIFT = 0
const MAXHIPDROP = 130
const OFFHANDDIST = -55
const MAXLEANANG = 20*PI/180
const TURNDIST = 0.40*MAXDIST
const HANDANG = 35*PI/180
const SLASHANG = -0.6*HANDANG
const SLASHMOVE = Vector2(-20, 3)
const TURNSHIFTL = Vector2(-10, 0)
const TURNSHIFTR = Vector2(20, 5)


var female
var opponent

var targetCloth
var targetPen
var targetPenSide
var targetPenHead
var targetPenBottom
var targetBallL
var targetBallR

var dist
var lift
var hipDist
var hipDrop
var leanAng

var done
var isTurn
var isHit
var sound1


func _init(femaleIn).(femaleIn):
	female = femaleIn
	opponent = female.opponent
	isHit = null
	sound1 = false
	done = false
	
	targetCloth = false
	targetPen = false
	targetPenSide = false
	targetPenHead = false
	targetPenBottom = false
	targetBallL = false
	targetBallR = false
	
	var exposedL = opponent.ball[L].isExposed && !opponent.ball[L].isSevered
	var exposedR = opponent.ball[R].isExposed && !opponent.ball[R].isSevered
	if opponent.erectLevel >= opponent.penPoly.size() - 2 && randf() < 0.7:
		if opponent.hasCloth:
			targetCloth = true
		else:
			targetPen = true
	elif opponent.hasCloth:
		if opponent.pen1.isCutSide || randf() < 0.66:
			targetCloth = true
		else:
			targetPen = true
	elif randf() < (0.15 if opponent.pen1.isCutHead else 0.38):
		targetPen = true
	else:
		var canTargetL = !opponent.ball[L].isSevered && !opponent.ball[L].isCrushed
		var canTargetR = !opponent.ball[R].isSevered && !opponent.ball[R].isCrushed
		if canTargetL && canTargetR:
			if randf() < 0.5:
				targetBallL = true
			else:
				targetBallR = true
		elif canTargetL:
			targetBallL = true
		elif canTargetR:
			targetBallR = true
		else:
			targetPen = true


func canStop():
	return true

func isDone():
	return time > LEN || done


func start():
	isTurn = false
	female.tire(0.5*STAMINA)
	
	setZOrder()
	female.setHandLMode(FConst.HANDL_OPEN)
	
	var index
	if targetCloth:
		index = opponent.get_node("polygons/Body").z_index + 1
	elif targetPen:
		if opponent.hasCloth:
			index = opponent.get_node("polygons/Body").z_index + 10
			targetPenSide = true
		else:
			index = opponent.get_node("polygons/Body/Penis").z_index
			if opponent.erectLevel >= opponent.penPoly.size() - 2:
				targetPenBottom = true
			elif opponent.erectLevel <= 5 && !opponent.pen1.isCutHead && randf() < (0.80 if opponent.pen1.isCutSide else 0.38):
				targetPenHead = true
			else:
				targetPenSide = true
	elif targetBallL:
		index = opponent.get_node("polygons/Body/BallL").z_index
	elif targetBallR:
		index = opponent.get_node("polygons/Body/BallR").z_index
	
	female.setKnifeZOrder(index + 1)


func perform(time, delta):
	female.setIsTurn(time > 0.4*STARTLEN && time < LEN-0.1)
	female.slideFeet(delta, 0, 0)
	
	female.targetHeight = 25 + 0.6*opponent.pos.y
	female.approachTargetHeight(delta)
	
	var targetOffset = getTargetOffset()
	
	var deltaPos = opponent.pos - (female.slidePos + TURNSHIFTR + \
			female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN)
	dist = min(MAXDIST, deltaPos.x + targetOffset.x)
	lift = -deltaPos.y - targetOffset.y
	
	var reachVect = Vector2(dist, -lift) - female.skeleton.hipArmOffset[R]
	var outOfReach = reachVect.length() > REACH
	if time > 0.17 && time < STARTLEN + SLASHLEN && outOfReach:
		done = true
	
	hipDist = min(MAXHIPDIST, 0.5*(deltaPos.x - 150))
	hipDrop = min(MAXHIPDROP, 0.25*(deltaPos.x - 100))
	leanAng = min(MAXLEANANG, 0.001*(deltaPos.x - 130))
	
	var handShift = Vector2(0, 0)
	var hipShift = Vector2(0, 0)
	var bodyAng = 0
	var offhandShift = Vector2(0, 0)
	var handAng = 0
	
	if time < STARTLEN:
		var ratio = time/STARTLEN
		var cosTerm = 0.5*(1 - cos(0.5*ratio*2*PI))
		handShift = Vector2(dist*ratio*ratio, -lift*ratio*ratio)
		hipShift = Vector2(hipDist*cosTerm, hipDrop*cosTerm)
		offhandShift = Vector2(OFFHANDDIST*cosTerm, 0)
		bodyAng = leanAng*cosTerm
		handAng = cosTerm*HANDANG
		if ratio > 0.3 && !sound1:
			sound1 = true
			female.game.swingSounds.playRandom()
	elif time < STARTLEN + SLASHLEN:
		if isHit == null:
			isHit = false
			if checkHit(targetOffset):
				if opponent.isBlockingLow():
					opponent.recStabArmL()
				elif opponent.perform(FSlashRec.new(opponent, self)):
					isHit = true
					female.tire(0.5*STAMINA)
					setZOrder()
		
		var ratio = (time - STARTLEN)/SLASHLEN
		handShift = Vector2(dist, -lift) + ratio*SLASHMOVE
		hipShift = Vector2(hipDist, hipDrop)
		offhandShift = Vector2(OFFHANDDIST, 0)
		bodyAng = leanAng
		handAng = HANDANG + ratio*SLASHANG
	else:
		var dt = time - (STARTLEN + SLASHLEN)
		var ratio = dt/ENDLEN
		var cosTerm = 0.5*(1 + cos(0.5*ratio*2*PI))
		handShift = (1 - ratio)*(Vector2(dist, -lift) + SLASHMOVE)
		hipShift = Vector2(hipDist*cosTerm, hipDrop*cosTerm)
		offhandShift = Vector2(OFFHANDDIST*cosTerm, 0)
		bodyAng = leanAng*cosTerm
		handAng = (1 - ratio)*(HANDANG + SLASHANG)
	
	if female.isTurn:
		offhandShift += TURNSHIFTL
		handShift += TURNSHIFTR
	
	female.pos = female.slidePos + hipShift
	female.handGlobalPos = [female.pos + offhandShift, female.slidePos + handShift]
	female.skeleton.abdomen.set_rotation(bodyAng)
	female.skeleton.neck.set_rotation(-bodyAng/2)
	female.handAngles[R] = handAng


func getTargetOffset():
	if targetCloth:
		return Vector2(-104, 20)
	elif targetPen:
		var penPos = opponent.pen2.get_global_position() - opponent.pos
		if targetPenSide:
			return penPos + Vector2(-86, 25)
		elif targetPenBottom:
			return penPos + Vector2(-48, 54)
		else:
			return penPos + Vector2(0, 30*(1 + 1.5*opponent.erect)).rotated(opponent.pen1.get_rotation()) + Vector2(-23, 35)
	elif targetBallL:
		return Vector2(-67, 95 + (15 if opponent.ball[L].isExposed else 0))
	elif targetBallR:
		return Vector2(-67, 95 + (13 if opponent.ball[R].isExposed else 0))


func stop():
	female.setIsTurn(false)


func checkHit(targetOffset):
	var delta = opponent.femaleGlobalHandPos(R).x - opponent.pos.x
	return abs(delta - targetOffset.x) < 35


func setZOrder():
	opponent.setZOrder([-5,-4,0,3,4])
	female.setZOrder([-2,-1,0,1,2])

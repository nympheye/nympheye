extends Action
class_name MPunch

func get_class():
	return "MPunch"


const FACE = 0
const BREAST = 1

const LEN = [0.34, 0.41]
const ACCELLEN = [0.50*LEN[L], 0.50*LEN[R]]
const ENDLEN = [LEN[L]-ACCELLEN[L], LEN[R]-ACCELLEN[R]]

const STAMINA = 0.33
const MAXDIST = [325, 325]
const LEFT_SEPARATION = 390
const HIPDIST = [-10, -130]
const HIP_DROP = [10, 95]
const OFFHANDDIST = 55
const LEANANG = [-5*PI/180, -20*PI/180]

const LIFT = 0


var male
var opponent

var target
var dist
var lift
var isTurn
var isHit
var punchTime
var punchStartPos
var soundTrigger
var hand
var offhand


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent
	isHit = null


func start():
	isTurn = false
	punchTime = null
	soundTrigger = false
	
	male.tire(STAMINA)
	male.gruntSounds.playRandom()
	
	if male.pos.x - opponent.pos.x < LEFT_SEPARATION:
		hand = L
		offhand = R
	else:
		hand = R
		offhand = L
	
	if (opponent.targetHeight - male.targetHeight < 50) && (randf() < 0.4 || male.targetHeight > 50):
		target = BREAST
	else:
		target = FACE


func canStop():
	return true

func isDone():
	return (punchTime != null && punchTime > LEN[hand]) || (punchTime == null && time > 0.4) || (opponent.pos.y > male.pos.y + 180)


func perform(time, delta):
	male.slideFeet(delta, 0, 0)
	
	var closeness = max(0, 700-(male.pos.x-opponent.pos.x))/(700-LEFT_SEPARATION)
	
	var deltaPos = getTargetBasePos(target)
	deltaPos -= male.slidePos + male.skeleton.handHipOffset[hand] - opponent.skeleton.heightDiff*Vector2.DOWN
	deltaPos.y += 0.12*male.pos.y
	deltaPos *= min(1, MAXDIST[hand]/deltaPos.length())
	deltaPos.x -= 10*closeness
	dist = deltaPos.x
	lift = -deltaPos.y
	
	var hipShift = Vector2(0, 0)
	var bodyAng = 0
	
	if punchTime == null:
		male.targetRelHandPos[hand] = Vector2(45 + 65*closeness, 0)
		male.approachTargetHandPos(delta)
		male.targetAbAng = 0
		if (male.handGlobalPos[hand] - (male.pos + male.targetRelHandPos[hand])).length() < 5:
			punchTime = 0
			punchStartPos = male.handGlobalPos[hand] - male.pos
			male.setZOrder([-5,-4,-3,3,4])
			opponent.setZOrder([-6,-1,0,1,2])
			if hand == R:
				male.setIsTurn(true)
	else:
		punchTime += delta
		if punchTime < ACCELLEN[hand]:
			var amt = punchTime/ACCELLEN[hand]
			var amt2 = amt*amt
			var amt4 = amt2*amt2
			var cosTerm = 0.5*(1 - cos(0.5*amt*2*PI))
			var handAmt = 0.3*amt2 + 0.7*amt4 
			var handShift = Vector2(dist*handAmt, -lift*handAmt)
			hipShift = Vector2(HIPDIST[hand]*cosTerm, HIP_DROP[hand]*cosTerm)
			var offhandShift = Vector2(OFFHANDDIST*cosTerm, 0)
			bodyAng = LEANANG[hand]*cosTerm
			male.handGlobalPos[hand] = male.pos + handShift + (1-amt)*punchStartPos
			male.handGlobalPos[offhand] = male.slidePos + offhandShift
			male.handVel[hand] = Vector2.ZERO
			if hand == R:
				male.setIsTurn(amt < 0.7)
			if amt > 0.3:
				if hand == L:
					male.setHandLMode(MConst.HANDL_FIST)
				else:
					male.setHandRMode(MConst.HANDR_FIST)
			if amt > 0.4 && !soundTrigger:
				soundTrigger = true
				male.owner.swingSounds.playRandom()
		else:
			var dt = punchTime - ACCELLEN[hand]
			var ratio = dt/ENDLEN[hand]
			var cosTerm = 0.5*(1 + cos(0.5*ratio*2*PI))
			hipShift = Vector2(HIPDIST[hand]*cosTerm, HIP_DROP[hand]*cosTerm)
			bodyAng = LEANANG[hand]*cosTerm
			male.targetGlobalHandPos[hand] = Vector2(min(dist + 200, 0), -lift) + male.pos
			male.targetGlobalHandPos[offhand] = null
			male.approachTargetHandPos(delta)
			checkHit()
		
		male.pos = male.slidePos + (1 - 0.7*closeness)*hipShift
		male.targetAbAng = (1 - 0.7*closeness)*bodyAng
		male.skeleton.neck.set_rotation(-male.skeleton.abdomen.get_rotation()/2)
		male.footAngles[L] = male.footAngles[L] + 0.003*hipShift.x
	
	male.approachTargetAbAng(1.3*delta)


func stop():
	male.targetGlobalHandPos = [null, null]
	male.setHandRMode(MConst.HANDR_OPEN)
	male.setHandLMode(MConst.HANDL_OPEN)
	male.setIsTurn(false)


func getTargetBasePos(targetType):
	if targetType == FACE:
		return opponent.pos + opponent.skeleton.getHeadPos() + Vector2(63, 15)
	if targetType == BREAST:
		return opponent.pos + opponent.skeleton.getChestPos() + Vector2(80, 15)
	

func checkHit():
	if isHit == null:
		var delta = getTargetBasePos(target) - opponent.maleGlobalHandPos(hand)
		isHit =  delta.length() < 37 && !opponent.isPerforming("FKickLow")
		if isHit:
			if target == FACE:
				opponent.recPunchFace()
				opponent.stopAction()
			elif target == BREAST:
				opponent.recPunchBreast()
				opponent.stopAction()


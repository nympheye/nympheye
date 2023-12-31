extends Action
class_name FCast

func get_class():
	return "FCast"


const TGT_BALL_L = 0
const TGT_BALL_R = 1
const TGT_PEN_HEAD = 2
const TGT_PEN_SIDE = 3
const TGT_PEN_BOTTOM = 4
const TGT_FACE = 5
const TGT_CLOTH = 6
const TGT_AB = 7
const TGT_MISS_LOW = 8

const TGT_CLASS_LOW = 0
const TGT_CLASS_HIGH = 1

const STARTLEN = 0.70
const CASTLEN = 0.02
const ENDLEN = 0.4
const LEN = STARTLEN + CASTLEN + ENDLEN

const STAMINA = 0.38
const MAXHIPDIST = 50
const MAXHIPDROP = 50
const OFFHAND_CAST_SHIFT = Vector2(-30, 0)
const MAXLEANANG = 16*PI/180
const TURNSHIFTL = Vector2(-10, 0)
const TURNSHIFTR = Vector2(20, 5)
const HANDANG_START = 32*PI/180
const HANDANG_CAST = 27*PI/180
const HANDR_START_POS = Vector2(15, 0)
const HANDR_ROTFRAC_START = 0.4
const HANDR_ROTFRAC_CAST = 0.8
const CAST_POS = Vector2(4, 65)
const BOLT_AMT = 0.2


var female
var opponent
var bolt

var glowPolyTop
var glowPolyBottom

var startHandRAng
var offhandStartPos

var isTurn
var isHit
var whooshed
var shot
var grunted
var doneCast
var tgtPosRand


func _init(femaleIn, targetClass).(femaleIn):
	female = femaleIn
	bolt = female.bolt
	bolt.targetClass = targetClass
	opponent = female.opponent
	whooshed = false
	shot = false
	grunted = false
	doneCast = false


func canStop():
	return true

func isDone():
	return time > LEN


func start():
	isTurn = false
	female.setHandLMode(FConst.HANDL_OPEN)
	female.targetGlobalHandPos = [null, null]
	female.setUseGlobalHandAngles(true)
	
	startHandRAng = female.handAngles[R]
	
	setZOrder()
	
	setEffectAmt(0.0)
	female.glowEffect.shaderDisabled = female.options.shadersDisabled
	
	glowPolyTop = female.get_node("polygons/ArmR/Glow_top")
	glowPolyBottom = female.get_node("polygons/ArmR/Glow_bottom")
	
	glowPolyTop.set_visible(true)
	glowPolyBottom.set_visible(true)
	setGlowOpacity(0.0)
	
	tgtPosRand = [2*randf() - 1, 2*randf() - 1]
	
	female.game.castSounds.play(1)
	
	if bolt.targetClass == TGT_CLASS_LOW:
		
		var ballL = opponent.ball[L]
		var ballR = opponent.ball[R]
		var exposedL = ballL.isExposed && !ballL.isSevered
		var exposedR = ballR.isExposed && !ballR.isSevered
		var erectExposed = clamp((opponent.erect - 0.85)/0.15, 0, 1)
		if randf() < 0.07:
			bolt.target = TGT_MISS_LOW
		elif randf() < 0.04:
			bolt.target = TGT_AB
		elif !opponent.hasCloth && opponent.erectLevel >= opponent.penPoly.size() - 2 && randf() < 0.5:
			bolt.target = TGT_PEN_BOTTOM
		elif opponent.hasCloth && randf() < (0.60 if opponent.isCutCloth else 0.25):
			bolt.target = TGT_CLOTH
		elif randf() < ((0.20 if opponent.pen1.isCutSide else 0.30) \
						- (0.15 if opponent.pen1.isCutHead else 0.0) \
						+ (0.25 if opponent.hasCloth else 0.0) \
						- (0.0 if opponent.hasCloth else 0.45*erectExposed)):
			bolt.target = TGT_PEN_SIDE
		elif !opponent.pen1.isCutHead && \
				randf() < ((0.22 if opponent.pen1.isCutSide else 0.10) \
							- (0.14 if opponent.hasCloth else 0.0)\
							+ 0.6*erectExposed):
			bolt.target = TGT_PEN_HEAD
		elif ballL.health <= 0 && ballR.health <= 0:
			bolt.target = TGT_PEN_SIDE if opponent.pen1.isCutHead else TGT_PEN_HEAD
		else:
			var weightL = 0.0 if ballL.health <= 0 else (1.0 if exposedL else 0.4)
			var weightR = 0.0 if ballR.health <= 0 else (1.0 if exposedR else 0.4)
			if randf() < weightL/(weightR + weightL):
				bolt.target = TGT_BALL_L
			else:
				bolt.target = TGT_BALL_R
		
	elif bolt.targetClass == TGT_CLASS_HIGH:
		
		bolt.target = TGT_FACE
	


func perform(time, delta):
	female.slideFeet(delta, 0, 0)
	
	var handTargetVect = getTargetBasePos(bolt.target)
	handTargetVect -= female.slidePos + TURNSHIFTR + \
			female.skeleton.handHipOffset[R] + female.skeleton.heightDiff*Vector2.DOWN
	var handTargetDist = handTargetVect.length()
	var handTargetDir = handTargetVect/handTargetDist
	
	female.face.setAngry(handTargetVect.angle() + 0.4)
	
	var baseHandAng = atan2(handTargetVect.y, handTargetVect.x)
	
	var targetHipShift = Vector2(min(MAXHIPDIST, 0.5*(handTargetVect.x - 150)), \
								min(MAXHIPDROP, 0.25*(handTargetVect.x - 100)))
	var targetLeanAng = min(MAXLEANANG, 0.001*(handTargetVect.x - 130))
	
	var leanAng = 0
	
	setEffectAmt(time/(STARTLEN + CASTLEN))
	
	if time < STARTLEN:
		female.tire(STAMINA*delta/STARTLEN)
		
		if opponent.pos.x - female.pos.x < 400 && bolt.targetClass == TGT_CLASS_HIGH:
			bolt.targetClass = TGT_CLASS_LOW
			bolt.target = TGT_AB
		
		var amt = time/STARTLEN
		var amt2 = amt*amt
		var amt3 = amt*amt2
		var amt4 = amt2*amt2
		var cosTerm = 0.5*(1 - cos(0.5*amt*2*PI))
		
		female.pos = female.slidePos + cosTerm*targetHipShift
		
		var eyePos = human.getEyePos()
		var eyeTargetDir = getEyeTargetDir(eyePos)
		var offhandStartDist = 240 - 50*max(0, -eyeTargetDir.y)
		offhandStartPos = eyePos + offhandStartDist*eyeTargetDir - female.skeleton.handHipOffset[L]
		offhandStartPos += Vector2(0, 10) - 0.9*targetHipShift
		
		var offhandAmt = 0.6*amt + 4.4*amt2 - 6.5*amt3 + 2.5*amt4
		female.targetRelHandPos = [offhandAmt*(offhandStartPos - female.pos), HANDR_START_POS]
		female.approachTargetHandPos(0.6*delta)
		leanAng = targetLeanAng*cosTerm
		
		female.handAngles[L] = female.skeleton.zeroAbsHandAngle[L]
		female.handAngles[R] = (1 - sqrt(amt))*startHandRAng + cosTerm*(HANDR_ROTFRAC_START*baseHandAng + HANDANG_START)
		
		female.glow.position = Vector2.ZERO
		female.glow.scale.x = 1.0
		setGlowOpacity(amt)
		
	elif time < STARTLEN + CASTLEN || !doneCast:
		var amt = (time - STARTLEN)/CASTLEN
		
		if amt >= 1.0:
			amt = 1.0
			doneCast = true
		
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var cosTerm = 0.5*(1 - cos(0.5*amt*2*PI))
		
		female.pos = female.slidePos + targetHipShift
		leanAng = targetLeanAng
		
		var closeness = clamp((handTargetDist - 80)/60, 0, 1)
		var castMoveMag = 300 - 50*closeness
		
		var offhandAmt = amt
		female.handGlobalPos[L] = offhandStartPos + offhandAmt*OFFHAND_CAST_SHIFT
		var handAmt = 0.3*amt + 0.7*amt2 - 0.0*amt4
		female.handGlobalPos[R] = female.slidePos + HANDR_START_POS + handAmt*castMoveMag*handTargetDir
		female.setIsTurn(amt > 0.6)
		if female.isTurn:
			female.handGlobalPos[L] += TURNSHIFTL
			female.handGlobalPos[R] += TURNSHIFTR
		
		var handAngAmt = sqrt(sqrt(amt))
		female.handAngles[R] = (1-handAngAmt)*(HANDANG_START + HANDR_ROTFRAC_START*baseHandAng) \
								+ handAngAmt*(HANDANG_CAST + HANDR_ROTFRAC_CAST*baseHandAng)
		
		if amt > 0.2 && !grunted:
			grunted = true
			female.gruntSounds.playRandomDb(-2)
		
		if amt > 0.3 && !whooshed:
			whooshed = true
			female.game.swingSounds.playRandom()
		
		if amt > 0.1:
			female.setHandRMode(FConst.HANDR_CAST)
		
		if amt > BOLT_AMT && !shot:
			shot = true
			human.bolt.z_index = Utility.getAbsZIndex(glowPolyTop)
			human.bolt.castFBolt(female.handGlobalPos[R] + CAST_POS, getTargetBasePos(bolt.target))
	else:
		var dt = time - (STARTLEN + CASTLEN)
		var amt = dt/ENDLEN
		var cosTerm = 0.5*(1 + cos(0.5*amt*2*PI))
		
		female.pos = female.slidePos + cosTerm*targetHipShift
		leanAng = cosTerm*targetLeanAng
		
		female.setUseGlobalHandAngles(false)
		female.approachDefaultHandAngs(delta)
		
		setGlowOpacity(0.0)
		
		if amt > 0.2:
			female.setDefaultHandRMode()
		
		female.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
		female.approachTargetHandPos(1.2*delta)
		if female.isTurn:
			female.setIsTurn(amt < 0.4)
			if !female.isTurn:
				female.handGlobalPos[L] -= TURNSHIFTL
				female.handGlobalPos[R] -= TURNSHIFTR
	
	if time > STARTLEN:
		var glowAmt = (time - STARTLEN)/0.09
		if glowAmt < 1:
			var glowCosTerm = 0.5*(1 - cos(0.5*glowAmt*2*PI))
			glowAmt = (1.33333333)*(glowCosTerm if glowAmt < 0.5 else 0.5 + 0.75*(glowAmt - 0.5))
			female.glow.position = 8.0*glowAmt*handTargetDir
			female.glow.scale.x = 1.0 + 2.0*glowAmt
			female.glow.scale.y = 1.0 - 0.3*glowAmt
			setGlowOpacity(1.0 - glowCosTerm)
		else:
			setGlowOpacity(0.0)
	
	female.skeleton.abdomen.set_rotation(leanAng)
	female.skeleton.neck.set_rotation(-leanAng/2)
	
	if shot && !bolt.miss:
		bolt.updateTarget(getTargetBasePos(bolt.target))


func setGlowOpacity(amt):
	var color = female.options.fboltColor
	glowPolyTop.color.h = color[0]
	glowPolyTop.color.s = color[1]
	glowPolyTop.color.v = color[2]
	glowPolyTop.color.a = 0.3*amt
	glowPolyBottom.color.h = color[0]
	glowPolyBottom.color.s = color[1]
	glowPolyBottom.color.v = color[2]
	glowPolyBottom.color.a = 0.40*amt


func setEffectAmt(amt):
	female.glowEffect.setAmt(amt)
	female.glowEffect.position = female.handGlobalPos[R] + CAST_POS


func stop():
	female.setHandLMode(FConst.HANDL_OPEN)
	female.setDefaultHandRMode()
	female.setUseGlobalHandAngles(false)
	female.setIsTurn(false)
	glowPolyTop.set_visible(false)
	glowPolyBottom.set_visible(false)
	female.glowEffect.set_visible(false)


func getTargetBasePos(target):
	var offset = Vector2.ZERO
	if bolt.targetClass == TGT_CLASS_LOW:
		if target == TGT_MISS_LOW:
			offset = Vector2(-20, 130)
		elif target == TGT_AB:
			offset = Vector2(-56, -30)
		elif target == TGT_CLOTH:
			offset = Vector2(-95, 20)
		else:
			if opponent.hasCloth:
				offset = Vector2(-31, 70)
			elif target == TGT_BALL_L:
				offset = opponent.ball[L].position + Vector2(0, 37 if opponent.ball[L].isExposed else 33)
			elif target == TGT_BALL_R:
				offset = opponent.ball[R].position + Vector2(0, 35 if opponent.ball[R].isExposed else 30)
			elif target == TGT_PEN_HEAD:
				offset = Vector2(-31, 75)
			elif target == TGT_PEN_SIDE:
				offset = Vector2(-31, 60)
			elif target == TGT_PEN_BOTTOM:
				offset = Vector2(-35, 55)
			elif target == TGT_CLOTH:
				offset = Vector2(-104, 20)
	elif bolt.targetClass == TGT_CLASS_HIGH:
		if target == TGT_FACE:
			return human.opponent.getEyePos() + Vector2(15 + 5*tgtPosRand[0], 30 + 60*tgtPosRand[1])
	return opponent.pos + offset



func getEyeTargetDir(eyePos):
	return (getTargetBasePos(bolt.target) + female.skeleton.heightDiff*Vector2.DOWN - eyePos).normalized()


func setZOrder():
	female.setDefaultZOrder()

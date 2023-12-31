extends Human
class_name Male

func get_class():
	return "Male"


const ERECT_RATE = 0.04
const RETRACT_RATE = 0.04
const DAMAGE_RECOVER_RATE = 0.03
const ERECT_DAMAGE_START = 0.35
const ERECT_DAMAGE_FULL = 0.65

const SHOULDERL_SHIFT = Vector2(-60, 10)
const SHOULDERR_SHIFT = Vector2(22, 10)

const LBALL_BACK_SHIFT = Vector2(-51, -2)
const RBALL_BACK_SHIFT = Vector2(-38, -4)


var groin
var pen1 : Pen1
var pen2 : Pen2
var ball : Array
var tear : Bone2D
var innards
var sperm

var penPoly : Array
var penPolyCut : Array
var penPolyCutHead : Array
var tearPoly : Polygon2D
var tearBackPoly : Polygon2D
var grabCoverPoly : Polygon2D
var clothPolys

var hitSounds
var loseSounds
var crySounds
var gaspSounds
var sobSounds
var gruntSounds

var health
var recentDamageReceived
var recentDamageDelivered
var erect
var targetErect
var retract
var minRetract
var maxRetract
var erectLevel
var oldErectLevel
var isRetract
var cryTime
var hasCloth
var isStabAb
var isCutCloth
var isTurn
var isBack
var isArmRUp
var isRunFootL
var handLMode
var handRMode
var isHitHead
var isHitPen
var isImpotent
var hitTimer
var autoArmRUp
var erectPauseTime
var stabAbBaseIndex
var penBaseIndex
var ballLBaseIndex
var ballRBaseIndex


func _init().(false):
	sex = M
	health = 1.0
	recentDamageReceived = 0
	recentDamageDelivered = 0
	erect = 0
	targetErect = 0
	retract = 0
	erectLevel = 0
	oldErectLevel = erectLevel
	cryTime = 0
	erectPauseTime = 0
	isRetract = false
	hasCloth = true
	isStabAb = false
	isCutCloth = false
	isTurn = false
	isBack = false
	isArmRUp = false
	isRunFootL = false
	isHitHead = false
	isHitPen = false
	isImpotent = false
	hitTimer = 0
	isAi = false
	autoArmRUp = true
	
	walkAccel = 500
	runAccel = 650
	walkSpeed = 310
	runSpeed = 580
	maxLean = 20
	minHeight = 230
	maxHeight = 90
	vertSpeed = 2000
	vertAccel = 2600
	upHeight = 60
	runHeight = 20
	walkBobHeight = 28
	downHeight = 200
	minWalkStride = [-90, -70]
	maxWalkStride = [70, 90]
	minRunStride = [-150, -250]
	maxRunStride = [300, 310]
	walkLift = 18
	footSpeed = 50*walkSpeed
	footRunSpeed = 80*runSpeed
	footAccel = 23*walkAccel
	footRunAccel = 23*walkAccel
	minRetract = 0
	maxRetract = 1
	minStaminaRegen = 0.62
	staminaRegenRate = 0.17


func _ready():
	regenRateMult = options.mregenRateMult
	
	skeleton.head.eyeshutPoly = get_node("polygons/Head/Eyeshut")
	opponent = owner.get_node("Female")
	groin = game.get_node("Groin")
	
	tear = skeleton.head.get_node("Tear")
	tearPoly = get_node("polygons/Head/Tear")
	tearBackPoly = get_node("polygons/Head/Tear_back")
	
	clothPolys = []
	clothPolys.append(get_node("polygons/Body/ClothF"))
	clothPolys.append(get_node("polygons/Body/ClothF/ClothF_patch"))
	clothPolys.append(get_node("polygons/Body/ClothF_grab"))
	clothPolys.append(get_node("polygons/Body/ClothB"))
	clothPolys.append(get_node("polygons/LegL/ClothF2"))
	clothPolys.append(get_node("polygons/Lay/ClothF_lay"))
	clothPolys.append(get_node("polygons/Lay/ClothF_lay/ClothF_lay2"))
	clothPolys.append(owner.get_node("MCloth/polygons/Front"))
	clothPolys.append(owner.get_node("MCloth/polygons/Back"))
	
	stabAbBaseIndex = get_node("polygons/Body/StabAb").z_index
	penBaseIndex = get_node("polygons/Body/Penis").z_index
	ballLBaseIndex = get_node("polygons/Body/BallL").z_index
	ballRBaseIndex = get_node("polygons/Body/BallR").z_index
	
	commandList = MaleCommandList.new(self)
	input = MaleInputController.new(self)
	aiPlayer = MaleAIPlayer.new(self)
	
	gui = game.get_node("CanvasLayer/MGui")
	gui.initialize(self)
	
	pen1 = skeleton.hip.get_node("Groin/Penis1")
	pen2 = pen1.get_node("Penis2")
	ball = [skeleton.hip.get_node("BallL"), skeleton.hip.get_node("BallR")]
	
	var poly = get_node("polygons/Body/Penis")
	penPoly = [poly.get_node("Penis1"), poly.get_node("Penis2"), poly.get_node("Penis3"), \
			poly.get_node("Penis4"), poly.get_node("Penis5"), poly.get_node("Penis6"), \
			poly.get_node("Penis7"), poly.get_node("Penis8")]
	penPolyCut = [poly.get_node("Penis1"), poly.get_node("Penis2"), poly.get_node("Penis3"), \
			poly.get_node("Penis4"), poly.get_node("Penis5"), poly.get_node("Penis6"), \
			poly.get_node("Penis7"), poly.get_node("Penis8s")]
	penPolyCutHead = [poly.get_node("Penis1c"), poly.get_node("Penis1c"), poly.get_node("Penis1c"), \
			poly.get_node("Penis1c"), poly.get_node("Penis1c"), poly.get_node("Penis1c"), \
			poly.get_node("Penis1c"), poly.get_node("Penis1c")]
	
	grabCoverPoly = poly.get_node("Grab_cover")
	
	innards = get_node("Innards")
	sperm = get_node("Sperm")
	
	setDefaultZOrder()
	setHandLMode(MConst.HANDL_OPEN)
	setHandRMode(MConst.HANDR_OPEN)
	
	hitSounds = Sounds.new(game.get_node("Sounds/MHit"), Game.VOICE_VOLUME+3, Game.MALE_PITCH)
	loseSounds = Sounds.new(game.get_node("Sounds/MLose"), Game.VOICE_VOLUME, Game.MALE_PITCH)
	crySounds = Sounds.new(game.get_node("Sounds/MCry"), Game.VOICE_VOLUME, Game.MALE_PITCH)
	gaspSounds = Sounds.new(game.get_node("Sounds/MGasp"), Game.VOICE_VOLUME, Game.MALE_PITCH)
	sobSounds = Sounds.new(game.get_node("Sounds/MSob"), Game.VOICE_VOLUME, Game.MALE_PITCH)
	gruntSounds = Sounds.new(game.get_node("Sounds/MGrunt"), Game.VOICE_VOLUME, Game.MALE_PITCH)
	
	for p in clothPolys:
		p.color = Color.from_hsv(options.mbottomColor[0], options.mbottomColor[1], options.mbottomColor[2])
	
	var skinColor = Color.from_hsv(options.mcolor[0], options.mcolor[1], options.mcolor[2])
	
	for p in Utility.getAllChildren(self, "Polygon2D"):
		var name = p.name
		if name == "Iris" || name == "Eyewhite" || name == "Tear":
			continue
		if clothPolys.has(p):
			continue
		var origAlpha = p.color.a
		p.color = skinColor
		p.color.a = origAlpha
	
	var skinPolys = []
	skinPolys.append(owner.get_node("Head/polygons/Head"))
	var groinPoly = owner.get_node("Groin/polygons")
	skinPolys.append(groinPoly.get_node("Body"))
	skinPolys.append(groinPoly.get_node("LegL"))
	skinPolys.append(groinPoly.get_node("Penis"))
	skinPolys.append(groinPoly.get_node("Penis2"))
	skinPolys.append(groinPoly.get_node("Penis3"))
	skinPolys.append(groinPoly.get_node("Penis_cut"))
	var winPoly = owner.get_node("Female/polygons_win/HandL_grab1")
	skinPolys.append(winPoly.get_node("HandL_penisc"))
	skinPolys.append(winPoly.get_node("HandL_penis_hard"))
	skinPolys.append(winPoly.get_node("HandL_penis"))
	for p in skinPolys:
		var origAlpha = p.color.a
		p.color = skinColor
		p.color.a = origAlpha
	


func _physics_process(delta):
	approachTargetErect(delta)
	approachTargetRetract(delta)
	cry(delta)
	processHit(delta)
	
	isImpotent = pen1.isCutBottom || pen1.isCutHead || \
				ball[L].health <= 0 || ball[R].health <= 0
	
	recentDamageReceived = max(0, recentDamageReceived - delta*DAMAGE_RECOVER_RATE)
	recentDamageDelivered = max(0, recentDamageDelivered - delta*0.25*DAMAGE_RECOVER_RATE)
	var baseErect = clamp((1.2*opponent.moraleDamage + 0.2*opponent.damage - ERECT_DAMAGE_START)/(ERECT_DAMAGE_FULL - ERECT_DAMAGE_START) + 4.0*recentDamageDelivered, 0, 1)
	targetErect = clamp(baseErect - 4.0*recentDamageReceived, 0, 1)
	if !opponent.isActive:
		targetErect = 1 if opponent.isSurrender else 0
	if isImpotent:
		targetErect = 0
	
	if runningFrac > 0.3:
		if !isRunFootL && footGlobalPos[L].x - pos.x < 30:
			isRunFootL = true
			get_node("polygons/LegL/FootL").set_visible(false)
			get_node("polygons/LegL/FootL_run").set_visible(true)
	elif runningFrac < 0.4:
		if isRunFootL:
			isRunFootL = false
			get_node("polygons/LegL/FootL").set_visible(true)
			get_node("polygons/LegL/FootL_run").set_visible(false)
	
	skeleton.footLRun.set_rotation(skeleton.foot[L].get_rotation() + skeleton.footLRunAngOffset)
	skeleton.toeLRun.set_rotation(0.65*skeleton.toe[L].get_rotation())
	skeleton.placeBiceps()
	
	if autoArmRUp:
		setArmRUpAuto()
	
	if isBack:
		skeleton.placeBackLegs(footGlobalPos)
		skeleton.placeBackArms()


func defaultProcess(delta):
	.defaultProcess(delta)
	
	autoArmRUp = true
	
	face.setNeutral()
	setHandLMode(MConst.HANDL_OPEN)
	setHandRMode(MConst.HANDR_OPEN)
	setIsTurn(false)
	
	if !isActive:
		recoil(true, true, Human.GRAB_GROIN)


func removeCloth():
	if hasCloth:
		hasCloth = false
		
		pen1.set_rotation((Pen1.ANG - 10)*PI/180)
		pen1.vel = vel
		
		var body = get_node("polygons/Body")
		var leg = get_node("polygons/LegL")
		body.get_node("ClothF").set_visible(false)
		body.get_node("ClothF_grab").set_visible(false)
		leg.get_node("ClothF2").set_visible(false)
		body.get_node("ClothB").set_visible(false)
		body.get_node("Bulge").set_visible(false)
		get_node("polygons/Lay/ClothF_lay").set_visible(false)
		
		var cloth = owner.get_node("MCloth")
		cloth.get_node("polygons").set_visible(true)
		cloth.get_node("polygons").z_index = get_node("polygons/Body").z_index
		var center = cloth.get_node("Skeleton2D/Center")
		center.fall()
		center.transform.origin = pos
		center.vel.x = 80


func approachTargetErect(delta):
	if erectPauseTime > 0:
		erectPauseTime -= delta
	else:
		var diff = targetErect - erect
		var rate = ERECT_RATE
		if targetErect < erect:
			rate = 2.0*rate
		var change = delta*rate*(0.3 + 0.7*min(1, 3*abs(diff)))
		if change <= abs(diff):
			erect += sign(diff)*change
		else:
			erect = targetErect
	
	if erect < 0.32:
		erectLevel = 0
	elif erect < 0.46:
		erectLevel = 1
	elif erect < 0.57:
		erectLevel = 2
	elif erect < 0.66:
		erectLevel = 3
	elif erect < 0.75:
		erectLevel = 4
	elif erect < 0.83:
		erectLevel = 5
	elif erect < 0.91:
		erectLevel = 6
	else:
		erectLevel = 7
	if erectLevel != oldErectLevel:
		oldErectLevel = erectLevel
		for poly in penPoly:
			poly.set_visible(false)
		penPoly[erectLevel].set_visible(true)
		if pen1.isCutBottom:
			get_node("polygons/Body/Penis/Sever").set_visible(true)


func approachTargetRetract(delta):
	var damage = 1 - min(ball[L].health, ball[R].health)
	var targetRetractRatio = max(0, 1.4*damage)
	var retractRatio = (retract - minRetract)/(maxRetract - minRetract)
	var retractRate = RETRACT_RATE*(1.0 + 1.5*abs(targetRetractRatio - retractRatio))
	retract = clamp(retract + delta*sign(targetRetractRatio - retractRatio)*retractRate, minRetract, maxRetract)
	ball[L].setRetract(retract)
	ball[R].setRetract(retract)


func limitArmExtents():
	handGlobalPos[L].y = min(handGlobalPos[L].y, pos.y + 90)
	handGlobalPos[R].y = min(handGlobalPos[R].y, pos.y + 77)


func getReactionTimeMult():
	return 0.4 if isPerforming("MGrabArmsPen") else .getReactionTimeMult()


func cutCloth():
	isCutCloth = true
	get_node("polygons/Body/ClothF/ClothF_patch").set_visible(false)


func cutPenSide():
	recDamage(0.03)
	recGenitalDamage(0.2)
	cutCloth()
	pen1.cutSide()
#	if options.goreEnabled:
#		get_node("polygons/Body/Penis/Cut").set_visible(true)


func cutPenHead():
	recDamage(0.03)
	recGenitalDamage(0.3)
	if options.goreEnabled:
		approachTargetErect(0.0)
		for poly in penPoly:
			poly.set_visible(false)
		penPoly = penPolyCutHead
		penPoly[erectLevel].set_visible(true)
		pen1.cutHead()
		var severedHead = game.get_node("Head")
		severedHead.sever()


func cutPenBottom():
	recDamage(0.03)
	recGenitalDamage(0.3)
	if options.goreEnabled:
		approachTargetErect(0.0)
		for poly in penPoly:
			poly.set_visible(false)
		penPoly = penPolyCut
		penPoly[erectLevel].set_visible(true)
		pen1.get_node("Cum").start()
	pen1.cutBottom()
	erectPauseTime = 0.3


func setLegsClosed(frac):
	legsClosedAbAng = -frac*20*PI/180
	targetHeadAng = frac*10*PI/180
	skeleton.setLegsClosed(frac)


func setGrabPart(frac, part):
	if part == GRAB_GROIN:
		handAngles[L] = -0.4*frac
		targetRelHandPos[L] = frac*skeleton.handLGroinOffset
		handAngles[R] = 0.5*frac
		targetRelHandPos[R] = frac*Vector2(-150, -50)
	elif part == GRAB_FACE:
		handAngles[L] = 0.2*frac
		targetRelHandPos[L] = frac*Vector2(-5, 20)
		handAngles[R] = 0.5*frac
		targetRelHandPos[R] = frac*Vector2(10, -160)


func setHandLMode(mode):
	if handLMode != mode:
		handLMode = mode
		get_node("polygons/ArmL/HandL").set_visible(mode == MConst.HANDL_OPEN)
		get_node("polygons/ArmL/HandL_grab").set_visible(mode == MConst.HANDL_GRAB)
		get_node("polygons/ArmL/HandL_feel").set_visible(mode == MConst.HANDL_FEEL)
		get_node("polygons/ArmL/HandL_fist").set_visible(mode == MConst.HANDL_FIST)
		get_node("polygons/Back/HandL_grab_lift0").set_visible(mode == MConst.HANDL_LIFT1)
		get_node("polygons/Back/HandL_grab_lift").set_visible(mode == MConst.HANDL_LIFT2)
		var clothPoly = get_node("polygons/ArmL/HandL_grab_cloth")
		clothPoly.set_visible(mode == MConst.HANDL_GRAB_CLOTH)
		clothPoly.z_index = opponent.get_node("polygons/Body").z_index + 1


func setHandRMode(mode):
	if handRMode != mode:
		handRMode = mode
		get_node("polygons/ArmR/HandR").set_visible(mode == MConst.HANDR_OPEN)
		get_node("polygons/ArmR/HandR_fist").set_visible(mode == MConst.HANDR_FIST)
		get_node("polygons/ArmR/HandR_grab1").set_visible(mode == MConst.HANDR_GRAB)
		get_node("polygons/ArmR/HandR_grab2").set_visible(mode == MConst.HANDR_GRAB)
		get_node("polygons/ArmR/HandR_grab_cloth1").set_visible(mode == MConst.HANDR_GRAB_CLOTH)
		get_node("polygons/ArmR/HandR_grab_cloth2").set_visible(mode == MConst.HANDR_GRAB_CLOTH)
		get_node("polygons/ArmR/HandR_grab_armr").set_visible(mode == MConst.HANDR_GRAB_ARMR)


func setIsTurn(newTurn):
	if newTurn:
		if !isTurn:
			isTurn = true
			var body = get_node("polygons/Body")
			body.get_node("Body").set_visible(false)
			body.get_node("Body2").set_visible(true)
			skeleton.arm[L].transform.origin += SHOULDERL_SHIFT
			skeleton.arm[R].transform.origin += SHOULDERR_SHIFT
	else:
		if isTurn:
			isTurn = false
			var body = get_node("polygons/Body")
			body.get_node("Body").set_visible(true)
			body.get_node("Body2").set_visible(false)
			skeleton.arm[L].transform.origin = skeleton.shoulderBasePos[L]
			skeleton.arm[R].transform.origin = skeleton.shoulderBasePos[R]


func setIsBack(newBack):
	if newBack != isBack:
		isBack = newBack
		shadow.setVisible(!isBack)
		skeleton.hip.get_node("Penis_back").physActive = isBack
		var poly = get_node("polygons")
		poly.get_node("Back").set_visible(isBack)
		poly.get_node("Body/Body").set_visible(!isBack)
		poly.get_node("Body/Penis").set_visible(!isBack)
		poly.get_node("Body/StabAb").set_visible(!isBack && isStabAb)
		poly.get_node("Head").set_visible(!isBack)
		poly.get_node("LegL").set_visible(!isBack)
		poly.get_node("LegR").set_visible(!isBack)
		poly.get_node("ArmL").set_visible(!isBack)
		poly.get_node("ArmR/ArmR").set_visible(!isBack)
		if isBack:
			footGlobalPos[L].x = pos.x + min(footGlobalPos[L].x - pos.x, -100)
			skeleton.arm[L].transform.origin += Vector2(-163, 17)
			skeleton.arm[R].transform.origin += Vector2(164, 15)
			poly.get_node("Back/ArmL").z_index = Utility.getAbsZIndex(poly.get_node("ArmL/ArmL"))
			ball[L].basePosOffset = LBALL_BACK_SHIFT
			ball[R].basePosOffset = RBALL_BACK_SHIFT
			poly.get_node("Body/BallL").transform.origin = LBALL_BACK_SHIFT
			poly.get_node("Body/BallR").transform.origin = RBALL_BACK_SHIFT
			ball[L].rest.origin = ball[L].origRestPos + LBALL_BACK_SHIFT
			ball[R].rest.origin = ball[R].origRestPos + RBALL_BACK_SHIFT
			skeleton.updateArmPos()
			skeleton.place_arms(handGlobalPos, handAngles, useGlobalHandAngles, armScale)
			skeleton.placeBackArms()
		else:
			skeleton.arm[L].transform.origin = skeleton.shoulderBasePos[L]
			skeleton.arm[R].transform.origin = skeleton.shoulderBasePos[R]
			ball[L].basePosOffset = Vector2.ZERO
			ball[R].basePosOffset = Vector2.ZERO
			poly.get_node("Body/BallL").transform.origin = Vector2.ZERO
			poly.get_node("Body/BallR").transform.origin = Vector2.ZERO
			ball[L].rest.origin = ball[L].origRestPos
			ball[R].rest.origin = ball[R].origRestPos
			skeleton.updateArmPos()


func startCrying():
	if cryTime < 0.3:
		cryTime = 0.01


func cry(delta):
	if cryTime <= 0:
		return
	cryTime += delta
	var cryAmt = min(1.0, cryTime/4.0)
	tearPoly.color = Color(1, 1, 1, cryAmt)
	isBack = skeleton.hip.get_rotation() > 0.8
	tearPoly.set_visible(!isBack)
	tearBackPoly.set_visible(isBack)
	tear.position = (1 - cryAmt)*(Vector2(-26, 0) if isBack else Vector2(0, -26))


func getHealth():
	var ballDamageL = 1 if ball[L].health <= 0 else 0.7*(1 - ball[L].health)
	var ballDamageR = 1 if ball[R].health <= 0 else 0.7*(1 - ball[R].health)
	var ballDamage = 0.338*(ballDamageL + ballDamageR + max(ballDamageL, ballDamageR))
	var penDamage = min(1, (0.4 if pen1.isCutBottom else 0) + (0.08 if pen1.isCutSide else 0) + (1.0 if pen1.isCutHead else 0))
	return health - ballDamage - 0.5*penDamage


func recDamage(damage):
	health -= damage
	recentDamageReceived += damage


func recGenitalDamage(damage):
	recentDamageReceived += damage
	recentDamageDelivered -= 0.5*damage
	if getHealth() < 0:
		isActive = false


func deliverMoraleDamage(damage):
	recentDamageDelivered += damage


func recStabFace(bleedPos):
	hitSounds.playRandom()
	owner.cutSounds.playRandom()
	bleed(null, bleedPos - pos, false, get_node("polygons/Head/Head"), 50, 0.8)
	if !isActive:
		return
	recDamage(0.12)
	tire(0.3)
	isHitHead = true
	hitTimer = 0
	face.setEyesClosed()


func recStabAb():
	isStabAb = true
	recDamage(0.05)
	tire(0.3)
	get_node("polygons/Body/StabAb").set_visible(true)
	bleed(null, Vector2(-5, -36), false, get_node("polygons/Body"), 30, 0.5)
	hitSounds.playRandom()
	owner.cutSounds.playRandom()


func recStabArmR():
	recDamage(0.016)
	tire(0.12)
	bleed(skeleton.hand[R], Vector2(0, 10), false, get_node("polygons/ArmR/HandR"), 30, 0.5)
	hitSounds.playRandom()
	owner.cutSounds.playRandom()


func recStabArmL():
	recDamage(0.016)
	tire(0.12)
	bleed(skeleton.hand[L], Vector2(0, 10), false, get_node("polygons/ArmL/HandL"), 30, 0.5)
	hitSounds.playRandom()
	owner.cutSounds.playRandom()


func recHitHead():
	hitSounds.playRandom()
	owner.punchSounds.playRandom()
	if !isActive:
		return
	recDamage(0.1)
	tire(0.3)
	isHitHead = true
	hitTimer = 0
	face.setEyesClosed()


func recBlockedKick():
	owner.punchSounds.playRandom()
	tire(0.12)
	if isPerforming("MBlock"):
		action.recBlockedKick()


func recPenHit():
	isHitPen = true
	hitTimer = 0
	if erect >= 0.75 || pen1.isCutHead:
		recDamage(0.03)
		recGenitalDamage(0.15)
		face.setPain(-0.2)
		hitSounds.playRandom()
		game.clapSounds.playRandomDb(0)


func processHit(delta):
	hitTimer += delta
	if isHitHead:
		var amt = hitTimer/0.38
		var amt2 = amt*amt
		var moveAmt = amt - 1.5*amt2 + 0.5*amt2*amt2
		setHeadAng(2.2*moveAmt)
		if amt > 1:
			isHitHead = false
	if isHitPen:
		var amt = hitTimer/0.06
		skeleton.clothF1.vel.x -= delta*19000;
		skeleton.clothF1.vel.y -= delta*10000;
		skeleton.clothF2.vel.x -= delta*10000;
		skeleton.clothF3.vel.x -= delta*9000;
		if erect < 0.75:
			pen1.vel.y -= delta*10000;
			pen1.vel.x -= delta*15000;
			pen2.vel.x -= delta*10000;
		else:
			pen1.vel.y -= delta*15000;
		if amt > 1:
			isHitPen = false


func getFootAngles(footPos):
	var lAng = 0
	var rAng = 0
	if pos.y < -11:
		lAng = 0.007*(pos.y + 11)
		rAng = lAng
	elif pos.y > 0:
		var downDist = pos.y - downHeight/2
		if downDist > 0:
			lAng = -0.005*downDist
	lAng = max(-0.4, lAng - 0.25*legsClosedFrac)
	if runningFrac > 0:
		var deltaLX = footPos[L].x - skeleton.footBasePos[L].x
		var deltaLY = footPos[L].y - skeleton.footBasePos[L].y + pos.y
		var runAngleL
		if deltaLX < 0:
			runAngleL = -0.008*deltaLX*clamp(-0.02*deltaLY, 0, 1)
		else:
			runAngleL = -0.0015*deltaLX
		var runAngleR
		var deltaRX = footPos[R].x - skeleton.footBasePos[R].x
		var deltaRY = footPos[R].y - skeleton.footBasePos[R].y + pos.y
		if deltaRX < 0:
			runAngleR = -0.007*deltaRX*clamp(-0.01*deltaRY, 0, 1)
		else:
			runAngleR = -0.003*deltaRX
		lAng = lAng*(1-runningFrac) + runAngleL*runningFrac
		rAng = rAng*(1-runningFrac) + runAngleR*runningFrac
	return [lAng, rAng]


func setArmRUpAuto():
	var up = isArmRUp
	var armRPos = handGlobalPos[R] - (pos + skeleton.rotShift)
	if armRPos.x < 0:
		up = false
	else:
		if armRPos.y < -125:
			up = true
		elif armRPos.y > -123:
			up = false
	setArmRUp(up)

func setArmRUp(up):
	if isArmRUp != up:
		isArmRUp = up
		get_node("polygons/ArmR/ForearmR_up").set_visible(up)
		get_node("polygons/ArmR/ForearmR").set_visible(!up)
		#setHandRMode(MConst.HANDR_OPEN)


func startGrabPart(part):
	.startGrabPart(part)
	setHandLMode(MConst.HANDL_OPEN)


func getPhysicalHealth():
	return getHealth()


func isBlockingLow():
	if isPerforming("MBlock") && action.isBlockingLow():
		return true
	if grabbingPart == GRAB_GROIN && partGrabFrac > 0.95:
		return true
	return false

func isBlockingHigh():
	if isPerforming("MBlock") && action.isBlockingHigh():
		return true
	if grabbingPart == GRAB_FACE && partGrabFrac > 0.95:
		return true
	if isPerforming("MRecoil2") || (isPerforming("MRecoil1") && action.isBlockingHigh()):
		return true
	return false


func isRecoiling():
	return isPerforming("MRecoil1") || isPerforming("MRecoil2") || isPerforming("MFallBack")


func getNumBalls():
	return (1 if ball[L].health > 0 else 0) + (1 if ball[R].health > 0 else 0)


func femaleGlobalHandPos(index):
	return opponent.handGlobalPos[index] + \
			opponent.skeleton.handHipOffset[index] + opponent.skeleton.heightDiff*Vector2.DOWN


func handFemalePos(index):
	return -skeleton.handHipOffset[index] + opponent.pos + opponent.skeleton.heightDiff*Vector2.DOWN


func performMGrabArmsPen(male):
	action.done = true
	perform(MGrabArmsPen.new(male))


func recoilSound(hard, isFatal, makeSound, grabPart):
	isFatal = true
	if !isPerforming("MRecoil1") && !isPerforming("MRecoil2"):
		if makeSound:
			if hard || getHealth() <= 0:
				loseSounds.playRandom()
			else:
				hitSounds.playRandom()
		isFatal = isFatal && getHealth() <= 0
		if !hard || isFatal:
			perform(MRecoil1.new(self, isFatal, grabPart))
		else:
			perform(MRecoil2.new(self))


func recoil(hard, isFatal, grabPart):
	recoilSound(hard, isFatal, true, grabPart)


func recBolt(bolt):
	if !isActive:
		pass
		return false
	else:
		var blockingLow = isBlockingLow()
		if bolt.target == FCast.TGT_PEN_HEAD && erect > 0.88:
			blockingLow = false
		if bolt.target == FCast.TGT_AB || bolt.target == FCast.TGT_CLOTH:
			blockingLow = false
		if blockingLow && bolt.targetClass == FCast.TGT_CLASS_LOW:
			recStabArmL()
		elif isBlockingHigh() && bolt.targetClass == FCast.TGT_CLASS_HIGH:
			recStabArmR()
		else:
			if !perform(FBoltRec.new(bolt)):
				if bolt.target == FCast.TGT_FACE:
					recStabFace(bolt.getTargetPos())
				elif bolt.target == FCast.TGT_AB:
					recStabAb()
				else:
					return false
	return true


func getEyePos():
	return Vector2(-15, 0) + face.eyeL.get_global_position()


func innard(location, direction, backPoly):
	innards.z_index = Utility.getAbsZIndex(backPoly) + 1
	innards.transform.origin = pos + location
	innards.process_material.direction = Vector3(1 if direction else -1, 0, 0)
	innards.emitting = true


func sperm(location, backPoly):
	sperm.z_index = Utility.getAbsZIndex(backPoly) + 1
	sperm.transform.origin = pos + location
	sperm.emitting = true


func performWin2():
	perform(MWin2.new(self))


func setDefaultZOrder():
	setZOrder([-5,-4,-3,3,4])
	isDefaultZOrder = true

func setZOrder(zOrder):
	isDefaultZOrder = false
	var poly = get_node("polygons")
	poly.get_node("ArmR").z_index = 10*zOrder[0]
	poly.get_node("LegR").z_index = 10*zOrder[1]
	poly.get_node("Body").z_index = 10*zOrder[2]
	poly.get_node("Head").z_index = 10*zOrder[2]
	poly.get_node("Back").z_index = 10*zOrder[2]
	poly.get_node("LegL").z_index = 10*zOrder[3]
	poly.get_node("ArmL").z_index = 10*zOrder[4]
	grabCoverPoly.set_visible(false)
	poly.get_node("Body/StabAb").z_index = stabAbBaseIndex
	poly.get_node("Body/Penis").z_index = penBaseIndex
	poly.get_node("Body/Penis").z_as_relative = true
	poly.get_node("Body/BallL").z_index = ballLBaseIndex
	poly.get_node("Body/BallL").z_as_relative = true
	poly.get_node("Body/BallR").z_index = ballRBaseIndex
	poly.get_node("Body/BallR").z_as_relative = true

func setGrabCoverVisible(visible):
	isDefaultZOrder = false
	grabCoverPoly.set_visible(visible)

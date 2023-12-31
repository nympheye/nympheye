extends Human
class_name Female

func get_class():
	return "Female"

const GRAB_BREAST = 1
const GRAB_GUT = 2

const SHOULDERL_SHIFT = Vector2(-18, -3)
const SHOULDERR_SHIFT = Vector2(22, 15)

var damage
var moraleDamage
var weapon
var hasTop
var hasBottom
var handLMode
var handRMode
var isTurn
var isArmsUp
var isLegROpen
var alternaFoot
var isKnifePointUp
var isKnifeBloody
var cryTime
var grabbedBall
var stabbedBalls

var shoulder
var bolt : FBolt
var glowEffect : GlowEffect
var glow : Bone2D
var tear : Bone2D
var hitSounds : Sounds
var loseSounds : Sounds
var crySounds : Sounds
var dieSounds : Sounds
var gruntSounds : Sounds

var knifePoly
var knife2Poly
var knife2BloodPoly
var tearPoly
var wrapPolys
var topPolys
var bottomPolys
var hairPolys

var punchTimer
var isPunchedFace
var isPunchedBreast
var isPunchedGut
var punchStartAbAng


func _init().(true):
	sex = F
	damage = 0.0
	moraleDamage = 0.0
	weapon = FConst.WEAPON_KNIFE
	hasTop = true
	hasBottom = true
	isTurn = false
	isArmsUp = false
	isLegROpen = false
	alternaFoot = false
	isKnifePointUp = false
	isKnifeBloody = false
	handLMode = FConst.HANDL_OPEN
	handRMode = FConst.HANDR_CLOSED
	punchTimer = 0
	isPunchedFace = false
	isPunchedBreast = false
	isPunchedGut = false
	isAi = false
	cryTime = 0
	grabbedBall = false
	stabbedBalls = false
	
	walkAccel = 500
	runAccel = 500
	walkSpeed = 310
	runSpeed = 530
	maxLean = 20
	minHeight = 140
	maxHeight = 60
	vertSpeed = 800
	vertAccel = 1750
	upHeight = 32
	runHeight = 25
	walkBobHeight = 26
	downHeight = 130
	minWalkStride = [-140, -55]
	maxWalkStride = [55, 100]
	minRunStride = [-250, -140]
	maxRunStride = [280, 280]
	walkLift = 15
	footSpeed = 50*walkSpeed
	footRunSpeed = 300*runSpeed
	footAccel = 20*walkAccel
	footRunAccel = 22*walkAccel
	minStaminaRegen = 0.80
	staminaRegenRate = 0.135


func _ready():
	regenRateMult = options.fregenRateMult
	opponent = game.get_node("Male")
	weapon = options.fweapon
	
	bolt = game.get_node("FBolt")
	bolt.human = self
	
	glowEffect = game.get_node("FBoltGlow")
	
	glow = skeleton.hand[R].get_node("Glow")
	glow.rest = Transform2D.IDENTITY.rotated(glow.get_rotation())
	
	var poly = get_node("polygons")
	shoulder = poly.get_node("ArmR/ShoulderR")
	shoulder = poly.get_node("ArmR/ShoulderR")
	knifePoly = poly.get_node("ArmR/Knife")
	knife2Poly = poly.get_node("ArmR/Knife2")
	knife2BloodPoly = poly.get_node("ArmR/Knife2_blood")
	
	tear = skeleton.head.get_node("Tear")
	tearPoly = get_node("polygons/Head/Tear")
	
	wrapPolys = []
	wrapPolys.append(poly.get_node("Head/Wrap"))
	wrapPolys.append(get_node("polygons_turn/Wrap"))
	wrapPolys.append(get_node("polygons_win/Wrap"))
	
	topPolys = []
	topPolys.append(poly.get_node("Body/Top"))
	topPolys.append(poly.get_node("Body/Top2"))
	topPolys.append(poly.get_node("Body/TopR"))
	topPolys.append(get_node("polygons_turn/Top"))
	topPolys.append(get_node("polygons_lose/Top"))
	topPolys.append(get_node("polygons_win/Top"))
	topPolys.append(owner.get_node("TopL/polygons/TopL_tearL"))
	topPolys.append(owner.get_node("TopL/polygons/TopL_tearR"))
	topPolys.append(owner.get_node("TopR/polygons/TopR_tearL"))
	topPolys.append(owner.get_node("TopR/polygons/TopR_tearR"))
	
	bottomPolys = []
	bottomPolys.append(poly.get_node("Body/ClothB"))
	bottomPolys.append(poly.get_node("Body/ClothF"))
	bottomPolys.append(poly.get_node("LegR/ClothF2"))
	bottomPolys.append(get_node("polygons_turn/Cloth"))
	bottomPolys.append(get_node("polygons_turn/ClothF"))
	bottomPolys.append(get_node("polygons_lose/Cloth"))
	bottomPolys.append(get_node("polygons_win/Cloth"))
	bottomPolys.append(owner.get_node("FCloth/polygons/Front"))
	bottomPolys.append(owner.get_node("FCloth/polygons/Back"))
	
	hairPolys = []
	hairPolys.append(poly.get_node("Head/Hair"))
	hairPolys.append(poly.get_node("Head/HairBL"))
	hairPolys.append(poly.get_node("Head/HairBR"))
	hairPolys.append(poly.get_node("Head/HairBR_lay"))
	hairPolys.append(poly.get_node("Head/HairFR"))
	hairPolys.append(poly.get_node("Head/HairFC"))
	hairPolys.append(poly.get_node("Head/HairFL"))
	hairPolys.append(poly.get_node("Body/Body/Hair_neck"))
	hairPolys.append(poly.get_node("Body/Body2/Hair_neck"))
	hairPolys.append(get_node("polygons_turn/Hair"))
	hairPolys.append(get_node("polygons_win/Hair"))
	hairPolys.append(get_node("polygons_lose/Hair"))
	
	setDefaultZOrder()
	setKnifePoly()
	
	skeleton.chest.get_node("BreastL").removeTop()
	skeleton.head.set_scale(Vector2(1.05, 1.05))
	skeleton.head.eyeshutPoly = poly.get_node("Head/Eyeshut")
	
	commandList = FemaleCommandList.new(self)
	input = FemaleInputController.new(self)
	aiPlayer = FemaleAIPlayer.new(self)
	
	gui = game.get_node("CanvasLayer/FGui")
	gui.initialize(self)
	
	if weapon == FConst.WEAPON_KNIFE:
		defaultHandPos[R] = Vector2.ZERO
	elif weapon == FConst.WEAPON_CAST:
		defaultHandPos[R] = Vector2(25, -15)
	elif weapon == FConst.WEAPON_NONE:
		defaultHandPos[R] = Vector2(45, -45)
		defaultHandPosVertShift[R] = 0.1
	
	hitSounds = Sounds.new(game.get_node("Sounds/FHit"), Game.VOICE_VOLUME, Game.FEMALE_PITCH)
	loseSounds = Sounds.new(game.get_node("Sounds/FLose"), Game.VOICE_VOLUME, Game.FEMALE_PITCH)
	crySounds = Sounds.new(game.get_node("Sounds/FCry"), Game.VOICE_VOLUME, Game.FEMALE_PITCH)
	dieSounds = Sounds.new(game.get_node("Sounds/FDie"), Game.VOICE_VOLUME, Game.FEMALE_PITCH)
	gruntSounds = Sounds.new(game.get_node("Sounds/FGrunt"), Game.VOICE_VOLUME, Game.FEMALE_PITCH)
	
	for p in hairPolys:
		p.color = Color.from_hsv(options.fhairColor[0], options.fhairColor[1], options.fhairColor[2])
	
	for p in wrapPolys:
		p.set_visible(options.fwrap)
		p.color = Color.from_hsv(options.fwrapColor[0], options.fwrapColor[1], options.fwrapColor[2])
	
	for p in topPolys:
		p.color = Color.from_hsv(options.ftopColor[0], options.ftopColor[1], options.ftopColor[2])
	
	for p in bottomPolys:
		p.color = Color.from_hsv(options.fbottomColor[0], options.fbottomColor[1], options.fbottomColor[2])
	
	if options.ftopless:
		removeTop()
	
	if options.fbottomless:
		removeBottom()
	
	poly.get_node("Head/HairFC").set_visible(options.fhairCenter)
	poly.get_node("Head/HairFR").set_visible(options.fhairSide)
	
	var skinColor = Color.from_hsv(options.fskinColor[0], options.fskinColor[1], options.fskinColor[2])
	
	for p in Utility.getAllChildren(self, "Polygon2D"):
		var name = p.name
		if name == "Iris" || name == "Eyewhite" || name == "Tear" || name.begins_with("Knife") || name.find("penis") > 0:
			continue
		if hairPolys.has(p) || wrapPolys.has(p) || topPolys.has(p) || bottomPolys.has(p):
			continue
		var origAlpha = p.color.a
		p.color = skinColor
		p.color.a = origAlpha
	
	var groinPoly = owner.get_node("Groin/polygons")
	var groinFPolys = []
	groinFPolys.append(groinPoly.get_node("Foot"))
	groinFPolys.append(groinPoly.get_node("Foot_back"))
	groinFPolys.append(groinPoly.get_node("Knee"))
	groinFPolys.append(groinPoly.get_node("Hand_twist"))
	groinFPolys.append(groinPoly.get_node("Hand_grab"))
	groinFPolys.append(groinPoly.get_node("Hand_grab/Hand_grabt"))
	groinFPolys.append(groinPoly.get_node("Hand_grab/Hand_grabf"))
	for p in groinFPolys:
		var origAlpha = p.color.a
		p.color = skinColor
		p.color.a = origAlpha
	


func _physics_process(delta):
	
	var upAng = 90 - rad2deg(skeleton.arm[R].get_rotation())
	var angFrac = clamp((upAng-35)/65, 0, 1)
	shoulder.color.a = angFrac
	
	if partGrabFrac > 0.9:
		setHandLMode(FConst.HANDL_BACK)
	elif partGrabFrac < 0.6 && handLMode == FConst.HANDL_BACK:
		setHandLMode(FConst.HANDL_OPEN)
	
	if isArmsUp:
		skeleton.placeUpArms(handGlobalPos)
	
	processPunch(delta)
	cry(delta)
	
	if isActive && getHealth() <= 0 && !stabbedBalls:
		tire(1.0)
		if isPerforming("FRecoil") || perform(FRecoil.new(self)):
			isActive = false
	
	if action == null && punchTimer > 0.4:
		setHandLMode(FConst.HANDL_OPEN)
		setKnifePointUp(isKnifeBloody)
		face.setNeutral()


func defaultProcess(delta):
	.defaultProcess(delta)
	
	setDefaultHandRMode()
	setIsTurn(false)
	
	if punchTimer > 0.4:
		setHandLMode(FConst.HANDL_OPEN)
		setKnifePointUp(isKnifeBloody)
		face.setNeutral()
	


func getHealth():
	if damage >= 1.0:
		return 0.0
	return (1.0 - moraleDamage)*(1.0 - 0.8*damage)

func getPhysicalHealth():
	return 1.0 - damage


func removeTop():
	if hasTop:
		hasTop = false
		recMoraleDamage(0.20)
		
		skeleton.breast[L].removeTop()
		skeleton.breast[R].removeTop()
		get_node("polygons/Body/Top").set_visible(false)
		get_node("polygons_turn/Top").set_visible(false)
		get_node("polygons_lose/Top").set_visible(false)
		get_node("polygons_win/Top").set_visible(false)


func removeBottom():
	if hasBottom:
		hasBottom = false
		recMoraleDamage(0.20)
		
		get_node("polygons/Body/ClothB").set_visible(false)
		get_node("polygons/Body/ClothF").set_visible(false)
		get_node("polygons/LegR/ClothF2").set_visible(false)
		get_node("polygons_turn/Cloth").set_visible(false)
		get_node("polygons_turn/ClothF").set_visible(false)
		get_node("polygons_lose/Cloth").set_visible(false)
		get_node("polygons_win/Cloth").set_visible(false)
		
		var cloth = owner.get_node("FCloth")
		cloth.get_node("polygons").set_visible(true)
		cloth.get_node("polygons").z_index = get_node("polygons/Body").z_index
		var center = cloth.get_node("Skeleton2D/Center")
		center.fall()
		center.transform.origin = pos + Vector2(0, skeleton.heightDiff)
		center.vel.x = -120


func recPunchFace():
	if !isPunchedFace:
		recDamage(0.15)
		tire(0.35)
		isPunchedFace = true
		punchTimer = 0
		punchStartAbAng = skeleton.abdomen.get_rotation()
		face.setEyesClosed()
		hitSounds.playRandom()
		owner.punchSounds.playRandom()
		if getPhysicalHealth() < 0.5:
			get_node("polygons/Head/Blood").set_visible(true)
			get_node("polygons_win/Blood").set_visible(true)

func recPunchBreast():
	if !isPunchedBreast:
		recDamage(0.15)
		tire(0.35)
		isPunchedBreast = true
		punchTimer = 0
		punchStartAbAng = skeleton.abdomen.get_rotation()
		face.setPain(0.4)
		hitSounds.playRandom()
		owner.punchSounds.playRandom()

func recPunchGut():
	if !isPunchedGut:
		recDamage(0.15)
		tire(0.22)
	else:
		recDamage(0.12)
		tire(0.0)
	isPunchedGut = true
	punchTimer = 0
	punchStartAbAng = skeleton.abdomen.get_rotation()
	face.setPain(0.4)
	setHandRMode(FConst.HANDR_CLOSED)
	loseSounds.playRandom()
	owner.punchSounds.playRandom()
	startGrabPart(GRAB_GUT)


func processPunch(delta):
	punchTimer += delta
	if isPunchedFace:
		var amt = punchTimer/0.42
		var amt2 = amt*amt
		var moveAmt = amt - 1.5*amt2 + 0.5*amt2*amt2
		skeleton.abdomen.set_rotation(punchStartAbAng - 0.6*moveAmt)
		setHeadAng(-2.2*moveAmt)
		if amt > 1:
			isPunchedFace = false
			face.setNeutral()
	elif isPunchedBreast:
		var amt = punchTimer/0.5
		var amt2 = amt*amt
		var moveAmt = amt - 1.5*amt2 + 0.5*amt2*amt2
		skeleton.abdomen.set_rotation(punchStartAbAng - 1.0*moveAmt)
		setHeadAng(1.8*moveAmt)
		if amt < 0.3:
			skeleton.breast[L].linVel.x -= delta*3500
			skeleton.breast[L].vel.y -= delta*3500
		if amt > 1:
			isPunchedBreast = false
			face.setNeutral()
	elif isPunchedGut:
		targetAbAng = 0.24
		if punchTimer > 0.5 && action == null:
			isPunchedGut = false


func recDamage(amt):
	damage += amt

func recMoraleDamage(amt):
	moraleDamage += amt
	opponent.deliverMoraleDamage(amt)


func getStaminaHealth():
	var healthDisadvantage = max(0, opponent.getPhysicalHealth() - getPhysicalHealth())
	return .getStaminaHealth() + 0.6*pow(healthDisadvantage, 2)


func setLegsClosed(frac):
	if alternaFoot && frac < 0.8:
		alternaFoot = false
		var leg = get_node("polygons/LegL")
		leg.get_node("FootL").set_visible(true)
		leg.get_node("FootL2").set_visible(false)
	elif !alternaFoot && frac > 0.8:
		alternaFoot = true
		var leg = get_node("polygons/LegL")
		leg.get_node("FootL").set_visible(false)
		leg.get_node("FootL2").set_visible(true)
	
	legsClosedAbAng = frac*15*PI/180
	targetHeadAng = -frac*10*PI/180
	skeleton.setLegsClosed(frac)


func setGrabPart(frac, part):
	if part == GRAB_GROIN:
		handAngles[L] = 0.2*frac
		targetRelHandPos[L] = frac*skeleton.handLGroinOffset
	elif part == GRAB_BREAST:
		handAngles[L] = 0.0
		targetRelHandPos[L] = frac*Vector2(-195, 35)
	elif part == GRAB_GUT:
		handAngles[L] = 0.0
		targetRelHandPos[L] = frac*Vector2(-170, 90)


func getFootAngles(footPos):
	var angleL = max(0, -pos.y/100) + 0.25*legsClosedFrac - 0.003*legsClosedFrac*min(0, footPos[L].x)
	var angleR = clamp(0.85*PI - PI + atan2(-footPos[R].x, footPos[R].y), -0.2, 0.2)
	angleR += max(0, -pos.y/100)*(0.5 + 0.5*legsClosedFrac)
	var footRShift = footPos[R].x - skeleton.footBasePos[R].x
	angleR += max(0, -0.002*footRShift if footRShift < 0 else 0)
	if runningFrac > 0:
		var deltaLX = footPos[L].x - skeleton.footBasePos[L].x
		var deltaLY = footPos[L].y - skeleton.footBasePos[L].y + pos.y
		var runAngleL
		if deltaLX > 0:
			runAngleL = -0.003*deltaLX*clamp(-0.02*deltaLY, 0, 1)
		else:
			runAngleL = -0.004*deltaLX
		var runAngleR = -0.8
		var deltaRX = footPos[R].x - skeleton.footBasePos[R].x
		var deltaRY = footPos[R].y - skeleton.footBasePos[R].y + pos.y
		if deltaRX > 0:
			runAngleR += -0.003*deltaRX*clamp(-0.02*deltaRY, 0, 1)
		else:
			runAngleR += -0.006*deltaRX
		angleL = angleL*(1-runningFrac) + runAngleL*runningFrac
		angleR = angleR*(1-runningFrac) + runAngleR*runningFrac
	angleL = min(angleL, 0.95)
	angleR = min(angleR, 0.32)
	return [angleL, angleR]


func startCrying():
	if cryTime < 0.3:
		cryTime = 0.01

func cry(delta):
	if cryTime <= 0:
		return
	cryTime += delta
	var cryAmt = min(1.0, cryTime/4.0)
	tearPoly.set_visible(true)
	tearPoly.color = Color(1, 1, 1, cryAmt)
	tear.position = (1 - cryAmt)*Vector2(-26, 0)


func bloodyKnife():
	isKnifeBloody = true
	setKnifePoly()


func setKnifePointUp(isUp):
	if isKnifePointUp != isUp:
		isKnifePointUp = isUp
		setKnifePoly()


func setKnifePoly():
	get_node("polygons/ArmR/Knife").set_visible(weapon == FConst.WEAPON_KNIFE && !isKnifePointUp)
	get_node("polygons/ArmR/Knife2").set_visible(weapon == FConst.WEAPON_KNIFE && isKnifePointUp && !isKnifeBloody)
	get_node("polygons/ArmR/Knife2_blood").set_visible(weapon == FConst.WEAPON_KNIFE && isKnifePointUp && isKnifeBloody)
	get_node("polygons/Body/ArmR_up/ForearmR_up/Knife").set_visible(weapon == FConst.WEAPON_KNIFE)
	get_node("polygons_turn/ArmR/Knife").set_visible(weapon == FConst.WEAPON_KNIFE)
	get_node("polygons_turn/ArmR_back/Knife_back").set_visible(weapon == FConst.WEAPON_KNIFE)


func isRecoiling():
	return isPerforming("FRecoil")


func isCasting():
	return isPerforming("FCast") || (bolt.isActive && bolt.position.x < opponent.pos.x + 100)


func setHandLMode(mode):
	if mode != handLMode:
		handLMode = mode
		
		var poly = get_node("polygons/ArmL")
		poly.get_node("Foreward").set_visible(true)
		poly.get_node("Back").set_visible(false)
		
		skeleton.armDir[L] = false
		
		poly.get_node("Foreward/HandL").set_visible(false)
		poly.get_node("Foreward/Grab").set_visible(false)
		poly.get_node("Foreward/Grab_both").set_visible(false)
		poly.get_node("Foreward/HandL_push").set_visible(false)
		poly.get_node("Foreward/Twist").set_visible(false)
		
		if mode == FConst.HANDL_OPEN:
			poly.get_node("Foreward/HandL").set_visible(true)
		elif mode == FConst.HANDL_PUSH:
			poly.get_node("Foreward/HandL_push").set_visible(true)
		elif mode == FConst.HANDL_GRAB:
			poly.get_node("Foreward/Grab").set_visible(true)
		elif mode == FConst.HANDL_BOTH:
			poly.get_node("Foreward/Grab_both").set_visible(true)
		elif mode == FConst.HANDL_TWIST:
			poly.get_node("Foreward/Twist").set_visible(true)
		elif mode == FConst.HANDL_BACK:
			skeleton.armDir[L] = true
			poly.get_node("Foreward").set_visible(false)
			poly.get_node("Back").set_visible(true)


func setDefaultHandRMode():
	if weapon == FConst.WEAPON_KNIFE:
		setHandRMode(FConst.HANDR_KNIFE)
	elif weapon == FConst.WEAPON_CAST:
		setHandRMode(FConst.HANDR_OPEN)
	else:
		setHandRMode(FConst.HANDR_OPEN)

func setHandRMode(mode):
	if weapon == FConst.WEAPON_KNIFE:
		mode = FConst.HANDR_KNIFE
	
	if mode != handRMode:
		handRMode = mode
		
		var poly = get_node("polygons/ArmR")
		poly.get_node("HandR_knife").set_visible(mode == FConst.HANDR_KNIFE)
		poly.get_node("HandR_closed").set_visible(mode == FConst.HANDR_CLOSED)
		poly.get_node("HandR_open").set_visible(mode == FConst.HANDR_OPEN)
		poly.get_node("HandR_cast").set_visible(mode == FConst.HANDR_CAST)


func dropWeapon():
	if weapon == FConst.WEAPON_KNIFE:
		game.get_node("Knife/Skeleton2D/Knife").drop()
	weapon = FConst.WEAPON_NONE
	setHandRMode(FConst.HANDR_OPEN)
	setKnifePoly()


func setIsTurn(newTurn):
	if newTurn:
		if !isTurn:
			isTurn = true
			var body = get_node("polygons/Body")
			body.get_node("Body").set_visible(false)
			body.get_node("Top").set_visible(false)
			body.get_node("Body2").set_visible(true)
			body.get_node("Top2").set_visible(hasTop)
			skeleton.arm[L].transform.origin += SHOULDERL_SHIFT
			skeleton.arm[R].transform.origin += SHOULDERR_SHIFT
			skeleton.updateArmPos()
	else:
		if isTurn:
			isTurn = false
			var body = get_node("polygons/Body")
			body.get_node("Body").set_visible(true)
			body.get_node("Top").set_visible(hasTop)
			body.get_node("Body2").set_visible(false)
			body.get_node("Top2").set_visible(false)
			skeleton.arm[L].transform.origin = skeleton.shoulderBasePos[L];
			skeleton.arm[R].transform.origin = skeleton.shoulderBasePos[R];
			skeleton.updateArmPos()


const UP_SHIFT = Vector2(-20, -120)
func setArmsUp(newUp):
	if newUp != isArmsUp:
		isArmsUp = newUp
		for i in [L,R]:
			handGlobalPos[i] += UP_SHIFT if isArmsUp else -UP_SHIFT
		skeleton.armDir[R] = isArmsUp
		var body = get_node("polygons/Body")
		body.get_node("ArmL_up").set_visible(isArmsUp)
		body.get_node("ArmR_up").set_visible(isArmsUp)
		body.get_node("Neck_up").set_visible(isArmsUp)
		get_node("polygons/ArmR").set_visible(!isArmsUp)
		get_node("polygons/ArmL").set_visible(!isArmsUp)


func setLegROpen(newOpen):
	if newOpen != isLegROpen:
		isLegROpen = newOpen
		var poly = get_node("polygons/LegR")
		poly.get_node("LegR_open").set_visible(isLegROpen)
		poly.get_node("CalfR_open").set_visible(isLegROpen)
		poly.get_node("LegR").set_visible(!isLegROpen)
		poly.get_node("CalfR").set_visible(!isLegROpen)
		poly.get_node("FootR").set_visible(!isLegROpen)


func maleGlobalHandPos(index):
	return opponent.handGlobalPos[index] + opponent.skeleton.handHipOffset[index] - \
			skeleton.heightDiff*Vector2.DOWN


func getEyePos():
	return Vector2(60, -230) + pos + skeleton.rotShift


func trueGlobalHandPos():
	var handPos = [0, 0]
	for i in [L,R]:
		handPos[i] = handGlobalPos[i] + skeleton.handHipOffset[i] + skeleton.heightDiff*Vector2.DOWN
	return handPos


func isKicking():
	return (isPerforming("FKick") || isPerforming("FKickLow")) && action.time < 0.4


func performFWinCutHard():
	perform(FWinCutHard.new(self))


func setDefaultZOrder():
	setZOrder([-2,-1,0,1,2])
	isDefaultZOrder = true

func setZOrder(zOrder):
	isDefaultZOrder = false
	var poly = get_node("polygons")
	poly.get_node("ArmL").z_index = 10*zOrder[0]
	poly.get_node("LegL").z_index = 10*zOrder[1]
	poly.get_node("Body").z_index = 10*zOrder[2]
	poly.get_node("Lay1").z_index = 10*zOrder[2]
	poly.get_node("Head").z_index = 10*zOrder[2]
	poly.get_node("LegR").z_index = 10*zOrder[3]
	poly.get_node("ArmR").z_index = 10*zOrder[4]
	
	knifePoly.z_index = poly.get_node("ArmR").z_index + 1
	knife2Poly.z_index = knifePoly.z_index
	knife2BloodPoly.z_index = knifePoly.z_index
	poly.get_node("ArmL/Back").z_index = poly.get_node("Body").z_index + 3
	poly.get_node("ArmL/Foreward/Twist").z_index = 0
	poly.get_node("ArmL/Foreward/Grab").z_index = 0

func setKnifeZOrder(index):
	isDefaultZOrder = false
	knifePoly.z_index = index
	knife2Poly.z_index = index
	knife2BloodPoly.z_index = index


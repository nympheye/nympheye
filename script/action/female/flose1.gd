extends Action
class_name FLose1

func get_class():
	return "FLose1"


const SQUIRM_PERIOD = 2.0
const SQUIRM_RATE_MULT = [1.0, 0.8]

const LEGR_SPREAD = 2


var skeleton : FemaleSkeleton
var layPoly
var basePos

var squirmRate
var squirmTimer
var targetSquirmRate
var squirmAmt

var legsBaseOpenAmt
var legsOpenAmt
var hairStartPos
var startHipAng

var bumpTimer
var bumpSize

var isSpreadL
var isSpreadR
var isFlat


func _init(humanIn).(humanIn):
	pass


func start():
	skeleton = human.skeleton
	basePos = human.pos
	layPoly = human.get_node("polygons/Lay1")
	
	targetSquirmRate = 0.0
	squirmRate = targetSquirmRate
	squirmTimer = [0, 0.6]
	squirmAmt = [0, 0]
	legsBaseOpenAmt = [0, 0]
	legsOpenAmt = [0, 0]
	bumpSize = 1
	bumpTimer = 9999
	isSpreadL = false
	isSpreadR = false
	isFlat = false
	hairStartPos = skeleton.hairLay.transform.origin
	startHipAng = skeleton.hip.get_rotation()


func canStop():
	return true

func isDone():
	return false


func perform(time, delta):
	human.breathe(delta, true)
	squirm(delta)
	processBump(delta)
	legsOpenAmt = [legsBaseOpenAmt[L] + squirmAmt[L], legsBaseOpenAmt[R] - squirmAmt[R]]
	skeleton.setLayLegsOpen(legsOpenAmt[L], legsOpenAmt[R])
	if isFlat:
		var breathe = 0.5*(1 - cos(2*PI*time/human.BREATH_TIME))
		skeleton.chestLay1.position = skeleton.chestLayStartPos + breathe*Vector2(1.7, -0.3)


func squirm(delta):
	squirmRate += 0.6*delta*(targetSquirmRate - squirmRate)
	if squirmRate <= 0:
		return
	for i in [L,R]:
		squirmTimer[i] += delta*SQUIRM_RATE_MULT[i]
		if squirmTimer[i] > SQUIRM_PERIOD*max(1, 1/squirmRate):
			squirmTimer[i] = 0
		var squirmMagnitude = 0.5*squirmRate
		var cycle = 4.4*(squirmTimer[i]/SQUIRM_PERIOD - 0.5)
		squirmAmt[i] = squirmMagnitude*squirmFunc(cycle)


func squirmFunc(cycle):
	return 3.474*(cycle - pow(cycle,5))/exp(2*cycle*cycle)


func processBump(delta):
	bumpTimer += delta
	var bumpLen = 1.5
	var bumpCycle = bumpTimer*12/bumpLen
	var breastCycle = bumpTimer*18/bumpLen
	var breastCycle2 = breastCycle*breastCycle
	var breastCycle4 = breastCycle2*breastCycle2
	var bodyMove = bumpSize*exp(-bumpCycle)*bumpCycle*bumpCycle
	human.pos = basePos + bodyMove*Vector2(-15, -3)
	var breastMove = bumpSize*exp(-breastCycle)*(breastCycle4 - 0.035*breastCycle2*breastCycle4 + 0.0002*breastCycle4*breastCycle4)
	skeleton.breastsLay1.transform.origin = breastMove*Vector2(-1, -5)
	var footCycle = bumpTimer*23/bumpLen
	var footCycle2 = breastCycle*breastCycle
	var footCycle4 = breastCycle2*breastCycle2
	var footMove = bumpSize*exp(-footCycle)*(footCycle4 - 0.035*footCycle2*footCycle4 + 0.0002*footCycle4*footCycle4)
	skeleton.footRLay1s.transform.origin = footMove*Vector2(35, 0)
	skeleton.calfRLay1s.set_rotation(0.08*footMove)
	skeleton.hairLay.set_rotation(-0.2*bodyMove)
	skeleton.hairLay.transform.origin = hairStartPos + bodyMove*Vector2(6, 1)


func bump(size):
	bumpSize = size
	bumpTimer = 0


func setLegsOpen(amtL, amtR):
	legsBaseOpenAmt[L] = amtL
	legsBaseOpenAmt[R] = amtR


func spreadL():
	if !isSpreadL:
		isSpreadL = true
		layPoly.get_node("LegL").set_visible(false)
		layPoly.get_node("LegL_body").set_visible(false)
		layPoly.get_node("CalfL").set_visible(false)
		layPoly.get_node("LegL_s").set_visible(true)
		layPoly.get_node("CalfL_s").set_visible(true)


func setYankAmt(amt):
	var amt2 = amt*amt
	var amt4 = amt2*amt2
	var amt6 = amt4*amt2
	var upAmt = 0.3*amt + 1.9*amt2 - 3.35*amt4 + 1.15*amt4*amt4
	skeleton.abdomen.set_rotation(0.8*upAmt)
	var headAmt = -0.2*amt - 0.1*amt2 + 1.7*amt4 - 1.4*amt6
	skeleton.setHeadRot(FFallBack.HEAD_ROT - 0.05*amt + 2.5*headAmt, 0.5*amt)
	
	if amt > 0.65 && !isFlat:
		isFlat = true
		layPoly.get_node("Body").set_visible(false)
		layPoly.get_node("Neck").set_visible(false)
		layPoly.get_node("Body_flat").set_visible(true)
		layPoly.get_node("Neck_flat").set_visible(true)
		layPoly.get_node("ArmL").set_visible(false)
		layPoly.get_node("ArmL_flat").set_visible(true)
		layPoly.get_node("ArmR").set_visible(false)
		layPoly.get_node("ArmR_flat").set_visible(true)
		skeleton.armLay1[L].transform.origin += Vector2(-40, -17)
		skeleton.armLay1[R].transform.origin += Vector2(-5, 25)


func setLegRLift(amt):
	legsBaseOpenAmt[R] = (1-amt)*LEGR_SPREAD - amt*21
	var calfAngle = -0.17*(1-amt)
	skeleton.calfRLay1s.set_rotation(calfAngle)
	
	if !isSpreadR && amt > 0.5:
		isSpreadR = true
		layPoly.get_node("LegR").set_visible(false)
		layPoly.get_node("LegR2").set_visible(false)
		layPoly.get_node("CalfR").set_visible(false)
		layPoly.get_node("FootR").set_visible(false)
		layPoly.get_node("LegR_s").set_visible(true)
		layPoly.get_node("CalfR_s").set_visible(true)
		layPoly.get_node("FootR_s").set_visible(true)


func setLegRLiftAng(ang):
	var thighAngle = ang - skeleton.hip.get_rotation()
	skeleton.thighRLay1s.set_rotation(thighAngle)


func setLegLSOpen(amt):
	var hipAng = skeleton.hip.get_rotation() - startHipAng
	skeleton.setLegLSConfig(-0.57*amt - 1.0*hipAng, 0.76*amt, 1.0 + 1.1*hipAng)


func setVagOpen(amt):
	amt = clamp(amt, 0, 1)
	var isInside = amt > 0.26
	human.get_node("polygons/Lay1/Hip2").set_visible(!isInside)
	human.get_node("polygons/Lay1/Hip2_open").set_visible(isInside)
	if isInside:
		amt = 1 - sqrt(clamp((amt-0.3)/(1-0.5), 0, 1))
	else:
		amt = -clamp((amt-0.12)/(1-0.6), 0, 1)
	skeleton.vagTop.transform.origin = amt*Vector2(-6, 6)
	skeleton.vagSide.transform.origin = amt*Vector2(5, 10)


func stop():
	pass

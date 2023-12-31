extends Action
class_name MLose

func get_class():
	return "MLose"


const SQUIRM_PERIOD = 2.0
const SQUIRM_RATE_MULT = [1.0, 0.8]
const CUM_DURATION = 0.45
const CUM_PERIOD = 1.8
const CUM_SPEED = 350


var male
var opponent
var holdingThroat

var squirmRate
var squirmTimer
var targetSquirmRate

var cum : Bone2D
var cumPoly : Polygon2D
var cumBasePos
var cumTimer
var cumVelocity
var isCumming
var cumCount
var cumLanded
var pulsation
var penPolySuffix


func _init(maleIn, opponentIn).(maleIn):
	male = maleIn
	opponent = opponentIn


func start():
	targetSquirmRate = 0.0
	squirmRate = targetSquirmRate
	squirmTimer = [0, 0.6]
	
	cumTimer = CUM_PERIOD/2
	cumCount = 0
	isCumming = false
	cumLanded = false
	pulsation = 0
	cum = male.skeleton.hip.get_node("Cum")
	cumBasePos = cum.transform.origin
	cumPoly = male.get_node("polygons/Lay/Cum_shoot")
	male.get_node("polygons/Lay/LegR").z_index = 5
	
	penPolySuffix = "c" if male.pen1.isCutHead else ""


func canStop():
	return false

func isDone():
	return false


func perform(time, delta):
	male.approachTargetHandPos(0.6*delta)
	male.breathe(delta, false)
	squirm(delta)
	
	if holdingThroat:
		male.targetRelHandPos[L] = Vector2(305, 10) + Vector2(1, 3)*squirmFunc(fmod(time,5.0)*0.5)
	
	cumPoly.set_visible(isCumming)
	if isCumming:
		cumPoly.color = Color(1, 1, 1, clamp(1 - pow(cumTimer/CUM_DURATION, 6), 0, 1))
		cumTimer += delta
		
		var pulseTime = cumTimer/CUM_PERIOD
		if pulseTime > 0.5:
			pulseTime -= 1.0
		pulsation = exp(-pow(14*pulseTime, 2))
		
		if cumTimer > CUM_PERIOD:
			cumTimer = 0
			cum.transform.origin = cumBasePos
			cum.set_rotation(male.skeleton.layPen1.get_rotation() - male.skeleton.baseLayPen1Ang \
						+ male.skeleton.layPen2.get_rotation() - male.skeleton.baseLayPen2Ang)
			cumVelocity = Vector2(CUM_SPEED, 0).rotated(0.2 + cum.get_rotation() - male.skeleton.hip.get_rotation())
			cumLanded = false
			cumCount += 1
		if cumTimer < CUM_DURATION:
			var down = Vector2.DOWN.rotated(-male.skeleton.hip.get_rotation())
			cumVelocity += 0.65*delta*down*PhysChain.GRAVITY
			cum.transform.origin += delta*cumVelocity
		if cumTimer > 0.95*CUM_DURATION && !cumLanded:
			cumLanded = true
			if cumCount == 1:
				male.get_node("polygons/Lay/Cum1").set_visible(true)
			elif cumCount == 2:
				male.get_node("polygons/Lay/Cum1").set_visible(false)
				male.get_node("polygons/Lay/Cum2").set_visible(true)
			elif cumCount == 3:
				male.get_node("polygons/Lay/Cum2").set_visible(false)
				male.get_node("polygons/Lay/Cum3").set_visible(true)
	

func holdThroat():
	holdingThroat = true


func squirm(delta):
	squirmRate += 0.6*delta*(targetSquirmRate - squirmRate)
	if squirmRate <= 0:
		return
	var squirmAmt = [0, 0]
	for i in [L,R]:
		squirmTimer[i] += delta*SQUIRM_RATE_MULT[i]
		if squirmTimer[i] > SQUIRM_PERIOD*max(1, 1/squirmRate):
			squirmTimer[i] = 0
		var squirmMagnitude = 0.5*squirmRate
		var cycle = 4.4*(squirmTimer[i]/SQUIRM_PERIOD - 0.5)
		squirmAmt[i] = squirmMagnitude*squirmFunc(cycle)
	male.skeleton.setLayLegMove(0.3*squirmAmt[L], -squirmAmt[R])


func squirmFunc(cycle):
	return 3.474*(cycle - pow(cycle,5))/exp(2*cycle*cycle)


func stop():
	pass

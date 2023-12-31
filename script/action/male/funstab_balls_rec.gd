extends Action
class_name FUnstabBallsRec

func get_class():
	return "FUnstabBallsRec"


const ARMR_FORWARD_TIME = 0.4


var male
var isArmDown
var startClose
var endTime


func _init(maleIn, endTimeIn).(maleIn):
	male = maleIn
	endTime = endTimeIn


func start():
	isArmDown = false
	male.targetGlobalHandPos[R] = null
	male.closingLegs = true
	male.face.setShock(0.0)


func canStop():
	return true

func isDone():
	return false


func perform(time, delta):
	
	if time < ARMR_FORWARD_TIME:
		male.targetRelHandPos[R] = Vector2(70, 50)
	else:
		male.targetRelHandPos[R] = Vector2(120, 90)
		if !isArmDown:
			isArmDown = true
			male.setZOrder([-6,-5,-2,1,2])
	
	if time > 0.2:
		if time < 1.6:
			male.targetRelHandPos[L] = Vector2(25, 50)
		else:
			male.targetRelHandPos[L] = Vector2(25, 75)
	
	if time > 0.3:
		male.approachDefaultHandAngs(0.3*delta)
	
	male.approachTargetHandPos(0.2*delta)
	
	if time > endTime:
		male.perform(MFallBack.new(male))


func stop():
	pass


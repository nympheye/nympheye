extends Action
class_name FStabRec

func get_class():
	return "FStabRec"


const AB_LEN = 0.8
const ARM_LEN = 0.4


var male
var fstab
var length


func _init(maleIn, fstabIn).(male):
	male = maleIn
	fstab = fstabIn


func start():
	if fstab.target == fstab.AB:
		length = AB_LEN
		male.recStabAb()
	elif fstab.target == fstab.ARMR:
		length = ARM_LEN
		male.recStabArmR()
	male.face.setPain(-0.1)


func canStop():
	return time >= length

func isDone():
	return time >= length


func perform(time, delta):
	var ratio = time/fstab.STABLEN
	
	if ratio > 1:
		male.targetAbAng = -6*PI/180 if fstab.target == fstab.AB else 0
		male.targetSpeed = male.walkSpeed
	
	male.approachTargetHandAng(delta, L, 0)
	male.approachTargetHandAng(delta, R, 0)
	
	male.approachTargetHeight(delta)
	male.approachTargetSpeed(delta)
	male.walk(delta)
	male.approachTargetHandPos(delta)
	male.approachTargetAbAng(0.5*delta)
	


func stop():
	pass

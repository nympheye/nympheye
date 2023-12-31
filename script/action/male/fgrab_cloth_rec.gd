extends Action
class_name FGrabClothRec

func get_class():
	return "FGrabClothRec"

var male : Human
var fgrabCloth
var soundTrigger
var done


func _init(maleIn, fgrabClothIn).(maleIn):
	male = maleIn
	fgrabCloth = fgrabClothIn


func start():
	male.targetRelHandPos[L] = Vector2(-15, 110)
	male.targetAbAng = -0.1
	soundTrigger = false
	male.face.setPain(-0.2)
	done = false


func canStop():
	return done


func isDone():
	return done


func perform(time, delta):
	if !male.opponent.isPerforming("FGrabCloth"):
		done = true
	
	male.slideFeet(delta, -110, 50)
	male.breathe(delta, true)
	male.approachTargetHandPos(delta)
	male.approachTargetAbAng(delta)
	
	var move = min(1, time/0.3)
	male.footAngles[L] = -0.3*move
	
	if !soundTrigger && time > 0.3:
		soundTrigger = true
		male.gaspSounds.play(4)


func stop():
	male.targetRelHandPos[L] = Vector2.ZERO


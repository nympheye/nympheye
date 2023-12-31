extends Action
class_name FRecoil

func get_class():
	return "FRecoil"


var opponent
var done


func _init(humanIn).(humanIn):
	opponent = humanIn.opponent
	done = false


func start():
	human.setLegsClosing(human.damage < 1)
	human.targetGlobalHandPos = [null, null]
	human.setDefaultZOrder()
	human.face.setPain(0.0)
	human.startGrabPart(human.GRAB_GUT if human.damage >= 1 else human.GRAB_GROIN)
	human.setHandLMode(FConst.HANDL_OPEN)


func canStop():
	return done

func isDone():
	return done


func perform(time, delta):
	human.setDefaultZOrder()
	
	if time < 1.2:
		human.targetSpeed = -0.8*human.walkSpeed
	else:
		human.targetSpeed = 0.0
	
	human.targetAbAng = 0.24
	human.targetHeight = 0.0
	
	human.approachTargetHeight(delta)
	human.approachTargetSpeed(delta)
	human.walk(delta)
	human.approachTargetHandPos(delta)
	human.approachTargetAbAng(delta)
	human.updateLegsClosed(delta)
	human.updateGrabPart()
	human.regen(0.5*delta)
	
	var isDead = human.damage >= 1
	if time > (1.2 if isDead else 1.5):
		done = true
		if isDead:
			human.perform(FDie.new(human))
		elif human.moraleDamage >= 1:
			human.perform(FFallKnees.new(human))


func stop():
	human.closingLegs = false
	human.face.setNeutral()
	human.stopGrabPart()

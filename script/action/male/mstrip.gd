extends Action
class_name MStrip

func get_class():
	return "MStrip"


func _init(humanIn).(humanIn):
	pass

func start():
	pass


func canStop():
	return true

func isDone():
	return !human.hasCloth


func perform(time, delta):
	human.slideFeet(delta, 0, 0)
	
	human.targetHeight = 0
	human.approachTargetHeight(delta)
	human.targetAbAng = 0
	human.approachTargetAbAng(delta)
	
	human.targetRelHandPos[L] = Vector2.ZERO
	human.targetRelHandPos[R] = Vector2(200, 90)
	
	human.approachTargetHandPos(delta)
	
	if time > 0.8:
		human.removeCloth()


func stop():
	pass

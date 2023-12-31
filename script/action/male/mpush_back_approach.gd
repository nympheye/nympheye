extends Action
class_name MPushBackApproach

func get_class():
	return "MPushBackApproach"


func _init(humanIn).(humanIn):
	pass


func start():
	pass


func canStop():
	return true


func isDone():
	return false


func perform(time, delta):
	human.isIgnoringMapLimit = true
	
	abs(human.pos.x - human.opponent.pos.x - 385 + 30) < 5
	
	var targetPosX = human.opponent.pos.x + 355
	human.approachTargetPosX(delta, targetPosX)
	human.walk(delta)
	human.approachTargetHeight(delta)
	human.approachTargetHandPos(delta)
	human.breathe(delta, true)
	if abs(human.pos.x - targetPosX) < 2:
		human.perform(MPushBack.new(human))
	
	var headMoveAmt = clamp(1 - abs(human.pos.x - targetPosX)/180, 0, 1)
	human.skeleton.neck.set_rotation(-0.05*headMoveAmt)
	human.skeleton.head.set_rotation(-0.1*headMoveAmt)


func stop():
	pass

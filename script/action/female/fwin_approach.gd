extends Action
class_name FWinApproach

func get_class():
	return "FWinApproach"


func _init(humanIn).(humanIn):
	pass


func start():
	human.face.setNeutral()


func canStop():
	return true

func isDone():
	return false


func perform(time, delta):
	human.isIgnoringMapLimit = true
	
	var targetPosX = human.opponent.pos.x + FWin.START_OFFSET
	human.breathe(delta, true)
	human.approachTargetPosX(delta, targetPosX)
	human.walk(delta)
	
	human.targetHeight = 0
	human.approachTargetHeight(delta)
	
	human.approachDefaultHandAngs(delta)
	
	human.targetRelHandPos = [Vector2.ZERO, Vector2.ZERO]
	human.approachTargetHandPos(delta)
	
	if abs(human.pos.x - targetPosX) < 2:
		human.opponent.perform(MLose.new(human.opponent, self))
		human.perform(FWin.new(human, human.opponent))
	
	var headMoveAmt = clamp(1 - abs(human.pos.x - targetPosX)/220, 0, 1)
	
	human.targetHeadAng = 0.15*headMoveAmt
	human.approachTargetHeadAng(delta)
	
	human.targetAbAng = 0.03*headMoveAmt
	human.approachTargetAbAng(delta)


func stop():
	pass

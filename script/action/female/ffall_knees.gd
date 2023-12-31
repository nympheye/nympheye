extends Action
class_name FFallKnees

func get_class():
	return "FFallKnees"


const FALL_TIME = 0.9


var startPos : Vector2
var footStartPos
var startAbAng
var startHeadAng
var sound1


func _init(humanIn).(humanIn):
	pass


func start():
	human.isSurrender = true
	human.dropWeapon()
	
	startPos = human.pos
	footStartPos = [human.footGlobalPos[L], human.footGlobalPos[R]]
	startAbAng = human.skeleton.abdomen.get_rotation()
	startHeadAng = human.skeleton.head.get_rotation()
	sound1 = false


func canStop():
	return time > FALL_TIME && human.opponent.isPerforming("MPushBack")

func isDone():
	return false


func perform(time, delta):
	var amt = min(1, time/FALL_TIME)
	var amt2 = amt*amt
	
	var footAmt = 0.5*amt + 0.5*amt2
	for i in [L,R]:
		human.footGlobalPos[i] = (1-footAmt)*footStartPos[i] + footAmt*(startPos + Vector2(-50, 0))
	
	var fallAmt = 0.1*amt + 1.5*amt2 - 0.6*amt2*amt2
	
	human.skeleton.setKneelLegConfig((1-fallAmt)*0.8, 1.0, \
			(1-fallAmt)*0.8, -(1-fallAmt)*0.8, 1.0, 1.0)
	
	human.breathe(delta, true)
	if fallAmt < 1:
		fallAmt = min(1, fallAmt + delta*1.5)
		if startPos == null:
			startPos = human.pos
		human.pos = startPos + fallAmt*Vector2(30, 270);
		var handLShift = (1 - fallAmt)*human.skeleton.handLGroinOffset + fallAmt*Vector2(50, -110)
		var handRShift = fallAmt*Vector2(85, 60)
		human.handGlobalPos = [human.pos + handLShift, human.pos + handRShift]
		var kneelPoly = human.get_node("polygons/Legs_kneel")
		if fallAmt > 0.6 && !kneelPoly.is_visible():
			human.closingLegs = false
			kneelPoly.set_visible(true)
			human.get_node("polygons/LegL").set_visible(false);
			human.get_node("polygons/LegR").set_visible(false);
	else:
		if !sound1:
			sound1 = true
			human.game.fallSounds.playRandom()
	if human.handLMode == FConst.HANDL_BACK && fallAmt > 0.3:
		human.setHandLMode(FConst.HANDL_OPEN)#setArmLBack(false)
	
	human.skeleton.abdomen.set_rotation(0.25*amt + (1-amt)*startAbAng)
	human.skeleton.head.set_rotation(-0.12*amt + (1-amt)*startHeadAng)
	human.face.setPain(-0.4)


func stop():
	pass


extends Face
class_name MaleFace


func _ready():
	pass


func setOpen(lookAng):
	setTargetConfig(Vector2.ZERO, 0, Vector2.ZERO, 0, lookAng)


func setShock(lookAng):
	setTargetConfig(Vector2(0, -1.7), 0.14, Vector2(0, 2.2), 0.22, lookAng)


func setAngry(lookAng):
	setTargetConfig(Vector2(-0.5, -0.5), -0.14, Vector2(0, 1.8), -0.14, lookAng)


func setPain(lookAng):
	setTargetConfig(Vector2(0.0, 2.0), 0.30, Vector2(1.0, -1.5), 0.15, lookAng)


func setEyesClosed():
	setPain(0)
	eyeshutPoly.set_visible(true)


func getNeutralEyeAng():
	return max(-0.18, 0.2 + atan2(human.pos.y - human.opponent.pos.y - 200, human.pos.x - human.opponent.pos.x))

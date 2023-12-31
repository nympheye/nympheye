extends Face
class_name FemaleFace


func _ready():
	pass


func setShock(lookAng):
	setTargetConfig(Vector2(0, -1.7), -0.14, Vector2(0, 2.2), -0.22, lookAng)

func setAngry(lookAng):
	setTargetConfig(Vector2(-0.5, -0.5), 0.14, Vector2(0, 1.8), 0.14, lookAng)

func setPain(lookAng):
	setTargetConfig(Vector2(0.0, 2.0), -0.25, Vector2(1.0, -1.5), -0.10, lookAng)


func setEyesClosed():
	setPain(0)
	eyeshutPoly.set_visible(true)


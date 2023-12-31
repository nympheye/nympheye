extends Ball


func _init().(Vector2(1, -22), R):
	pass


func _ready():
	severedBall.get_node("Skeleton2D/Ball").rollDir = false


func getLength():
	return 26 - 12*getRetract()

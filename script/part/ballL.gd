extends Ball


var skinPoly


func _init().(Vector2(-1, -17), L):
	pass


func _ready():
	skinPoly = male.get_node("polygons/Body/BallL/BallL/Skin")
	severedBall.get_node("Skeleton2D/Ball").rollDir = true


func _process(delta):
	var opacity = 0
	if otherBall.relaxedPoly.is_visible():
		var separation = (otherBall.transform.get_origin() - otherBall.basePos) - (transform.get_origin() - basePos)
		opacity = max(0, 1 - 0.1*separation.length_squared())
	skinPoly.color.a = opacity


func getLength():
	return 22 - 10*getRetract()


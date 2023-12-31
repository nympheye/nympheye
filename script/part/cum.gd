extends PhysChain
class_name Cum

func get_class():
	return "Cum"


const LENGTH = 20
const HANG_TIME = 2.8


var male
var lenScale
var growRate
var time
var poly
var finished
var fallVel
var globalPos


func _init().(false):
	pass


func _ready():
	male = owner.get_node("Male")
	poly = male.get_node("polygons/Body/Penis/Cum")
	physActive = false
	poly.visible = false
	finished = true


func start():
	finished = false
	physActive = true
	poly.visible = true
	rotation_degrees = -10
	time = 0
	lenScale = 0.15
	growRate = 0.1


func getAngDamp():
	return 200


func getLength():
	return LENGTH*lenScale


func parentVel():
	return get_parent().vel


func _physics_process(delta):
	if finished:
		return
	
	if growRate < 0.35:
		growRate += delta*0.25
	
	time = time + delta
	if time < HANG_TIME:
		lenScale = lenScale + growRate*delta
	else:
		if physActive:
			physActive = false
			globalPos = get_global_position()
			fallVel = Vector2(parentVel().x, 100)
		if globalPos.y < owner.groundPos:
			lenScale = lenScale*exp(-0.7*delta)
			fallVel.y = fallVel.y + 700*delta
			globalPos += delta*fallVel
			set_global_position(globalPos)
		else:
			poly.visible = false
			finished = true
			return
	
	var trans = Math.inverted(male.pen1.transform).scaled(Vector2(1, lenScale))
	trans.origin = transform.origin
	var ang = rotation
	transform = trans
	rotation = ang

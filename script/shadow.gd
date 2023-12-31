extends Node
class_name Shadow

func get_class():
	return "Shadow"


const L = 0
const R = 1

const OPACITY = 0.5


var human
var hip
var foot
var bodyPoly
var footPoly
var default


func _ready():
	hip = get_node("Skeleton2D/Hip")
	foot = [get_node("Skeleton2D/FootL"), get_node("Skeleton2D/FootR")]
	footPoly = [get_node("polygons/FootL"), get_node("polygons/FootR")]
	bodyPoly = get_node("polygons/Body")


func process():
	var ang = human.skeleton.hip.get_rotation()
	hip.set_rotation(ang)
	hip.position.x = human.pos.x
	hip.position.y = 0.3*human.pos.y
	var angOpacity = clamp(1 - 1.3*abs(ang), 0, 1)
	bodyPoly.color = Color(1, 1, 1, angOpacity*OPACITY)
	
	for i in [L, R]:
		var pos = human.footGlobalPos[i]
		pos += human.skeleton.footBasePos[i] - human.skeleton.footBasePos0[i]
		foot[i].position.x = pos.x
		foot[i].position.y = 0.2*pos.y
		var opacity = angOpacity*clamp(OPACITY - 0.0001*pos.y*pos.y, 0, OPACITY)
		footPoly[i].color = Color(1, 1, 1, opacity)


func setVisible(visible):
	get_node("polygons").set_visible(visible)


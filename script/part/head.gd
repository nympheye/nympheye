extends Node2D
class_name Head

func get_class():
	return "Head"


var pen : Pen1
var male
var isSevered


func _init():
	isSevered = false


func _ready():
	male = owner.get_node("Male")
	pen = male.get_node("Skeleton2D/Hip/Groin/Penis1")
	

func sever():
	if !isSevered:
		isSevered = true
		get_node("polygons").z_index = male.get_node("polygons/Body").z_index
		var bone = get_node("Skeleton2D/Head")
		position = Vector2.ZERO
		bone.position = male.pos + Vector2(0, 20).rotated(male.pen1.get_rotation()) + Vector2(-7, 69)
		bone.set_scale(male.options.msoftScale*Vector2(1, male.options.mpenWidth))
		bone.fall(Vector2(-200, -150), -2.0 + 4.0*randf())
		get_node("polygons/Head").set_visible(true)


func fall(velX):
	if isSevered:
		var bone = get_node("Skeleton2D/Head")
		bone.fall(velX)


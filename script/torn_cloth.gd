extends Bone2D
class_name TornCloth


var DRAG = 1.6

var isFalling
var vel


func _init():
	isFalling = false
	vel = Vector2.ZERO


func _ready():
	pass


func _physics_process(delta):
	if isFalling:
		vel.y += delta*PhysChain.GRAVITY
		vel -= delta*vel*DRAG
		transform.origin += delta*vel
		
		if transform.origin.y > owner.groundPos:
			isFalling = false
			get_node("../../polygons").set_visible(false)
			setPhysActive(self, false)


func fall():
	isFalling = true
	setPhysActive(self, true)


func setPhysActive(node, active):
	for child in node.get_children():
		if child is ClothSegment:
			child.physActive = active
			setPhysActive(child, active)


func parentVel():
	return get_parent().vel

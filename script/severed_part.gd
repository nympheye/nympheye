extends Bone2D
class_name SeveredPart


const L = 0
const R = 1


var DRAG = 1.5
var ROLL_TIME = 0.4

var isFalling
var isEnabled
var rollTimer
var vel
var accel
var rollDir
var landPos
var angVel
var landAng


func _ready():
	isFalling = false
	isEnabled = false
	rollTimer = 0
	vel = Vector2.ZERO
	angVel = 0
	accel = PhysChain.GRAVITY


func _physics_process(delta):
	if isEnabled:
		if isFalling:
			accel = min(1.5*PhysChain.GRAVITY, accel + delta*1.5*PhysChain.GRAVITY)
			vel.y += delta*accel
			vel -= delta*vel*DRAG
			position += delta*vel
			set_rotation(get_rotation() + delta*angVel)
			if position.y > owner.groundPos + 18:
				isFalling = false
				vel = Vector2.ZERO
				landPos = position
				landAng = get_rotation()
				landed()
		else:
			rollTimer += delta
			var ratio = rollTimer/ROLL_TIME
			var ratio2 = ratio*ratio
			var rollAmt = 4*ratio - 3.8*ratio2 + 0.8*ratio2*ratio2
			var rollSign = (1 if rollDir else -1)
			set_rotation(landAng + rollSign*rollAmt*PI/2)
			position = landPos + Vector2(10*sin(get_rotation()) + 4*rollSign*ratio, 4*ratio)
			if rollTimer > ROLL_TIME:
				isEnabled = false


func fall(startVel, startAngVel):
	isFalling = true
	isEnabled = true
	vel = startVel
	angVel = startAngVel


func landed():
	get_owner().stepSounds.playRandomDb(5)


func parentVel():
	return get_parent().vel

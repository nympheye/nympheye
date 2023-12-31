extends Sprite
class_name Bolt

func get_class():
	return "Bolt"


var human
var isActive
var vel
var miss
var targetPos
var time
var targetDisp
var targetSize


func _init():
	pass


func _ready():
	pass


func cast(from, to, velIn, missIn):
	vel = velIn
	isActive = true
	set_visible(true)
	time = 0.0
	position = from
	updateTarget(to)
	miss = missIn
	targetSize = 0
	


func _physics_process(delta):
	if !isActive:
		return
	
	time += delta
	
	var dist = targetDisp.length()
	
	var dpos = delta*vel
	
	if dist < 1.1*dpos + targetSize:
		if miss:
			deactivate()
		else:
			if human.opponent.recBolt(self):
				deactivate()
			else:
				miss = true
				updateTarget(position + targetDisp)
				dist = targetDisp.length()
	
	position += dpos*targetDisp/dist


func getTargetPos():
	return position + targetDisp


func updateTarget(to):
	if miss:
		var hitBottom = false
		if targetDisp.y > 0:
			var groundPos = human.game.groundPos - 140
			var alt = groundPos - position.y
			if alt < 0:
				deactivate()
				return
			var bottomHitX = position.x + alt*targetDisp.x/targetDisp.y
			if abs(bottomHitX) < Game.MAP_LIMIT:
				hitBottom = true
				to = Vector2(bottomHitX, groundPos)
		if !hitBottom:
			to += (1000.0/targetDisp.length())*targetDisp
	targetDisp = to - position
	set_rotation(atan2(targetDisp.y, targetDisp.x))


func deactivate():
	isActive = false
	set_visible(false)

extends LinPhysChain
class_name Ball

func get_class():
	return "Ball"


const ATTR = 12e-2
const PEN_MIN_ANGLE = 8
const MAX_SEPARATION = 15
const AB_HIT_ANG = [230, 235]


var otherBall : Ball
var side
var pen : Pen1
var origBasePos : Vector2
var origRestPos : Vector2
var retractVect : Vector2
var startScale : Vector2
var male
var options
var health
var isRetract
var isCrushed
var isExposed
var isSevered
var relaxedPoly : Polygon2D
var retractedPoly : Polygon2D
var exposedPoly : Polygon2D
var exposedCrushedPoly : Polygon2D
var crushedPoly : Polygon2D
var twistPoly : Polygon2D
var severedPoly : Polygon2D
var severedBall
var basePosOffset : Vector2


func _init(retractVectIn, sideIn).(false, Vector2(25, 25)):
	retractVect = retractVectIn
	side = sideIn
	health = 1.0
	isRetract = false
	isCrushed = false
	isExposed = false
	isSevered = false


func _ready():
	options = get_node("/root/Options")
	origBasePos = basePos
	origRestPos = self.rest.origin
	basePosOffset = Vector2.ZERO
	male = owner.get_node("Male")
	pen = male.get_node("Skeleton2D/Hip/Groin/Penis1")
	startScale = options.mballScale*get_scale()
	setScale(1.0, 1.0)
	
	var body = male.get_node("polygons/Body")
	var label = "R" if side == R else "L"
	relaxedPoly = body.get_node("Ball" + label + "/Ball" + label)
	retractedPoly = body.get_node("Ball" + label + "/Ball" + label + "r")
	exposedPoly = body.get_node("Ball" + label + "/Ball" + label + "e")
	exposedCrushedPoly = body.get_node("Ball" + label + "/Ball" + label + "ed")
	crushedPoly = body.get_node("Ball" + label + "/Ball" + label + "d")
	twistPoly = body.get_node("Ball" + label + "/Ball" + label + "t")
	severedPoly = body.get_node("Ball" + label + "/Ball" + label + "s")
	severedBall = get_owner().get_node("Ball" + label)
	
	var siblings = get_parent().get_children()
	for s in siblings:
		if s.get_class() == "Ball" && s != self:
			otherBall = s
	


func _process(delta):
	if !physActive:
		return
	basePos = origBasePos + basePosOffset + retractVect*getRetract()
	
	var separation = otherBall.transform.origin - transform.origin
	var sepLen = separation.length()
	if sepLen > MAX_SEPARATION:
		var linkStr = 1.0
		if health < 0 && !isExposed:
			linkStr *= 0.5
		if isExposed:
			linkStr *= 0.2
		if otherBall.isExposed:
			linkStr *= 0.2
		if isSevered:
			linkStr *= 0.4
		position += 0.005*delta*linkStr*(sepLen - MAX_SEPARATION)*separation/sepLen
	


func getRetract():
	if isCrushed:
		return 0.3
	elif isExposed || isSevered:
		return 0
	else:
		return male.retract


const FADE_START = 0.6
const FADE_END = 0.9
const FADE_MID = 0.5*(FADE_START + FADE_END)
func setRetract(amt):
	var retractedRatio = clamp((amt - FADE_START)/(FADE_MID - FADE_START), 0, 1)
	var relaxedRatio = 1 - clamp((amt - FADE_MID)/(FADE_END - FADE_MID), 0, 1)
	retractedPoly.color.a = retractedRatio
	relaxedPoly.color.a = relaxedRatio


func recDamage(damage):
	health -= male.options.mdamageMult*damage
	male.recGenitalDamage(damage)


func crush():
	if !isCrushed && !isSevered:
		isCrushed = true
		health = 0
		setPoly()
		if isExposed:
			male.innard(position + Vector2(0, 50), false, exposedCrushedPoly)
			male.bleed(self, Vector2(0, 50), false, exposedCrushedPoly, 6, 0.0)


func expose():
	if !isExposed:
		if options.goreEnabled:
			isExposed = true
			setPoly()
			position.y -= 25
			male.recDamage(0.03)
			male.recGenitalDamage(0.25)
		else:
			male.recDamage(0.06)
			male.recGenitalDamage(0.25)


func sever():
	if !isSevered:
		isSevered = true
		health = 0
		setPoly()
		if isExposed:
			var label = "R" if side == R else "L"
			severedBall.get_node("polygons/Ball" + label + ("d" if isCrushed else "")).set_visible(true)
			severedBall.get_node("polygons").z_index = male.get_node("polygons/Body").z_index
			var bone = severedBall.get_node("Skeleton2D/Ball")
			bone.set_scale(male.options.mballScale*bone.get_scale())
			male.bleed(self, Vector2(0, 50), false, severedPoly, 3, 0.0)
			male.sperm(position + Vector2(0, 50), severedPoly)


func fall():
	fallPos(Vector2(0, 62), Vector2(-40 if side == L else -65, 0), 0.3*(2*randf() - 1))

func fallPos(offset, vel, angVel):
	if isSevered:
		severedBall.position = Vector2.ZERO
		var bone = severedBall.get_node("Skeleton2D/Ball")
		bone.position = male.pos + position + offset
		bone.fall(vel, angVel)


func setScale(scaleX, scaleY):
	set_scale(Vector2(startScale.x*scaleX, startScale.y*scaleY))


func setPoly():
	relaxedPoly.set_visible(false)
	retractedPoly.set_visible(false)
	exposedPoly.set_visible(false)
	crushedPoly.set_visible(false)
	twistPoly.set_visible(false)
	severedPoly.set_visible(false)
	exposedCrushedPoly.set_visible(false)
	if isCrushed && !isExposed:
		crushedPoly.set_visible(true)
	elif isCrushed && isExposed && !isSevered:
		exposedCrushedPoly.set_visible(true)
	elif isSevered && !isExposed:
		twistPoly.set_visible(true)
	elif isSevered && isExposed:
		severedPoly.set_visible(true)
	elif isExposed && !isSevered && !isCrushed:
		exposedPoly.set_visible(true)
	elif isRetract:
		retractedPoly.set_visible(true)
		relaxedPoly.set_visible(true)


func parentVel():
	return male.vel


func getAngForce():
	if !isExposed:
		var retract = getRetract()
		return [[75+10*retract,16e4],[88+3*retract,0],[93+3*retract,0],[110-8*retract,-12e4]]
	else:
		return [[60,4e4],[80,0],[100,0],[120,-2e4]]


func externalForce():
	var force = Vector2.ZERO
	var ballRot = getRotation()
	
	if !isExposed && !otherBall.isExposed && health > 0:
		var separation = (otherBall.transform.get_origin() - otherBall.basePos) - (transform.get_origin() - basePos)
		var diff = separation.length_squared() - 10
		if diff > 0:
			force += ATTR*separation*diff
	
	if !(isExposed || isSevered) && !male.isPerforming("FGrabBallRec"):
		var penRot = pen.getRotation()
		var ang = penRot - (ballRot - 90)
		var minAng = PEN_MIN_ANGLE
		if penRot > 0 && ang < minAng:
			force += Vector2(7e2*(minAng - max(0,ang)), 0)
	
	if ballRot > AB_HIT_ANG[side]:
		if vel.x > male.vel.x:
			force += Vector2(-6e2 - 6e2*(ballRot - AB_HIT_ANG[side]), 0)
		else:
			force += Vector2(-6e2, 0)
	
	return .externalForce() + force


func linParentVel():
	return male.vel


func getAngDamp():
	if isExposed || isSevered:
		return 150 if isSevered else 70
	return 300*(1 + 2*getRetract())


func getLength():
	return 25


func getLinForce():
	var force = 300
	if isExposed || isSevered:
		force *= 0.5
	elif male != null:
		force *= 1 + 2*getRetract()
	return Vector2(force, force)


func getLinDamp():
	if isExposed:
		return 17
	return 30*(1 + 1*getRetract())

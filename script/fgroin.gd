extends Node2D
class_name FGroin


const L = 0
const R = 1

const TRY1 = 1
const TRY2 = 2
const FINISH = 3
const RUB = 4
const PEN = 5
const DEEP = 6

const LO = 0
const RO = 1
const LI = 2
const RI = 3

const TRY1_DURATION = 2.0
const TRY2_DURATION = 2.0
const FINISH_DURATION = 3.0
const RUB_DURATION = 2.0
const PEN_DURATION = 2.2
const DEEP_DURATION = 2.8


var female
var poly
var camera

var hip : Bone2D
var lip
var lipBasePos
var clit : Bone2D
var penis : Bone2D

var lipROPoly
var lipROPenPoly
var lipRIPoly

var clitBasePos
var penisBasePos

var time
var action

var contactAng
var contactAngSpeed
var penisAng

var clitShift = 0
var lipShift = 0
var prevContactAngle


func _ready():
	
	female = get_owner().get_node("Female")
	camera = get_owner().get_node("Camera2D")
	time = 9999
	action = -1
	
	poly = get_node("polygons")
	poly.set_visible(false)
	
	hip = get_node("Skeleton2D/Hip")
	lip = [hip.get_node("LipLO"), hip.get_node("LipRO"), hip.get_node("LipLI"), hip.get_node("LipRI")]
	clit = hip.get_node("Clit")
	penis = hip.get_node("Penis")
	
	lipROPoly = get_node("polygons/LipRO")
	lipROPenPoly = get_node("polygons/LipRO_pen")
	lipRIPoly = get_node("polygons/LipRI")
	
	lipBasePos = [lip[LO].position, lip[RO].position, lip[LI].position, lip[RI].position]
	clitBasePos = clit.position
	penisBasePos = penis.position


func _process(delta):
	time += delta
	if action == TRY1:
		if time < TRY1_DURATION:
			setTry1(delta, time/TRY1_DURATION)
		else:
			end()
	elif action == TRY2:
		if time < TRY2_DURATION:
			setTry2(delta, time/TRY2_DURATION)
		else:
			end()
	elif action == FINISH:
		if time < FINISH_DURATION:
			setFinish(delta, time/FINISH_DURATION)
		else:
			end()
	elif action == RUB:
		if time < RUB_DURATION:
			setRub(delta, time/RUB_DURATION)
		else:
			end()
	elif action == PEN:
		if time < PEN_DURATION:
			setPen(delta, time/PEN_DURATION)
		else:
			end()
	elif action == DEEP:
		if time < DEEP_DURATION:
			setDeep(delta, time/DEEP_DURATION)
		else:
			end()
	
	position = camera.position + Vector2(400, 0) 


func perform(type, contactAngIn, contactAngSpeedIn, penisAngIn):
	action = type
	time = 0
	poly.set_visible(true)
	poly.get_node("LegL").set_visible(!female.isLegROpen)
	poly.get_node("LegL_open").set_visible(female.isLegROpen)
	poly.get_node("LegR").set_visible(!female.isLegROpen)
	poly.get_node("LegR_open").set_visible(female.isLegROpen)
	contactAng = contactAngIn
	contactAngSpeed = contactAngSpeedIn
	penisAng = penisAngIn
	prevContactAngle = contactAng
	if action == RUB:
		clitShift = 0


func setTry1(delta, amt):
	pass


func setTry2(delta, amt):
	pass


func setFinish(delta, amt):
	pass


func setRub(delta, amt):
	hip.set_rotation(0.96)
	var angSpeed = 0.3*sign(contactAngSpeed)*sqrt(abs(contactAngSpeed))
	var ang = contactAng + (amt - 0.3)*angSpeed
	var penAng = penisAng + (amt - 0.3)*0.3*angSpeed
	setPenPos(delta, ang, 0.10, penAng)


func setPen(delta, amt):
	var amt2 = amt*amt
	var amt4 = amt2*amt2
	hip.set_rotation(0.96)
	var ang = 1.05
	var pen = 2.2*amt2 - 1.2*amt4
	var penAng = -0.6 + 0.4*pen
	setPenPos(delta, ang, 0.6*pen, penAng)

func setDeep(delta, amt):
	hip.set_rotation(0.96)


const CLIT_ANG = 35*PI/180
const LIP_ANG = 50*PI/180
const PEN_ANG = 60*PI/180
func setPenPos(delta, contactAng, depth, penAng):
	var isDeep = false
	lipROPoly.set_visible(!isDeep)
	lipROPenPoly.set_visible(isDeep)
	lipRIPoly.set_visible(!isDeep)
	
	var angChange = contactAng - prevContactAngle
	prevContactAngle = contactAng
	
	var clitDang = (contactAng - CLIT_ANG)/0.25
	var clitStick = clamp(depth/0.1, 0, 1)
	clitStick *= clamp(1 - pow(abs(clitDang), 3), 0, 1)
	clitShift += clitStick*angChange
	var maxClitShift = 0.2*clitStick
	if abs(clitShift) > maxClitShift:
		clitShift -= sign(clitShift)*delta*min(1.2, abs(clitShift)-maxClitShift)
	clit.position = contactPos(clitShift, clitBasePos)
	
	var lipDang = (contactAng - LIP_ANG)/0.4
	var lipStick = clamp(depth/0.1, 0, 1)
	lipStick *= clamp(1 - pow(abs(lipDang), 3), 0, 1)
	lipShift += lipStick*angChange
	var maxLipShift = 0.2*lipStick
	if abs(lipShift) > maxLipShift:
		lipShift -= sign(lipShift)*delta*min(1.2, abs(lipShift)-maxLipShift)
	for i in [LO, RO, LI, RI]:
		lip[i].position = contactPos(lipShift, lipBasePos[i])
	
	var penDang = (contactAng - PEN_ANG)/0.3
	var pen = clamp(depth/0.5, 0, 1)
	pen *= clamp(1 - pow(abs(penDang), 3), 0, 1)
	var open = pen
	clit.position += open*Vector2(-7, -10)
	lip[LO].position += open*Vector2(18, 1)
	lip[LI].position += open*Vector2(18, 0)
	lip[RI].position += open*Vector2(-18, 0)
	var penRO = pen if !isDeep else pen - 0.7
	lip[RO].position += penRO*Vector2(-18, 0)
	
	penis.position = contactPos(contactAng - 0.9, penisBasePos)
	penis.position += pen*Vector2(-60, 0)
	


func contactPos(dang, basePos):
	var vagPos = Vector2(-93,52)
	basePos = basePos - vagPos
	var ang = dang + atan2(basePos.y, basePos.x)
	var rad = basePos.length()
	return vagPos + rad*Vector2(cos(ang), sin(ang))


func end():
	poly.set_visible(false)
	female.game.setSlowmo(1.0)
	hip.set_rotation(0)

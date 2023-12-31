extends Bone2D
class_name Face


const TRANSITION_TIME = 0.16
const TRANSITION_RATE = 1/TRANSITION_TIME


var jaw : Bone2D
var eyeU : Bone2D
var eyeL : Bone2D
var eyebrow : Bone2D
var iris : Bone2D

var eyeUBasePos : Vector2
var eyeUBaseAng
var eyeLBasePos : Vector2
var eyebrowBaseAng
var irisBaseAng

var human
var moveTimer
var isNeutral
var eyeUMoveVect : Vector2
var eyeUAngRate
var eyeLMoveVect : Vector2
var eyebrowAngRate
var irisAngRate
var eyeshutPoly


func _ready():
	isNeutral = true
	moveTimer = 0
	
	jaw = get_node("Jaw")
	eyeU = get_node("EyeU")
	eyeL = get_node("EyeL")
	eyebrow = eyeU.get_node("Eyebrow")
	iris = get_node("Iris")
	
	eyeUBasePos = eyeU.transform.origin
	eyeUBaseAng = eyeU.get_rotation()
	eyeLBasePos = eyeL.transform.origin
	eyebrowBaseAng = eyebrow.get_rotation()
	irisBaseAng = iris.get_rotation()


func _process(delta):
	if moveTimer > 0:
		if moveTimer < delta:
			moveTimer = 0
			if isNeutral:
				eyeU.transform.origin = eyeUBasePos
				eyeU.set_rotation(eyeUBaseAng)
				eyeL.transform.origin = eyeLBasePos
				eyebrow.set_rotation(eyebrowBaseAng)
				iris.set_rotation(irisBaseAng)
		else:
			moveTimer -= delta
		eyeU.transform.origin += delta*eyeUMoveVect
		eyeU.set_rotation(eyeU.get_rotation() + delta*eyeUAngRate)
		eyeL.transform.origin += delta*eyeLMoveVect
		eyebrow.set_rotation(eyebrow.get_rotation() + delta*eyebrowAngRate)
		iris.set_rotation(iris.get_rotation() + delta*irisAngRate)


func setNeutral():
	setTargetConfig(Vector2.ZERO, 0, Vector2.ZERO, 0, getNeutralEyeAng())
	isNeutral = true


func setTargetConfig(eyeUPos, eyeUAng, eyeLPos, eyebrowAng, irisAng):
	moveTimer = TRANSITION_TIME
	eyeUMoveVect = TRANSITION_RATE*(eyeUBasePos + eyeUPos - eyeU.transform.origin)
	eyeUAngRate = TRANSITION_RATE*Math.angleDiff(eyeU.get_rotation(), eyeUBaseAng + eyeUAng)
	eyeLMoveVect = TRANSITION_RATE*(eyeLBasePos + eyeLPos - eyeL.transform.origin)
	eyebrowAngRate = TRANSITION_RATE*Math.angleDiff(eyebrow.get_rotation(), eyebrowBaseAng + eyebrowAng)
	irisAngRate = TRANSITION_RATE*Math.angleDiff(iris.get_rotation(), irisBaseAng + irisAng)
	eyeshutPoly.set_visible(false)
	isNeutral = false


func setJawOpen(frac):
	jaw.set_rotation((10*frac - 5)*PI/180)


func getNeutralEyeAng():
	return 0.0


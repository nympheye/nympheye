extends Node
class_name FKickSkeleton

const L = 0
const R = 1

var footL : Bone2D
var thighL : Bone2D
var hip : Bone2D
var thighR : Bone2D
var calfR : Bone2D
var toeR : Bone2D
var head : Bone2D
var hair : Bone2D
var breast : Bone2D
var armL : Bone2D
var legLLen
var thighRLen
var calfRLen
var legLAng0
var hipAng0

func _ready():
	footL = get_node("FootL")
	thighL = footL.get_node("ThighL")
	hip = thighL.get_node("Hip")
	head = hip.get_node("Head")
	hair = head.get_node("Hair")
	breast = hip.get_node("Breast")
	armL = hip.get_node("ArmL")
	thighR = hip.get_node("ThighR")
	calfR = thighR.get_node("CalfR")
	toeR = calfR.get_node("ToeR")
	
	legLLen = hip.transform.origin.length()
	thighRLen = calfR.transform.origin.length()
	calfRLen = toeR.transform.origin.length()
	legLAng0 = thighL.get_rotation()
	hipAng0 = hip.get_rotation()


func setConfig(footRPos, legLAng, hipAng, thighScale, calfScale):
	hipAng -= legLAng
	legLAng += legLAng0
	hipAng += hipAng0
	thighL.set_rotation(legLAng)
	hip.set_rotation(hipAng)
	
	var hipRPos = hip.position.rotated(legLAng) + thighR.position.rotated(legLAng + hipAng)
	
	var angs = HumanSkeleton.compute_angles(footRPos - hipRPos, thighRLen*thighScale, calfRLen*calfScale, true)
	var thighAng = angs[0] - (legLAng + hipAng)
	var calfAng = angs[1] - angs[0]
	
	thighR.set_rotation(thighAng)
	thighR.set_scale(Vector2(thighScale, 1.0))
	
	var calfTrans = Math.scaledTrans(-calfAng, 1/thighScale)
	calfTrans = calfTrans.scaled(Vector2(calfScale, 1.0)).rotated(calfAng)
	calfTrans.origin = calfR.transform.origin
	calfR.transform = calfTrans
	

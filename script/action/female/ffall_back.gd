extends Action
class_name FFallBack

func get_class():
	return "FFallBack"


const FALL_TIME = 1.5
const NECK_ROT = -0.5
const HEAD_ROT = -0.15
const FALL_SHIFT = Vector2(-30, -60)


var startPos
var startHandPos
var sound1

var skeleton
var thighL : Bone2D
var thighR : Bone2D
var calfR : Bone2D
var kneelFootR : Bone2D
var thighLStartAng
var thighRStartAng
var calfRStartAng
var torsoStartPos
var abStartAng
var headStartAng
var neckStartAng


func _init(humanIn).(humanIn):
	pass


func start():
	startHandPos = [human.handGlobalPos[L], human.handGlobalPos[R]]
	startPos = human.pos
	human.face.setPain(0)
	skeleton = human.skeleton
	sound1 = false
	
	var hip = human.skeleton.hip
	thighL = hip.get_node("ThighL_kneel")
	thighR = hip.get_node("ThighR_kneel")
	calfR = thighR.get_node("CalfR_kneel")
	kneelFootR = calfR.get_node("FootR_kneel")
	thighLStartAng = thighL.get_rotation()
	thighRStartAng = thighR.get_rotation()
	calfRStartAng = calfR.get_rotation()
	torsoStartPos = skeleton.torso.position
	abStartAng = skeleton.abdomen.get_rotation()
	headStartAng = skeleton.head.get_rotation()
	neckStartAng = skeleton.neck.get_rotation()
	
	human.setDefaultZOrder()
	


func canStop():
	return time > FALL_TIME

func isDone():
	return false


func perform(time, delta):
	human.breathe(delta, true)
	
	var fallAmt = min(1, time/FALL_TIME)
	var fallAmt2 = fallAmt*fallAmt
	var fallAmt3 = fallAmt2*fallAmt
	var fallAmt4 = fallAmt3*fallAmt
	var upAmt = 1 - fallAmt
	var upAmt2 = upAmt*upAmt
	var upAmt3 = upAmt2*upAmt
	var upAmt4 = upAmt3*upAmt
	
	var armRMove = 0.4*fallAmt + 1.6*fallAmt2 - 1.0*fallAmt4
	
	human.targetGlobalHandPos[R] = startHandPos[R] + armRMove*Vector2(-295, 40)
	human.approachTargetHandPos(delta)
	
	var moveAmt = 0.5*fallAmt + 1.2*fallAmt2 - 0.7*fallAmt4
	human.pos = startPos + moveAmt*FALL_SHIFT
	
	var hipRotAmt = 0.5*fallAmt + 1.3*fallAmt2 - 0.8*fallAmt4 #var hipRotAmt = 1 - upAmt2
	human.skeleton.hip.set_rotation(-hipRotAmt*1.4)
	var abRotAmt = fallAmt - 1.2*fallAmt4 + 0.2*fallAmt4*fallAmt4
	human.skeleton.abdomen.set_rotation(abRotAmt*1.5 + upAmt*abStartAng)
	human.skeleton.torso.transform.origin = torsoStartPos + hipRotAmt*Vector2(0, 10)
	
	var layPoly = human.get_node("polygons/Lay1")
	if fallAmt > 0.68:
		if !layPoly.is_visible():
			layPoly.set_visible(true)
			human.skeleton.neck.set_rotation(-0.15)
			human.get_node("polygons/Legs_kneel").set_visible(false)
			human.get_node("polygons/Body").set_visible(false)
			human.get_node("polygons/ArmL").set_visible(false)
			human.get_node("polygons/ArmR").set_visible(false)
			human.get_node("polygons/Head/HairBL").set_visible(false)
			human.get_node("polygons/Head/HairBR").set_visible(false)
			human.get_node("polygons/Head/HairBR_lay").set_visible(true)
			human.get_node("polygons/Head").z_index = -4
		
		var legLAmt = upAmt*upAmt
		var thighAng = [-legLAmt*2.5, -upAmt*1.0]
		var calfAng = [-legLAmt*2.2, upAmt*2.0]
		var thighScale = [1.0-0.5*legLAmt, 1.0]
		var calfScale = [1-2.8*legLAmt, 1-0.7*upAmt]
		skeleton.setLayLegConfig(thighAng, calfAng, thighScale, calfScale)
	else:
		var legLScale = 1.0 + 0.55*fallAmt*fallAmt
		human.skeleton.setKneelLegConfig(fallAmt*1.8, legLScale, \
					fallAmt*1.6, -fallAmt*1.1, 1.0 - 0.15*fallAmt, 1 - 0.5*fallAmt)
		kneelFootR.set_scale(Vector2(1 + 0.2*fallAmt, 1.0))
	
	if fallAmt > 0.3 && !human.handLMode == 1:#Female.HANDL_OPEN:
		human.setHandLMode(FConst.HANDL_BACK)#setArmLBack(true)
	
	skeleton.placeLayArms(human.trueGlobalHandPos())
	
	skeleton.hairLay.set_rotation(-upAmt*2.0)
	skeleton.hairLay.transform.origin = skeleton.hairLayStartPos + upAmt*Vector2(0, 200)
	
	skeleton.neck.set_rotation(NECK_ROT*fallAmt + upAmt*neckStartAng)
	skeleton.setHeadRot(HEAD_ROT*fallAmt + upAmt*headStartAng, 0)
	
	if time > FALL_TIME:
		if !sound1:
			sound1 = true
			human.hitSounds.play(8)
			human.get_owner().fallSounds.playRandom()
		var bounceAmt = min(1, (time - FALL_TIME)/0.4)
		var bounceAmt2 = bounceAmt*bounceAmt
		bounceAmt = bounceAmt - 2*bounceAmt2 + bounceAmt2*bounceAmt2
		skeleton.breastsLay1.transform.origin = bounceAmt*Vector2(-6, -22)
		
		var headBounceAmt = min(1, (time - FALL_TIME)/0.55)
		var headBounceAmt2 = headBounceAmt*headBounceAmt
		headBounceAmt = 2.5*headBounceAmt - 3.8*headBounceAmt2 + 1.3*headBounceAmt2*headBounceAmt2
		skeleton.neck.set_rotation(NECK_ROT + headBounceAmt*0.12)
		skeleton.head.set_rotation(HEAD_ROT + headBounceAmt*0.06)
	


func stop():
	pass

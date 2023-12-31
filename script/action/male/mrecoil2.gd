extends Action
class_name MRecoil2

func get_class():
	return "MRecoil2"


const LEN = 7.0
const RECOIL_LEN = 0.22*LEN
const FALL_LEN = 0.18*LEN
const GETUP_LEN = 0.27*LEN
const WAIT2_LEN = 0.10*LEN
const WAIT_LEN = LEN - RECOIL_LEN - FALL_LEN - GETUP_LEN - WAIT2_LEN

const DROP_SHIFT = Vector2(-85, 250)
const FOOTL_SHIFT = Vector2(185, 0)
const FOOTR_SHIFT = Vector2(280, 0)
const HANDR_STAND_POS = Vector2(-130, -40)
const HANDR_KNEEL_POS = Vector2(-140, -120)
const FOOTL_ROT = -0.7
const FOOTR_ROT = -1.4
const THIGHL_DSCALE = 0.2
const CALFL_DSCALE = 0.0
const THIGHR_DSCALE = -0.1
const CALFR_DSCALE = -0.1


var fallPos
var isFoot2
var sound1
var blockingHigh


func _init(humanIn).(humanIn):
	pass

func start():
	human.closingLegs = true
	human.targetGlobalHandPos = [null, null]
	human.setZOrder([-5,-4,-3,4,3])
	human.face.setShock(-0.2)
	human.startGrabPart(human.GRAB_GROIN)
	isFoot2 = false
	sound1 = false


func canStop():
	return time > LEN - 1.0

func isDone():
	return time > LEN


func perform(time, delta):
	if time < 0.8*RECOIL_LEN:
		human.targetSpeed = 0.7*human.walkSpeed
	else:
		human.targetSpeed = 0.0
	
	human.updateGrabPart()
	
	if time < RECOIL_LEN:
		human.targetRelHandPos[R] = HANDR_STAND_POS
		human.targetHeight = 0
		human.approachTargetHeight(0.3*delta)
		human.approachTargetSpeed(delta)
		human.walk(delta)
	elif time < RECOIL_LEN + FALL_LEN:
		if fallPos == null:
			fallPos = human.pos
			human.crySounds.playRandom()
			human.face.setPain(0.0)
		var dt = time - RECOIL_LEN
		var amt = dt/FALL_LEN
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var fallAmt = 0.4*amt + 1.2*amt2 - 0.6*amt4
		human.targetHeight = DROP_SHIFT.y*fallAmt
		human.approachTargetHeight(delta)
		human.pos.x = fallPos.x + fallAmt*DROP_SHIFT.x
		human.legScale[L] = [1.0 + THIGHL_DSCALE*fallAmt, 1.0 + CALFL_DSCALE*fallAmt]
		human.legScale[R] = [1.0 + THIGHR_DSCALE*fallAmt, 1.0 + CALFR_DSCALE*fallAmt]
		human.footGlobalPos[L] = Vector2(human.pos.x, 0) + fallAmt*FOOTL_SHIFT
		human.footGlobalPos[R] = Vector2(human.pos.x, 0) + fallAmt*FOOTR_SHIFT
		human.footAngles[L] = FOOTL_ROT*fallAmt
		human.footAngles[R] = FOOTR_ROT*fallAmt
		human.targetRelHandPos[R] = HANDR_KNEEL_POS
		if !isFoot2 && amt > 0.75:
			isFoot2 = true
			human.get_node("polygons/LegL/FootL").set_visible(false)
			human.get_node("polygons/LegL/FootL2").set_visible(true)
	elif time < RECOIL_LEN + FALL_LEN + WAIT_LEN:
		human.legScale[L] = [1.0 + THIGHL_DSCALE, 1.0 + CALFL_DSCALE]
		human.legScale[R] = [1.0 + THIGHR_DSCALE, 1.0 + CALFR_DSCALE]
		human.footAngles[L] = FOOTL_ROT
		human.footAngles[R] = FOOTR_ROT
		human.targetRelHandPos[R] = HANDR_KNEEL_POS
		if !sound1:
			sound1 = true
			human.game.fallSounds.playRandom()
			human.startCrying()
			human.setZOrder([-5,-4,-3,4,3])
	elif time < RECOIL_LEN + FALL_LEN + WAIT_LEN + GETUP_LEN:
		var dt = time - (RECOIL_LEN + FALL_LEN + WAIT_LEN)
		var amt = dt/GETUP_LEN
		var footLAmt = clamp(amt/0.3, 0, 1)
		var footLAmt2 = footLAmt*footLAmt
		footLAmt = 0.4*footLAmt + 1.4*footLAmt2 - 0.8*footLAmt2*footLAmt2
		human.footGlobalPos[L] = Vector2(human.pos.x, 0) + (1-footLAmt)*FOOTL_SHIFT
		human.footAngles[L] = FOOTL_ROT*(1-footLAmt) + human.footAngles[L]*footLAmt
		if isFoot2 && footLAmt > 0.3:
			human.get_node("polygons/LegL/FootL").set_visible(true)
			human.get_node("polygons/LegL/FootL2").set_visible(false)
			human.setZOrder([-5,-4,-3,4,3])
		var footRAmt = clamp((amt - 0.4)/0.6, 0, 1)
		var footRAmt2 = footRAmt*footRAmt
		footRAmt = 0.1*footRAmt + 1.9*footRAmt2 - 1.0*footRAmt2*footRAmt2
		human.footGlobalPos[R] = Vector2(human.pos.x, 0) + (1-footRAmt)*FOOTR_SHIFT
		human.footAngles[R] = FOOTR_ROT*(1-footRAmt) + human.footAngles[R]*footRAmt
		var riseAmt = footRAmt
		human.targetHeight = DROP_SHIFT.y*(1-riseAmt)
		human.approachTargetHeight(delta)
		var downAmt = 1 - riseAmt
		var baseLegScaleL = human.skeleton.getLegScale(L, human.skeleton.getHeelPos(L, human.footAngles[L]))
		var baseLegScaleR = human.skeleton.getLegScale(R, human.skeleton.getHeelPos(R, human.footAngles[R]))
		human.legScale[L] = [(1.0+THIGHL_DSCALE)*downAmt + baseLegScaleL[0]*(1-downAmt), (1.0+CALFL_DSCALE)*downAmt + baseLegScaleL[1]*(1-downAmt)]
		human.legScale[R] = [(1.0+THIGHR_DSCALE)*downAmt + baseLegScaleR[0]*(1-downAmt), (1.0+CALFR_DSCALE)*downAmt + baseLegScaleR[1]*(1-downAmt)]
		human.targetRelHandPos[R] = HANDR_STAND_POS
	
	human.opponent.pushAway(delta, human.handGlobalPos[R].x - MRecoil1.PUSH_DIST)
	
	if human.opponent.isCasting() && human.opponent.bolt.targetClass == FCast.TGT_CLASS_HIGH:
		blockingHigh = true
	
	if blockingHigh:
		human.targetRelHandPos[R] = Vector2(-30, -180)
	
	human.approachTargetHandPos((0.8 if blockingHigh else 0.5)*delta)
	human.approachTargetAbAng(0.5*delta)
	human.updateLegsClosed(delta)
	human.breathe(delta, true)


func stop():
	human.closingLegs = false
	human.targetRelHandPos[L] = Vector2.ZERO
	human.targetRelHandPos[R] = Vector2.ZERO
	human.face.setNeutral()
	human.stopGrabPart()


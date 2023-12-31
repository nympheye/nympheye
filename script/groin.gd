extends Node2D
class_name Groin


const L = 0
const R = 1

const KICK = 1
const TWIST = 2
const GRAB = 3
const BOLT = 4

const KICK_DURATION = 0.25
const KNEE_DURATION = 0.20
const TWIST_DURATION = 0.32
const GRAB_DURATION = 0.32
const BOLT_DURATION = 0.18

const KICK_FRONT = 1
const KICK_KNEE = 2
const KICK_BACK = 3


var hip
var pen1
var pen2
var cord1
var cord2
var ball
var ankle
var foot
var calf
var hand
var thumb
var split1
var split2
var cordTwist0
var cordTwist1
var cordTwist2
var ballTwist

var poly
var normalPoly
var exposedPoly
var twistBallPoly
var twistCord1Poly
var twistCord2Poly
var twistCord3Poly
var severedPoly
var splitPoly1
var splitPoly2

var isEnabled
var male
var camera
var pen1AngOffset
var pen2AngOffset
var cord1BasePos
var cord2BasePos
var ballBasePos
var ballBaseAng
var ballPos0
var ballTwistLBasePos
var cord1Len
var cord2Len
var splitBasePos
var expelBasePos
var penPoly
var penPolyCut
var snapSounds : Sounds
var crushSounds : Sounds

var time
var action
var tgtBall
var kickPosX
var kickType
var erectLevel
var twistLevel
var isCrushed
var kickDuration


func _ready():
	male = get_owner().get_node("Male")
	camera = get_owner().get_node("Camera2D")
	snapSounds = Sounds.new(get_owner().get_node("Sounds/Snap"), 0, 1)
	crushSounds = Sounds.new(get_owner().get_node("Sounds/Crush"), 0, 1)
	time = 9999
	action = -1
	kickDuration = 0
	
	var options = get_node("/root/Options")
	isEnabled = options.goreEnabled && options.slowmo
	
	poly = get_node("polygons")
	normalPoly = []
	exposedPoly = []
	twistBallPoly = []
	twistCord1Poly = []
	twistCord2Poly = []
	twistCord3Poly = []
	severedPoly = []
	splitPoly1 = []
	splitPoly2 = []
	for i in [L,R]:
		var label = "L" if i == L else "R"
		normalPoly.append(poly.get_node("Ball" + label))
		exposedPoly.append(poly.get_node("Ball" + label + "_e"))
		twistBallPoly.append(poly.get_node("Ball" + label + "_twist"))
		twistCord1Poly.append(poly.get_node("Cord" + label + "_twist1"))
		twistCord2Poly.append(poly.get_node("Cord" + label + "_twist2"))
		twistCord3Poly.append(poly.get_node("Cord" + label + "_twist3"))
		severedPoly.append(poly.get_node("Ball" + label + "_s"))
		splitPoly1.append(poly.get_node("Ball" + label + "_s1"))
		splitPoly2.append(poly.get_node("Ball" + label + "_s2"))
	
	hip = get_node("Skeleton2D/Hip")
	pen1 = hip.get_node("Penis1")
	pen2 = pen1.get_node("Penis2")
	cord1 = [hip.get_node("CordL1"), hip.get_node("CordR1")]
	cord2 = [cord1[L].get_node("CordL2"), cord1[R].get_node("CordR2")]
	ball = [cord2[L].get_node("BallL"), cord2[R].get_node("BallR")]
	ankle = hip.get_node("Ankle")
	foot = ankle.get_node("Foot")
	calf = ankle.get_node("Calf")
	hand = hip.get_node("Hand")
	thumb = hand.get_node("Thumb")
	split1 = [ball[L].get_node("Split1L"), ball[R].get_node("Split1R")]
	split2 = [split1[L].get_node("Split2L"), split1[R].get_node("Split2R")]
	cordTwist0 = [hip.get_node("CordTwist0L"), hip.get_node("CordTwist0R")]
	cordTwist1 = [cordTwist0[L].get_node("CordTwist1L"), cordTwist0[R].get_node("CordTwist1R")]
	cordTwist2 = [cordTwist1[L].get_node("CordTwist2L"), cordTwist1[R].get_node("CordTwist2R")]
	ballTwist = [cordTwist2[L].get_node("BallTwistL"), cordTwist2[R].get_node("BallTwistR")]
	
	cord1BasePos = [cord1[L].position, cord1[R].position]
	cord2BasePos = [cord2[L].position, cord2[R].position]
	ballBasePos = [ball[L].position, ball[R].position]
	ballBaseAng = [0, 0]
	ballPos0 = [0, 0]
	cord1Len = [0, 0]
	cord2Len = [0, 0]
	for i in [L,R]:
		ballPos0[i] = ball[i].get_global_position() - cord1[i].get_global_position()
		cord1Len[i] = cord2[i].position.length()
		cord2Len[i] = ball[i].position.length()
		ballBaseAng[i] = ball[i].get_rotation() + cord1[i].get_rotation() + cord2[i].get_rotation()
	pen1AngOffset = pen1.get_rotation()
	pen2AngOffset = pen2.get_rotation()
	expelBasePos = [split2[L].position, split2[R].position]
	splitBasePos = [split1[L].position, split1[R].position]
	ballTwistLBasePos = ball
	
	penPoly = [poly.get_node("Penis"), poly.get_node("Penis2"), poly.get_node("Penis3")]
	penPolyCut = poly.get_node("Penis_cut")
	erectLevel = 0
	twistLevel = 0


func _process(delta):
	time += delta
	if action == KICK:
		if time < kickDuration:
			setKick(time/kickDuration, tgtBall)
		else:
			end()
	elif action == TWIST:
		if time < TWIST_DURATION:
			setTwist(time/TWIST_DURATION, tgtBall)
		else:
			setTwist(0.7, tgtBall)
			end()
	elif action == GRAB:
		if time < GRAB_DURATION:
			setGrab(time/GRAB_DURATION, tgtBall)
		else:
			end()
	elif action == BOLT:
		if time < BOLT_DURATION:
			setBolt(time/BOLT_DURATION, tgtBall)
		else:
			end()
	position = camera.position + Vector2(560, 0) 


func startAction(type, ball):
	action = type
	time = 0
	tgtBall = ball
	poly.set_visible(isEnabled)
	setPoly(L)
	setPoly(R)
	resetFPoly()
	setErectLevel(male.erect)


func grab(hitBall):
	startAction(GRAB, hitBall)
	isCrushed = false
	poly.get_node("Hand_grab").set_visible(true)
	poly.get_node("Hand_grab").z_index = normalPoly[hitBall].z_index - 1
	male.game.setSlowmo(0.12)


func kick(hitBall, toePosX, type):
	startAction(KICK, hitBall)
	kickPosX = toePosX
	kickType = type
	isCrushed = false
	if type == KICK_FRONT:
		poly.get_node("Foot").set_visible(true)
		kickDuration = KICK_DURATION
	elif type == KICK_KNEE:
		poly.get_node("Knee").set_visible(true)
		kickDuration = KNEE_DURATION
	elif type == KICK_BACK:
		poly.get_node("LegL").set_visible(false)
		poly.get_node("Foot_back").set_visible(true)
		kickDuration = KICK_DURATION
	male.game.setSlowmo(0.07)
	male.face.setShock(-0.4)


func bolt(hitBall):
	startAction(BOLT, hitBall)
	isCrushed = false
	male.game.setSlowmo(0.12)


func twist(hitBall):
	startAction(TWIST, hitBall)
	twistLevel = 0
	setBallPos([Vector2(0,0), Vector2(0,0)], [0, 0], [Vector2(1.0, 1.0), Vector2(1.0, 1.0)])
	setKickTwistRot(0.0)
	poly.get_node("Hand_twist").set_visible(true)
	twistBallPoly[hitBall].set_visible(true)
	twistCord1Poly[hitBall].set_visible(true)
	twistCord2Poly[hitBall].set_visible(false)
	twistCord3Poly[hitBall].set_visible(false)
	if hitBall == L:
		normalPoly[L].set_visible(false)
	else:
		poly.get_node("BallR").set_visible(false)
	male.game.setSlowmo(0.09)


const BOLT_SCALE_START = 0.1
const BOLT_SCALE_END = 0.97
const BOLT_CRUSH_START = 0.50
const BOLT_CRUSH_DURATION = 0.20
func setBolt(amt, side):
	var otherSide = ~side & 1
	
	var splitAmt = clamp((amt - BOLT_CRUSH_START)/BOLT_CRUSH_DURATION, 0, 1)
	setSplitAmt(2.0*splitAmt - 1.0*splitAmt*splitAmt, side)
	
	var ballScale = [1.0, 1.0]
	ballScale[otherSide] = Vector2(1.0, 1.0) if !male.ball[otherSide].isCrushed else Vector2(1.06, 0.8)
	
	var scaleAmt = clamp((amt - BOLT_SCALE_START)/(BOLT_CRUSH_START + BOLT_CRUSH_DURATION - BOLT_SCALE_START), 0, 1)
	var scaleAmt2 = scaleAmt*scaleAmt
	var scaleAmt4 = scaleAmt2*scaleAmt2
	
	var growRad = 0.4*scaleAmt + 0.4*scaleAmt2 + 0.2*scaleAmt4
	growRad = 0.66*(2*growRad - 1)*PI
	var growScale = -0.56*(sin(growRad)*(0.30 if growRad < 0 else 1.0)/exp(1.0*growRad*growRad))
	ballScale[side] = Vector2(1.0 + growScale, 1.0 + growScale)
	
	var moveAmt = 0.4*growScale + 0.4*splitAmt + 0.2*(2.0*scaleAmt2 - 1.0*scaleAmt4)
	
	var ballPos = [Vector2.ZERO, Vector2.ZERO]
	ballPos[otherSide] = amt*Vector2(-12, -5)
	ballPos[side] = Vector2(-20, -5) + amt*Vector2(10, 0) + moveAmt*Vector2(50, 20)
	if !male.ball[side].isExposed:
		ballPos[side] += Vector2(-45, 85) if side == L else Vector2(-2, 58)
	else:
		ballPos[side] += Vector2(-60, 45) if side == L else Vector2(-15, 20)
	
	var ballAngs = [0, 0]
	ballAngs[side] = -0.15 if side == L else -0.0
	ballAngs[side] += 0.15 - 0.6*moveAmt
	
	setBallPos(ballPos, ballAngs, ballScale)
	
	var penAng0 = getPenAng0()
	pen1.set_rotation(penAng0[0] + 0.1*(1-amt))
	pen2.set_rotation(penAng0[1] + 0.05*(1-amt))
	
	if splitAmt > 0.0 && !isCrushed:
		isCrushed = true
		crushSounds.playRandom()
	


const GRAB_HAND_POS = Vector2(-50, 0)
const THUMB1_AMT = 0.7
const THUMB_START_ROT = -0.25
const THUMB1_ROT = 0.29
const THUMB2_ROT = 0.28
func setGrab(amt, side):
	var otherSide = ~side & 1
	
	hand.position = Vector2(-0, 10) if side == L else Vector2(-10, 40)
	hand.position += amt*Vector2(-10, 10)
	if male.ball[side].isExposed:
		hand.position += Vector2(-20, 50) if otherSide == L else Vector2(-10, 50)
	
	var squishAmt = clamp((amt-0.10)/0.90, 0, 1)
	squishAmt = squishAmt*squishAmt*exp(-1.0*squishAmt*squishAmt)/0.38
	var ballScale = [1.0, 1.0]
	ballScale[otherSide] =  Vector2(1.0, 1.0) if !male.ball[otherSide].isCrushed else Vector2(1.06, 0.8)
	ballScale[side] = Vector2(1.0 + 0.13*squishAmt, 1.0 - 0.25*squishAmt)
	
	var ballPos = [Vector2.ZERO, Vector2.ZERO]
	if !male.ball[side].isExposed:
		ballPos[otherSide] = Vector2(0, -5) if otherSide == L else Vector2(10, -20)
	ballPos[otherSide] += amt*Vector2(7, -7)
	ballPos[side] = hand.position
	if !male.ball[side].isExposed:
		ballPos[side] += Vector2(-45, 85) if side == L else Vector2(-2, 58)
	else:
		ballPos[side] += Vector2(-60, 45) if side == L else Vector2(-15, 20)
	ballPos[side] += squishAmt*Vector2(-20, 80)
	
	var ballAngs = [0, 0]
	ballAngs[side] = -0.15 if side == L else -0.0
	ballAngs[side] -= squishAmt*0.1
	
	setBallPos(ballPos, ballAngs, ballScale)
	
	var penAng0 = getPenAng0()
	pen1.set_rotation(penAng0[0] + 0.1*(1-amt))
	pen2.set_rotation(penAng0[1] + 0.05*(1-amt))
	
	if amt < THUMB1_AMT:
		var thumbAmt = amt/THUMB1_AMT
		var thumbAmt2 = thumbAmt*thumbAmt
		var thumbAmt4 = thumbAmt2*thumbAmt2
		thumbAmt = 0.1*thumbAmt + 1.6*thumbAmt2 - 0.7*thumbAmt4
		thumb.set_rotation(THUMB_START_ROT + THUMB1_ROT*thumbAmt)
	else:
		if !isCrushed:
			isCrushed = true
			crushSounds.playRandom()
		var thumbAmt = (amt - THUMB1_AMT)/(1 - THUMB1_AMT)
		setSplitAmt(thumbAmt, side)
		var thumbAmt2 = thumbAmt*thumbAmt
		var thumbAmt4 = thumbAmt2*thumbAmt2
		thumbAmt = 0.1*thumbAmt + 2.0*thumbAmt2 - 1.1*thumbAmt4
		thumb.set_rotation(THUMB_START_ROT + THUMB1_ROT + THUMB2_ROT*thumbAmt)


const STRETCH_RATIO = 0.7
const HAND_START_POS = Vector2(-50, 0)
const HAND_SHIFT = Vector2(80, -20)
const BREAK_AMT = 0.5
func setTwist(amt, side):
	var amt2 = amt*amt
	var amt4 = amt2*amt2
	var pull1Amt = clamp(amt/BREAK_AMT, 0, 1)
	var pull2Amt = clamp((amt-BREAK_AMT)/0.40, 0, 1)
	var handMove1 = 1 - (1-pull1Amt)/exp(1.5*pull1Amt*pull1Amt)
	var handMove2 = 1 - (1-pull2Amt)/exp(3.0*pull2Amt*pull2Amt)
	var handMove = 1.25*handMove1 + 0.8*handMove2
	var handShift = HAND_START_POS + handMove*HAND_SHIFT
	hand.position = handShift.rotated(cordTwist0[side].get_rotation()) + \
			(Vector2.ZERO if side == L else Vector2(0, 12))
	
	if twistLevel == 0:
		var cord1Move = STRETCH_RATIO*handShift
		cordTwist1[side].position = cord1Move
		ballTwist[side].position = handShift - cord1Move
	else:
		var cord1Amt = clamp((amt-BREAK_AMT)/0.30, 0, 1)
		cord1Amt = (1-cord1Amt)/exp(8.0*cord1Amt*cord1Amt)
		var cord1Move = STRETCH_RATIO*(HAND_START_POS + (0.3 + 0.7*cord1Amt)*HAND_SHIFT)
		var cord2Amt = sqrt(1 - cord1Amt)
		var cord2Move = cord2Amt*(handShift - cord1Move)
		cordTwist1[side].position = cord1Move
		cordTwist2[side].position = cord2Move
		ballTwist[side].position = handShift - cord1Move - cord2Move
	
	var cordScale
	if twistLevel < 1:
		cordScale = 1.0 - 0.3*handMove1
	else:
		cordScale = 0.7 + 0.3*clamp((amt-BREAK_AMT)/0.2, 0, 1)
	cordTwist1[side].scale = Vector2(1.0, cordScale)
	ballTwist[side].scale = Vector2(1.0, 1/cordScale)
	
	var penAng0 = getPenAng0()
	pen1.set_rotation(penAng0[0] + 0.3*(1-amt))
	pen2.set_rotation(penAng0[1] + 0.1*(1-amt))
	
	if twistLevel == 0 && amt > BREAK_AMT:
		twistLevel = 1
		snapSounds.playRandom()
		twistCord1Poly[side].set_visible(false)
		twistCord2Poly[side].set_visible(true)
	elif twistLevel == 1 && amt > 0.60:
		twistLevel = 2
		twistCord2Poly[side].set_visible(false)
		twistCord3Poly[side].set_visible(true)


func setKick(amt, side):
	var otherSide = ~side & 1
	var amt2 = amt*amt
	var amt4 = amt2*amt2
	
	var footMove
	if side == L || side == R:
		if kickType == KICK_BACK:
			footMove = 1 - (1-amt)/exp(10.0*amt2) - 0.015*amt4*amt4
		else:
			footMove = 1 - (1-amt)/exp(13.0*amt2) - 0.015*amt4*amt4
	else:
		footMove = 1 - (1-amt)/exp(7.0*amt2) - 0.1*amt4*amt4
	var footEndPos
	if side == L:
		footEndPos = Vector2(-280, 160) if kickType == KICK_BACK else Vector2(-290, 160)
	elif side == R:
		footEndPos = Vector2(-320, 160) if kickType == KICK_BACK else Vector2(-290, 135)
	else:
		footEndPos = Vector2(-290, 135)
	ankle.position = Vector2(1.2*kickPosX, 0) + (1-footMove)*Vector2(-330, 370) + footMove*footEndPos
	var footRot = -0.8*amt + 3.4*amt2 - 1.6*amt2*amt2
	foot.set_rotation(0.2*footRot)
	var calfAng = -0.1 + 0.2*amt
	calf.set_rotation(calfAng)
	
	var time = [0.25 + 0.13*getRetraction(L), 0.19 + 0.17*getRetraction(R)]
	if kickType == KICK_BACK:
		time = [time[0] + 0.10, time[1] + 0.10]
	var samt = [0, 0]
	var samtX = [0, 0]
	var samtY = [0, 0]
	var scale = [0, 0]
	for i in [L,R]:
		samt[i] = clamp((amt-time[i])/(1-time[i]), 0, 1)
		var samt2 = samt[i]*samt[i]
		var samt4 = samt2*samt2
		
		samtX[i] = samt[i]
		if i == side:
			samtY[i] = 1 - (1-samt[i])/exp(25.0*samt2) - 0.2*samt4*samt4
		else:
			samtY[i] = 1.3*samt[i] + 1.4*samt2 - 1.9*samt2*samt[i]
		
		var squishAmt = clamp((samt[i]-0.10)/0.90, 0, 1)
		if side != L && side != R:
			squishAmt = squishAmt*squishAmt*exp(-2*squishAmt*squishAmt)/0.12
			scale[i] = Vector2(1.0 + 0.1*squishAmt, 1.0 - 0.08*squishAmt)
		else:
			if i == side:
				squishAmt = squishAmt*squishAmt*exp(-1.0*squishAmt*squishAmt)/0.38
				scale[i] = Vector2(1.0 + 0.13*squishAmt, 1.0 - 0.25*squishAmt)
			else:
				scale[i] = Vector2(1.0, 1.0) if !male.ball[i].isCrushed else Vector2(1.06, 0.8)
	
	var retractShift = getBallRetract()
	var ballPos = [Vector2(20, -43), Vector2(-15, -60)]
	if side == L:
		ballPos[L] = Vector2(10, -30)
	elif side == R:
		ballPos[R] = Vector2(-10, -55)
	for i in [L,R]:
		if male.ball[i].isExposed:
			ballPos[i] += Vector2(0, -15)
		ballPos[i] -= retractShift[i]
		ballPos[i] = Vector2(ballPos[i].x*samtX[i], ballPos[i].y*samtY[i])
	
	setBallPos(ballPos, [-0.3*samt[L]*(1-getRetraction(L)), -0.1*samt[R]*(1-getRetraction(R))], scale)
	setKickPenRot(amt)
	setKickTwistRot(amt)
	
	if side == L || side == R:
		var splitAmt = clamp((amt-0.50)/0.23, 0, 1)
		setSplitAmt(splitAmt, side)
		if splitAmt > 0 && !isCrushed:
			isCrushed = true
			crushSounds.playRandom()


func setSplitAmt(splitAmt, side):
	if splitAmt > 0:
		splitPoly1[side].set_visible(true)
		splitPoly2[side].set_visible(true)
		splitAmt = 2*splitAmt - splitAmt*splitAmt
		split1[side].set_scale(Vector2(splitAmt, sqrt(splitAmt)))
		if male.ball[side].isExposed:
			split1[side].position = splitBasePos[side] + (Vector2(20, 25) if side == L else Vector2(18, 23))
		var expelAmt = clamp((splitAmt-(0.2 if side == L else 0.1))/0.8, 0, 1)
		expelAmt = 2*expelAmt - expelAmt*expelAmt
		split2[side].set_scale(Vector2(0.1 + 0.7*expelAmt, 0.6 + 0.3*expelAmt))
		split2[side].position = expelBasePos[side] + expelAmt*(Vector2(-8, 0) if side == L else Vector2(6, -4))


func setKickPenRot(amt):
	var penAng0 = getPenAng0()
	var startTime = 0.2 + 0.3*male.erect
	var penAmt = clamp((amt-startTime)/0.8, 0, 1)
	var pen1Amt = 2.6*penAmt - 1.15*penAmt*penAmt
	pen1Amt = pen1Amt/(1 + 2.0*male.erect)
	var pen2Amt = -1.2*penAmt + 1.8*penAmt*penAmt
	pen2Amt = pen2Amt/(1 + 50.0*male.erect*male.erect)
	pen1.set_rotation(penAng0[0] + pen1Amt)
	pen2.set_rotation(penAng0[1] + pen2Amt)


func setKickTwistRot(amt):
	amt = (amt - 0.1)/0.9
	var amt2 = amt*amt
	amt = 1 - (1-amt)/exp(3.0*amt2)
	for i in [L,R]:
		cordTwist2[i].set_rotation(-0.4*amt)


func getPenAng0():
	var pen1Ang = -0.36 + 1.10*male.erect
	if erectLevel == 2:
		pen1Ang -= 0.65
	var pen2Ang = -0.23 + 0.2*male.erect
	return [pen1AngOffset + pen1Ang, pen2AngOffset + pen2Ang]


func getBallRetract():
	return [getRetraction(L)*Vector2(0, -36), getRetraction(R)*Vector2(0, -51)]


func getRetraction(side):
	if action == GRAB && tgtBall == side:
		return 0.0
	var ball = male.ball[side]
	if ball.isExposed:
		if ball.isSevered:
			return 0.2
		else:
			return -0.25
	else:
		if ball.isSevered:
			return -0.15
		else:
			if action == GRAB && tgtBall != side:
				return 0.5*male.retract
			else:
				return male.retract


func setBallPos(offset, ballAngs, ballScale):
	var ballRetract = getBallRetract()
	
	for i in [L,R]:
		var ballRetractAng = [-0.2*getRetraction(i), 0]
		var cordScale = 1 + 0.003*offset[i].y - 0.45*getRetraction(i)
		
		var angs = HumanSkeleton.compute_angles(ballPos0[i] + ballRetract[i] + offset[i], \
				cordScale*cord1Len[i], cordScale*cord2Len[i], true)
		var cord1Ang = angs[0]
		var cord2Ang = angs[1] - cord1Ang
		var ballAng = ballRetractAng[i] + ballBaseAng[i] + ballAngs[i] - (cord1Ang + cord2Ang)
		
		cord1[i].set_rotation(cord1Ang)
		cord1[i].set_scale(Vector2(cordScale, 1.0))
		
		var cord2Trans = Math.scaledTrans(-cord2Ang, 1/cordScale)
		cord2Trans = cord2Trans.scaled(Vector2(cordScale, 1.0)).rotated(cord2Ang)
		cord2Trans.origin = cord2[i].transform.origin
		cord2[i].transform = cord2Trans
		
		var ballTrans = Math.scaledTrans(-ballAng, 1/cordScale)
		ballTrans = ballTrans.scaled(ballScale[i]).rotated(ballAng)
		ballTrans.origin = ball[i].transform.origin
		ball[i].transform = ballTrans


func setPoly(index):
	normalPoly[index].set_visible(false)
	exposedPoly[index].set_visible(false)
	twistBallPoly[index].set_visible(false)
	twistCord1Poly[index].set_visible(false)
	twistCord2Poly[index].set_visible(false)
	twistCord3Poly[index].set_visible(false)
	severedPoly[index].set_visible(false)
	
	var ball = male.ball[index]
	if ball.isSevered && !ball.isExposed:
		twistBallPoly[index].set_visible(true)
		twistCord3Poly[index].set_visible(true)
	elif ball.isSevered && ball.isExposed:
		severedPoly[index].set_visible(true)
	elif ball.isExposed && !ball.isSevered:
		exposedPoly[index].set_visible(true)
	else:
		normalPoly[index].set_visible(true)
	
	var crushed = !(ball.isSevered && ball.isExposed) && ball.isCrushed
	splitPoly1[index].set_visible(crushed)
	splitPoly2[index].set_visible(crushed)


func resetFPoly():
	poly.get_node("Foot").set_visible(false)
	poly.get_node("Foot_back").set_visible(false)
	poly.get_node("Knee").set_visible(false)
	poly.get_node("Hand_twist").set_visible(false)
	poly.get_node("Hand_grab").set_visible(false)
	poly.get_node("LegL").set_visible(true)


func setErectLevel(erect):
	if erect < 0.45:
		erectLevel = 0
	elif erect < 0.75:
		erectLevel = 1
	else:
		erectLevel = 2
	if erectLevel < 2:
		pen1.set_scale(Pen1.PEN_SCALE*Vector2(1.0 + 1.62*erect, 1.0 + 0.10*erect))
	else:
		pen1.set_scale(Vector2(1.0, 1.0))
	pen2.set_scale(Pen2.getScale(erect))
	
	for p in penPoly:
		p.set_visible(false)
	if male.pen1.isCutHead:
		penPolyCut.set_visible(true)
	else:
		penPoly[erectLevel].set_visible(true)


func end():
	action = -1
	poly.set_visible(false)
	male.game.setSlowmo(1.0)


func isActive():
	return action > -1


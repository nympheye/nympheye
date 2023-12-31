extends Action
class_name MWin2

func get_class():
	return "MWin2"


const PULLOUT_TIME = 1.8
const PEN_EXIT_TIME = 0.3*PULLOUT_TIME
const LEGR1_START_TIME = 1.3
const LEGR1_TIME = 1.2
const LEGR2_TIME = 1.3
const LEGL1_TIME = 1.0
const LEGL2_TIME = 1.3
const GRABR_TIME = 1.1
const YANK_TIME = 2.4
const REACHL_TIME = 1.4
const LEGR_LIFT1_TIME = 1.5
const PULL1_TIME = 1.3
const PULL2_TIME = 1.0
const AIM_TIME = 1.1
const ENTER_TIME = 2.0
const NTHRUSTS = 10
const PULLOUT_POS = Vector2(172, 3)
const PEN_EXIT_ROT = 0.3
const HIP_HOLD_POS = Vector2(-40, 25)
const LEGR1_POS = Vector2(350, 190) - Vector2(9, -8)
const LEGR1_THIGHR_SCALE = 1.4
const LEGR2_POS = Vector2(300, 150) - Vector2(9, -8)
const LEGR2_KNEE_POS = Vector2(130, 120) - Vector2(9, -8)
const LEGR2_FSHIFT = Vector2(-12, 0)
const LEGL1_POS = Vector2(340, 260) - Vector2(9, -8)
const LEGL1_FLEGR_SPREAD = 1.1
const LEGL2_POS = Vector2(280, 310) - Vector2(9, -8)
const LEGL2_KNEE_POS = Vector2(104, 238)
const LEGL2_FSHIFT = Vector2(-4, 0)
const GRABR_POS = Vector2(-165, 180)
const GRABR_HANDANG = 75*PI/180
const YANK_POS = Vector2(-20, 10)
const YANK_FHANDR_POS = Vector2(-200, 230)
const YANK_FHANDL_SHIFT = Vector2(0, 10)
const REACHL_POS = Vector2(60, 180)
const REACHL_HIPSHIFT = Vector2(60, 50)
const REACHL_ABANG = 0.0
const REACHL_FORESCALE = 1.3
const REACHL_UPPERSCALE = 1.0
const REACHL_PENSHIFT = Vector2(-12, -30)
const LEGR_LIFT1_HIPSHIFT = Vector2(-10, 20)
const LEGR_LIFT1_GRABPOS = Vector2(-200, 197)
const LEGR_LIFT1_ABANG = -0.2
const LEGR_LIFT1_FORESCALE = 1.3
const LEGR_LIFT1_UPPERSCALE = 1.05
const LEGR_LIFT1_FSHIFT = Vector2(-20, 0)
const LEGR_LIFT1_KNEEL_POS = LEGL2_KNEE_POS + Vector2(-2, 20)
const LEGR_LIFT1_KNEER_POS = LEGR2_KNEE_POS + Vector2(23, -10)
const HANDL_GRAB_ANG = 105*PI/180
const PULL1_SHIFT = Vector2(70, 10)
const PULL1_GRABPOS = Vector2(-119, 171)
const PULL1_ABANG = -0.1
const PULL1_KNEEL_POS = LEGR_LIFT1_KNEEL_POS + Vector2(-17, 20)
const PULL1_KNEER_POS = LEGR_LIFT1_KNEER_POS + Vector2(11, -10)
const PULL2_SHIFT = Vector2(20, -15)
const PULL2_HAND_SHIFT = Vector2(25, -45)
const PULL2_ABANG = -0.1
const PULL2_HIPANG = -55*PI/180
const PULL2_THIGHR_SCALE = 0.9
const PULL2_FHIP_ROT = -0.22
const PULL2_LEGRLIFT = 0.82
const ENTER_KNEEL_POS = PULL1_KNEEL_POS
const ENTER_KNEER_POS = PULL1_KNEER_POS + Vector2(-22, 0)
const FINAL_PENSHIFT = Vector2(-15, -25)
const AIM_POS = Vector2(242, 95) - Vector2(9, -8)
const AIM_HIPANG = -65*PI/180
const AIM_HAND_SHIFT = Vector2(-16, 50)
const ENTER_POS = Vector2(215, 83) - Vector2(9, -8)
const ENTER_PENANG = 0.06
const ENTER_VOPEN = 0.55
const THRUST_SUND_INDICES = [4, 5, 7, 10, 11]


var male
var opponent
var winSkeleton : MaleWinSkeleton
var flose : FLose1
var sounds
var startPos
var opponentStartPos
var legRInside
var legLInside
var armLInside
var thighStartScale
var penStartRot
var handStartPos
var femaleHandStartPos
var femaleForearmLStartAng
var femaleArmLStartAng
var abStartAng
var handRHoldAng
var kneePos
var bumpTrigger
var soundTrigger
var thrustCycle
var thrustCount
var thrustSoundIndex


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent


func start():
	winSkeleton = male.get_node("Skeleton2D_win")
	startPos = male.pos
	flose = opponent.action
	opponentStartPos = flose.basePos
	legRInside = false
	legLInside = false
	armLInside = false
	bumpTrigger = false
	soundTrigger = false
	thrustCycle = 0
	thrustCount = 0
	thighStartScale = winSkeleton.thighScale
	penStartRot = winSkeleton.penis.get_rotation()
	handStartPos = [winSkeleton.handPos[L], winSkeleton.handPos[R]]
	femaleHandStartPos = opponent.trueGlobalHandPos()
	femaleForearmLStartAng = opponent.skeleton.forearmLay1[L].get_rotation()
	femaleArmLStartAng = opponent.skeleton.armLay1[L].get_rotation()
	kneePos = [0, 0]
	thrustSoundIndex = randi()
	
	sounds = [
		[LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + 0.2, "hit", 12, -4],
		[LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + 1.5, "hit", 2, -4],
		[LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + 0.3, "cry", 6, 0],
		[LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + 0.3, "cry", 1, 0],
		[LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME + AIM_TIME + 0.4, "cry", 5, 0]
	]


func canStop():
	return false

func isDone():
	return false


func perform(time, delta):
	
	for event in sounds:
		if event[1] != null && time > event[0]:
			if event[1] == "cry":
				flose.human.crySounds.playDb(event[2], event[3])
			elif event[1] == "hit":
				flose.human.hitSounds.playDb(event[2], event[3])
			event[1] = null
	
	if time < PULLOUT_TIME:
		var dt = time
		var amt = dt/PULLOUT_TIME
		var amt2 = amt*amt
		var amtX = 0.4*amt + 1.5*amt2 - 0.9*amt2*amt2
		var amtY = -0.1*amt + 2.0*amt2 - 0.9*amt2*amt2*amt2
		male.pos = Vector2((1-amtX)*startPos.x + amtX*(PULLOUT_POS.x + opponentStartPos.x), \
						(1-amtY)*startPos.y + amtY*(PULLOUT_POS.y + opponentStartPos.y))
		flose.setVagOpen(0.25*(1 - 2.0*amt))
		
		var prePenRotAmt = clamp(dt/PEN_EXIT_TIME, 0, 1)
		var penRotAmt = clamp((dt - PEN_EXIT_TIME)/(0.3), 0, 1)
		var penRotAmt2 = penRotAmt*penRotAmt
		var penRotAmt4 = penRotAmt2*penRotAmt2
		penRotAmt = 5.0*penRotAmt2 - 5.5*penRotAmt4 + 1.5*penRotAmt4*penRotAmt4
		winSkeleton.penis.set_rotation(penStartRot - 0.10*prePenRotAmt*(1-penRotAmt) + PEN_EXIT_ROT*penRotAmt)
		var handAmtX = amtX
		var handAmtY = -0.5*amt + 1.5*amt2
		winSkeleton.placeHandR(Vector2((1-handAmtX)*handStartPos[R].x + handAmtX*(opponent.pos.x + HIP_HOLD_POS.x), \
										(1-handAmtY)*handStartPos[R].y + handAmtY*(opponent.pos.y + HIP_HOLD_POS.y)), \
										Vector2.ZERO, 0.0)
		winSkeleton.placeHandL(handStartPos[L], 1.0)
	if time < LEGR1_START_TIME:
		winSkeleton.placeLegs([opponent.pos + MPushBack.FOOTL_POS, opponent.pos + MPushBack.FOOTR_POS], \
							[1.0, thighStartScale[R]], \
							[1.0, 1.0])
	elif time < LEGR1_START_TIME + LEGR1_TIME:
		var dt = time - LEGR1_START_TIME
		var amt = dt/LEGR1_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var amtX = 0.4*amt + 10.5*amt2 - 14.0*amt4 + 4.1*amt4*amt4
		var amtY = 0.4*amt + 1.5*amt2 - 0.9*amt2*amt2
		var thighScaleAmt = amtY
		var thighRScale = thighStartScale[R]*(1-thighScaleAmt) + LEGR1_THIGHR_SCALE*thighScaleAmt
		winSkeleton.placeLegs([opponentStartPos + MPushBack.FOOTL_POS, opponentStartPos + \
					Vector2((1-amtX)*MPushBack.FOOTR_POS.x + amtX*LEGR1_POS.x, \
							(1-amtY)*MPushBack.FOOTR_POS.y + amtY*LEGR1_POS.y)], [1.0, thighRScale], \
							[1.0, 1.0])
		if !legRInside && amt > 0.65:
			legRInside = true
			opponent.get_node("polygons/Lay1/CalfL").z_index = -101
		winSkeleton.placeHandL(handStartPos[L], 1.0)
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME)
		var amt = dt/LEGR2_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		kneePos = [LEGL2_KNEE_POS, LEGR2_KNEE_POS]
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + MPushBack.FOOTL_POS, \
					opponentStartPos + (1-amt)*LEGR1_POS + amt*LEGR2_POS], \
					[1.0, (1-amt)*LEGR1_THIGHR_SCALE + amt*thighScale[R]], \
					[1.0, (1-amt)*1 + amt*calfScale[R]])
		var spreadAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		flose.setLegsOpen((1-spreadAmt)*MWin1.END_LEG_SPREAD + spreadAmt*19, MWin1.END_LEG_SPREAD)
		if amt > 0.5:
			flose.spreadL()
		winSkeleton.placeHandR(opponent.pos + HIP_HOLD_POS, Vector2.ZERO, 0.0)
		winSkeleton.placeHandL(handStartPos[L], 1.0)
		flose.setLegLSOpen(spreadAmt*getLegLSOpen())
		flose.basePos = opponentStartPos + spreadAmt*LEGR2_FSHIFT
		opponent.skeleton.placeLayArms(femaleHandStartPos)
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME)
		var amt = dt/LEGL1_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var amtX = 0.4*amt + 10.5*amt2 - 14.0*amt4 + 4.1*amt4*amt4
		var amtY = 0.4*amt + 1.5*amt2 - 0.9*amt2*amt2
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + \
						Vector2((1-amtX)*MPushBack.FOOTL_POS.x + amtX*LEGL1_POS.x, \
								(1-amtY)*MPushBack.FOOTL_POS.y + amtY*LEGL1_POS.y), \
							opponentStartPos + LEGR2_POS], 
							[1.0, thighScale[R]], \
							[1.0, calfScale[R]])
		if !legLInside && amt > 0.5:
			legLInside = true
			opponent.get_node("polygons/Lay1/LegR").z_index = 9
			opponent.get_node("polygons/Lay1/LegR2").z_index = 18
			opponent.get_node("polygons/Lay1/CalfR").z_index = 20
		winSkeleton.placeHandR(opponent.pos + HIP_HOLD_POS, Vector2.ZERO, 0.0)
		winSkeleton.placeHandL(handStartPos[L], 1.0)
		var spreadAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		flose.setLegsOpen(1.0, (1-spreadAmt)*MWin1.END_LEG_SPREAD + spreadAmt*LEGL1_FLEGR_SPREAD)
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME)
		var amt = dt/LEGL2_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + (1-amt)*LEGL1_POS + amt*LEGL2_POS, \
					opponentStartPos + LEGR2_POS], \
					[(1-amt)*1.0 + amt*thighScale[L], thighScale[R]], \
					[(1-amt)*1.0 + amt*calfScale[L], calfScale[R]])
		var spreadAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		flose.setLegsOpen(1.0, (1-spreadAmt)*LEGL1_FLEGR_SPREAD + spreadAmt*FLose1.LEGR_SPREAD)
		winSkeleton.placeHandR(opponent.pos + HIP_HOLD_POS, Vector2.ZERO, 0.0)
		winSkeleton.placeHandL(handStartPos[L], 1.0)
		var fshiftAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		flose.basePos = opponentStartPos + LEGR2_FSHIFT + fshiftAmt*LEGL2_FSHIFT
		opponent.skeleton.placeLayArms(femaleHandStartPos)
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME)
		var amt = dt/GRABR_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var amtX = 0.4*amt + 1.5*amt2 - 0.9*amt2*amt2
		var amtY = amt
		var handRotAmt = amt2
		winSkeleton.placeHandR(Vector2(opponent.pos.x + (1-amtX)*HIP_HOLD_POS.x + amtX*GRABR_POS.x, \
										opponent.pos.y + (1-amtY)*HIP_HOLD_POS.y + amtY*GRABR_POS.y), \
										Vector2.ZERO, handRotAmt*GRABR_HANDANG)
		winSkeleton.placeHandL(handStartPos[L], 1.0)
		if amt > 0.90:
			male.get_node("polygons_win/HandR_open").set_visible(false)
			male.get_node("polygons_win/HandR_grabL").set_visible(true)
			male.get_node("polygons_win/HandR_grabLt").set_visible(true)
			opponent.get_node("polygons/Lay1/HandL").set_visible(false)
			opponent.get_node("polygons/Lay1/HandL_grab").set_visible(true)
		elif amt > 0.3:
			male.get_node("polygons_win/HandR").set_visible(false)
			male.get_node("polygons_win/HandR_open").set_visible(true)
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME)
		var amt = dt/YANK_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var handLMove = clamp(dt/0.4, 0, 1)
		var handLMove2 = handLMove*handLMove
		handLMove = 0.5*handLMove + 0.5*handLMove2 - 1.0*handLMove2*handLMove2
		winSkeleton.placeHandL(handStartPos[L] + handLMove*Vector2(20, -30), 1.0)
		var handAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		var handBackAmt = exp(-4*amt)*(0.2*amt + 4.6*amt2 - 7.3*amt4 + 2.5*amt4*amt4)/0.13
		var handRPos = Vector2(opponent.pos.x + (1-handAmt)*GRABR_POS.x + handAmt*YANK_POS.x, \
								opponent.pos.y + (1-handAmt)*GRABR_POS.y + handAmt*YANK_POS.y) \
							+ handBackAmt*Vector2(80, 10)
		var fhandRAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		var fhandLShiftAmt = clamp(8*amt, 0, 1)
		var fhandLPos = (1-fhandLShiftAmt)*femaleHandStartPos[L] + fhandLShiftAmt*(handRPos + YANK_FHANDL_SHIFT)
		opponent.skeleton.placeLayArms([fhandLPos, (1-fhandRAmt)*femaleHandStartPos[R] + fhandRAmt*(opponent.pos + YANK_FHANDR_POS)])
		var farmLScale = 1.0 + handAmt*0.12 + 0.1*handBackAmt
		if flose.isFlat:
			farmLScale -= 0.1
		opponent.skeleton.layUpperScale[L] = farmLScale
		var farmAng = (opponent.skeleton.forearmLay1[L].get_rotation() - femaleForearmLStartAng) + \
					(opponent.skeleton.armLay1[L].get_rotation() - femaleArmLStartAng) + opponent.skeleton.abdomen.get_rotation()
		handRHoldAng = GRABR_HANDANG + 0.9*farmAng
		winSkeleton.placeHandR(handRPos, Vector2.ZERO, handRHoldAng)
		var yankAmt = clamp((dt - 0.12)/1.8, 0, 1)
		var yankAmt2 = yankAmt*yankAmt
		flose.setYankAmt(yankAmt)
		var fshiftAmt = 0.4*yankAmt + 1.3*yankAmt2 - 0.7*yankAmt2*yankAmt2
		flose.basePos = opponentStartPos + (1-fshiftAmt)*(LEGR2_FSHIFT + LEGL2_FSHIFT)
		flose.setLegLSOpen(getLegLSOpen())
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME:
		if abStartAng == null:
			abStartAng = winSkeleton.abdomen.get_rotation() - 2*PI
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME)
		var amt = dt/REACHL_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var amtX = 0.3*amt + 2.8*amt2 - 2.7*amt4 + 0.6*amt4*amt4
		var amtY = 0.4*amt + 1.5*amt2 - 0.9*amt2*amt2
		var liftYAmt = 0.2*amt + 2.5*amt2 -4.0*amt4 + 1.3*amt4*amt4
		var scaleAmt = -1.2*amt2 + 2.2*amt4
		winSkeleton.placeHandLBend(Vector2((1-amtX)*handStartPos[L].x + amtX*(opponent.pos.x + REACHL_POS.x), \
									(1-amtY)*handStartPos[L].y + amtY*(opponent.pos.y + REACHL_POS.y) - 200*liftYAmt),
									1.0*(1-scaleAmt) + scaleAmt*REACHL_UPPERSCALE, 1.0*(1-scaleAmt) + scaleAmt*REACHL_FORESCALE,
									0.0)
		male.pos = opponentStartPos + PULLOUT_POS + amt*REACHL_HIPSHIFT
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, handRHoldAng)
		var abAmt = 0.2*amt + 1.8*amt2 - 1.0*amt4
		winSkeleton.abdomen.set_rotation((1-abAmt)*abStartAng + abAmt*REACHL_ABANG)
		winSkeleton.penis.transform.origin = winSkeleton.penisBasePos + amt*REACHL_PENSHIFT
		flose.setLegLSOpen(getLegLSOpen())
		if !armLInside && amt > 0.6:
			armLInside = true
			opponent.get_node("polygons/Lay1/LegR").z_index = 29
			opponent.get_node("polygons/Lay1/LegR2").z_index = 28
			opponent.get_node("polygons/Lay1/CalfR").z_index = 30
			var index = opponent.get_node("polygons/Lay1/ForearmR").z_index + 1
			male.get_node("polygons_win/ForearmL").z_index = index
			male.get_node("polygons_win/HandL").z_index = index
			male.get_node("polygons_win/HandL_grabR").z_index = index
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME)
		var amt = dt/LEGR_LIFT1_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		flose.setLegRLift(amt)
		flose.setLegRLiftAng(getFLegRLiftAng() + (1-amt)*0.4)
		var amtX = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		var amtY = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		var scaleAmt = sqrt(amt)
		var handDownAmt = 0.2*amt + 2.5*amt2 -4.0*amt4 + 1.3*amt4*amt4
		var scaleBoostAmt = 0.2*amt + 2.5*amt2 -4.0*amt4 + 1.3*amt4*amt4
		winSkeleton.placeHandLBend(opponent.pos + Vector2(
					(1-amtX)*REACHL_POS.x + amtX*LEGR_LIFT1_GRABPOS.x, \
					(1-amtY)*REACHL_POS.y + amtY*LEGR_LIFT1_GRABPOS.y + handDownAmt*30),
					REACHL_UPPERSCALE*(1-scaleAmt) + scaleAmt*LEGR_LIFT1_UPPERSCALE + scaleBoostAmt*0.25, REACHL_FORESCALE*(1-scaleAmt) + scaleAmt*LEGR_LIFT1_FORESCALE,
					0.0)
		var hipAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		male.pos = opponentStartPos + PULLOUT_POS + REACHL_HIPSHIFT + hipAmt*LEGR_LIFT1_HIPSHIFT
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, handRHoldAng)
		var abAmt = 0.2*amt + 1.8*amt2 - 1.0*amt4
		winSkeleton.abdomen.set_rotation((1-abAmt)*REACHL_ABANG + abAmt*LEGR_LIFT1_ABANG)
		var kneeAmt = hipAmt
		kneePos = [(1-kneeAmt)*LEGL2_KNEE_POS + kneeAmt*LEGR_LIFT1_KNEEL_POS, (1-kneeAmt)*LEGR2_KNEE_POS + kneeAmt*LEGR_LIFT1_KNEER_POS]
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		var fhipAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		flose.basePos = opponentStartPos + amt*LEGR_LIFT1_FSHIFT
		flose.setLegLSOpen(getLegLSOpen())
		if flose.isSpreadR:
			male.get_node("polygons_win/HandL").z_index = opponent.get_node("polygons/Lay1/ForearmR").z_index + 1
		elif amt > 0.3:
			male.get_node("polygons_win/HandL").z_index = opponent.get_node("polygons/Lay1/Body_flat").z_index - 1
		if amt > 0.95:
			male.get_node("polygons_win/HandL").set_visible(false)
			male.get_node("polygons_win/HandL_grabR").set_visible(true)
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME)
		var amt = dt/PULL1_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		flose.setLegRLiftAng(getFLegRLiftAng())
		var pullAmt = max(0, (dt - 0.3)/(PULL1_TIME - 0.3))
		var pullAmt2 = pullAmt*pullAmt
		pullAmt = 0.5*pullAmt + 1.2*pullAmt2 - 0.7*pullAmt2*pullAmt2
		flose.basePos = opponentStartPos + LEGR_LIFT1_FSHIFT + pullAmt*PULL1_SHIFT
		var fhandRAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		var grabShift = fhandRAmt*(PULL1_GRABPOS - LEGR_LIFT1_GRABPOS)
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, handRHoldAng)
		winSkeleton.placeHandLBend(opponent.pos + LEGR_LIFT1_GRABPOS + grabShift, LEGR_LIFT1_UPPERSCALE, LEGR_LIFT1_FORESCALE, \
					getFarmRAbsAng() - getArmLAbsAng() + HANDL_GRAB_ANG)
		opponent.skeleton.placeLayArms([opponent.pos + YANK_POS, opponent.pos + YANK_FHANDR_POS + grabShift])
		opponent.skeleton.layUpperScale[R] = 1.0 + fhandRAmt*0.16
		opponent.skeleton.layForearmScale[R] = 1.0 + fhandRAmt*0.12
		var rotAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		winSkeleton.abdomen.set_rotation((1-rotAmt)*LEGR_LIFT1_ABANG + rotAmt*PULL1_ABANG)
		var kneeAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		kneePos = [(1-kneeAmt)*LEGR_LIFT1_KNEEL_POS + kneeAmt*PULL1_KNEEL_POS, \
					(1-kneeAmt)*LEGR_LIFT1_KNEER_POS + kneeAmt*PULL1_KNEER_POS]
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		flose.setLegLSOpen(getLegLSOpen())
		if amt > 0.1:
			opponent.get_node("polygons/Lay1/ForearmR").set_visible(false)
			opponent.get_node("polygons/Lay1/ForearmR_grab").set_visible(true)
		male.get_node("polygons_win/LegL").z_index = 25
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME)
		var amt = dt/PULL2_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var pullAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		flose.basePos = opponentStartPos + LEGR_LIFT1_FSHIFT + PULL1_SHIFT + pullAmt*PULL2_SHIFT
		opponent.skeleton.hip.set_rotation(flose.startHipAng + PULL2_FHIP_ROT*pullAmt)
		opponent.skeleton.abdomen.set_rotation(-PULL2_FHIP_ROT*pullAmt)
		flose.setLegRLiftAng(getFLegRLiftAng())
		var grabShift = pullAmt*PULL2_HAND_SHIFT
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, handRHoldAng)
		winSkeleton.placeHandLBend(opponent.pos + PULL1_GRABPOS + grabShift, LEGR_LIFT1_UPPERSCALE, LEGR_LIFT1_FORESCALE, \
					getFarmRAbsAng() - getArmLAbsAng() + HANDL_GRAB_ANG)
		opponent.skeleton.placeLayArms([opponent.pos + YANK_POS, \
				opponent.pos + YANK_FHANDR_POS + (PULL1_GRABPOS - LEGR_LIFT1_GRABPOS) + grabShift])
		var rotAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		winSkeleton.abdomen.set_rotation((1-rotAmt)*PULL1_ABANG + rotAmt*PULL2_ABANG)
		winSkeleton.hip.set_rotation((1-rotAmt)*MPushBack.HIPROT + rotAmt*PULL2_HIPANG)
		kneePos = [PULL1_KNEEL_POS, PULL1_KNEER_POS]
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		winSkeleton.penis.transform.origin = winSkeleton.penisBasePos + (1-amt)*REACHL_PENSHIFT + amt*FINAL_PENSHIFT
		flose.setLegLSOpen(getLegLSOpen())
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME + AIM_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME)
		var amt = dt/AIM_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var pullBackAmt = 0.2*amt + 2.5*amt2 -4.0*amt4 + 1.3*amt4*amt4
		var aimAmt = 0.4*amt + 1.3*amt2 - 0.7*amt2*amt2
		male.pos = opponentStartPos + (1-aimAmt)*(PULLOUT_POS+REACHL_HIPSHIFT+LEGR_LIFT1_HIPSHIFT) + aimAmt*AIM_POS + pullBackAmt*Vector2(0, 30)
		winSkeleton.hip.set_rotation((1-aimAmt)*PULL2_HIPANG + aimAmt*AIM_HIPANG)
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, 0.0)
		var grabShift = aimAmt*AIM_HAND_SHIFT
		winSkeleton.placeHandLBend(opponent.pos + PULL1_GRABPOS + PULL2_HAND_SHIFT + grabShift, LEGR_LIFT1_UPPERSCALE, LEGR_LIFT1_FORESCALE, \
					getFarmRAbsAng() - getArmLAbsAng() + HANDL_GRAB_ANG)
		opponent.skeleton.placeLayArms([opponent.pos + YANK_POS, \
				opponent.pos + YANK_FHANDR_POS + (PULL1_GRABPOS - LEGR_LIFT1_GRABPOS) + PULL2_HAND_SHIFT + grabShift])
		flose.setLegLSOpen(getLegLSOpen())
		flose.setLegRLiftAng(getFLegRLiftAng())
	elif time < LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME + AIM_TIME + ENTER_TIME:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME + AIM_TIME)
		var amt = dt/ENTER_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var reactDt = (dt - 0.5)/0.2
		var reactAmt = exp(-reactDt*reactDt)
		opponent.skeleton.hip.set_rotation(flose.startHipAng + PULL2_FHIP_ROT - 0.1*reactAmt)
		opponent.skeleton.abdomen.set_rotation(-PULL2_FHIP_ROT + 0.1*reactAmt)
		var enterAmt = 1.5*amt2 - 0.5*amt4
		winSkeleton.penis.set_rotation(penStartRot + (1-enterAmt)*PEN_EXIT_ROT + enterAmt*ENTER_PENANG + 0.09*reactAmt)
		male.pos = opponentStartPos + (1-enterAmt)*AIM_POS + enterAmt*ENTER_POS
		winSkeleton.hip.set_rotation(AIM_HIPANG)
		flose.setVagOpen(enterAmt*ENTER_VOPEN)
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, handRHoldAng)
		winSkeleton.placeHandLBend(opponent.pos + PULL1_GRABPOS + PULL2_HAND_SHIFT + AIM_HAND_SHIFT, LEGR_LIFT1_UPPERSCALE, LEGR_LIFT1_FORESCALE, \
					getFarmRAbsAng() - getArmLAbsAng() + HANDL_GRAB_ANG)
		opponent.skeleton.placeLayArms([opponent.pos + YANK_POS, opponent.pos + YANK_FHANDR_POS + (PULL1_GRABPOS - LEGR_LIFT1_GRABPOS) + PULL2_HAND_SHIFT + AIM_HAND_SHIFT])
		flose.setLegLSOpen(getLegLSOpen())
		flose.setLegRLiftAng(getFLegRLiftAng())
		kneePos = [PULL1_KNEEL_POS*(1-enterAmt) + enterAmt*ENTER_KNEEL_POS, \
					PULL1_KNEER_POS*(1-enterAmt) + enterAmt*ENTER_KNEER_POS]
	elif thrustCount < NTHRUSTS:
		var dt = time - (LEGR1_START_TIME + LEGR1_TIME + LEGR2_TIME + LEGL1_TIME + LEGL2_TIME + GRABR_TIME + YANK_TIME + REACHL_TIME + LEGR_LIFT1_TIME + PULL1_TIME + PULL2_TIME + AIM_TIME + ENTER_TIME)
		
		var thrust
		var thrustPeriod = 1.5
		if thrustCount == 0:
			thrustPeriod = 3.5
		elif thrustCount == 1:
			thrustPeriod = 2.3
		elif thrustCount == NTHRUSTS - 2:
			thrustPeriod = 7.0
		elif thrustCount == NTHRUSTS - 1:
			thrustPeriod = 10.0
		thrustCycle += delta/thrustPeriod
		if thrustCycle > 1:
			thrustCycle = 0
			thrustCount += 1
		if thrustCount < NTHRUSTS - 2:
			thrust = thrustFunc(thrustCycle)
			flose.human.face.setEyesClosed()
			
			if thrust < 0.1:
				bumpTrigger = false
			elif thrust > 0.75 && bumpTrigger == false:
				bumpTrigger = true
				flose.bump(0.8 if thrustCount > 0 else 0.5)
				thrustSoundIndex = (thrustSoundIndex + 1)%THRUST_SUND_INDICES.size()
				flose.human.hitSounds.playDb(THRUST_SUND_INDICES[thrustSoundIndex], -4)
			
			if thrustCount == 1:
				flose.human.startCrying()
		else:
			var finalTime1 = 0.18 if thrustCount < NTHRUSTS-1 else 0.17
			var finalTime2 = 0.34 if thrustCount < NTHRUSTS-1 else 0.31
			var finalTime3 = 0.47 if thrustCount < NTHRUSTS-1 else 0.38
			var finalTime4 = 0.62 if thrustCount < NTHRUSTS-1 else 0.57
			var finalTime5 = 0.82 if thrustCount < NTHRUSTS-1 else 0.73
			if thrustCycle < 0.18:
				var st = thrustCycle/finalTime1
				var st2 = st*st
				st = 0.3*st + 1.6*st2 - 0.9*st2*st2
				thrust = 0.82*st
				if st > 0.8 && soundTrigger == false:
					soundTrigger = true
					flose.human.crySounds.play(7)
				flose.human.face.setPain(0)
			elif thrustCycle < finalTime2:
				var st = (thrustCycle - finalTime1)/(finalTime2 - finalTime1)
				var st2 = st*st
				st = 0.1*st + 1.5*st2 - 0.6*st2*st2
				thrust = 0.82 + 0.18*st
				if st > 0.8 && bumpTrigger == false:
					bumpTrigger = true
					flose.human.face.setShock(-0.0)
					flose.bump(0.06)
					flose.human.loseSounds.play(4 if thrustCount < NTHRUSTS-1 else 3)
			elif thrustCycle < finalTime3:
				thrust = 1.0
				bumpTrigger = false
			elif thrustCount < NTHRUSTS-1 && thrustCycle < finalTime5:
				thrustCycle = finalTime5
				thrust = 1.0
			elif thrustCycle < finalTime4:
				var st = min(1, 1.4*(thrustCycle - finalTime3)/(finalTime4 - finalTime3))
				thrust = 1.0 + 0.15*thrustFunc(st)
				if st > 0.30 && bumpTrigger == false:
					bumpTrigger = true
					flose.bump(0.4)
					flose.human.loseSounds.play(1)
					flose.human.face.setShock(-0.5)
			elif thrustCycle < finalTime5:
				var st = min(1, 1.4*(thrustCycle - finalTime4)/(finalTime5 - finalTime4))
				thrust = 1.0 + 0.15*thrustFunc(st)
				if st < 0.1:
					bumpTrigger = false
				elif st > 0.30 && bumpTrigger == false:
					bumpTrigger = true
					flose.bump(0.4)
					flose.human.loseSounds.play(2)
					flose.human.face.setShock(-0.5)
			else:
				var st = (thrustCycle - finalTime5)/(1 - finalTime5)
				var st2 = st*st
				st = 0.3*st + 1.5*st2 - 0.8*st2*st2
				thrust = 1 - st
				bumpTrigger = false
				if st > 0.2:
					flose.human.face.setEyesClosed()
					human.game.isFinished = true
			thrust = 1.55*thrust
		
		winSkeleton.penis.set_rotation(penStartRot + ENTER_PENANG + 0.05*thrust)
		male.pos = opponentStartPos + ENTER_POS + thrust*Vector2(-43, 8)
		winSkeleton.hip.set_rotation(AIM_HIPANG)
		winSkeleton.abdomen.set_rotation(PULL2_ABANG + 0.06*sqrt(thrust))
		kneePos = [ENTER_KNEEL_POS + thrust*Vector2(5, 15), \
					ENTER_KNEER_POS + thrust*Vector2(-10, 0)]
		var thighScale = getThighScale()
		var calfScale = getCalfScale()
		winSkeleton.placeLegs([opponentStartPos + LEGL2_POS, opponentStartPos + LEGR2_POS], \
					[thighScale[L], thighScale[R]], \
					[calfScale[L], calfScale[R]])
		winSkeleton.placeHandR(opponent.pos + YANK_POS, Vector2.ZERO, handRHoldAng)
		var grabShift = min(1, thrust)*Vector2(11, 8)
		winSkeleton.placeHandLBend(opponent.pos + grabShift + PULL1_GRABPOS + PULL2_HAND_SHIFT + AIM_HAND_SHIFT, LEGR_LIFT1_UPPERSCALE, LEGR_LIFT1_FORESCALE, \
					getFarmRAbsAng() - getArmLAbsAng() + HANDL_GRAB_ANG)
		opponent.skeleton.placeLayArms([opponent.pos + YANK_POS, \
				opponent.pos + grabShift + YANK_FHANDR_POS + (PULL1_GRABPOS - LEGR_LIFT1_GRABPOS) + PULL2_HAND_SHIFT + AIM_HAND_SHIFT])
		var openAmt = clamp(thrust*5, 0, 1)
		flose.setVagOpen((1-openAmt)*ENTER_VOPEN + openAmt*1.0)
		flose.setLegRLiftAng(getFLegRLiftAng())
		flose.setLegLSOpen(getLegLSOpen() - 0.10*thrust)
		
	winSkeleton.hip.position = male.pos


func getThighScale():
	var thighScale = [0, 0]
	for i in [L, R]:
		var hipPos = winSkeleton.hip.transform.origin + winSkeleton.leg[i].transform.origin.rotated(winSkeleton.hip.get_rotation())
		var thighLen = ((opponentStartPos + kneePos[i]) - hipPos).length()
		thighScale[i] = thighLen/winSkeleton.thighLen[i]
	return thighScale

func getCalfScale():
	var calfScale = [0, 0]
	for i in [L, R]:
		var calfLen = (winSkeleton.footPos[i] - (opponentStartPos + kneePos[i])).length()
		calfScale[i] = calfLen/winSkeleton.calfLen[i]
	return calfScale


func getLegLSOpen():
	return 1.0 - 0.01*(kneePos[R].x - (opponent.pos.x - opponentStartPos.x) - 130)


func getFarmRAbsAng():
	return opponent.skeleton.forearmLay1[R].get_rotation() + opponent.skeleton.armLay1[R].get_rotation() + \
				opponent.skeleton.hip.get_rotation() + opponent.skeleton.abdomen.get_rotation()

func getArmLAbsAng():
	return winSkeleton.forearmL.get_rotation() + winSkeleton.armL.get_rotation() + \
				winSkeleton.hip.get_rotation() + winSkeleton.abdomen.get_rotation()


func getFLegRLiftAng():
	var shoulderPos = winSkeleton.getShoulderLPos()
	var armAng = winSkeleton.armL.get_rotation() + winSkeleton.hip.get_rotation() + winSkeleton.abdomen.get_rotation()
	var hipPos = opponent.pos + opponent.skeleton.heightDiff*Vector2.DOWN + \
			opponent.skeleton.thighRLay1s.position.rotated(opponent.skeleton.hip.get_rotation())
	var kneeDist = (shoulderPos - hipPos).length() - opponent.skeleton.calfRLay1s.position.x
	var contactPos = shoulderPos + kneeDist*Vector2(cos(armAng), sin(armAng))
	return (contactPos - hipPos + Vector2(-60 + 0.11*kneeDist, 0)).angle()


func thrustFunc(cycle):
	var moveTime = 10*cycle
	var moveTime2 = moveTime*moveTime
	return 0.4*exp(-1.2*moveTime)*(moveTime2 + moveTime2*moveTime2)


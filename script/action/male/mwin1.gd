extends Action
class_name MWin1

func get_class():
	return "MWin1"


const HANDR_MOVE_TIME = 0.7
const PRY1_TIME = 1.8
const WORK_TIME = 6.0
const TRY1_TIME = 1.4
const RESET_TIME = 0.8
const WORK2_TIME = 3.5
const TRY2_TIME = 1.7
const PREP_TIME = PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME + TRY2_TIME
const THRUST_TIME = 8.0
const PRY_POS = Vector2(47, 56) - Vector2(9, -8)
const PRY_POS_SHIFT = Vector2(2, -4)
const POKE_POS = Vector2(-11, 10) - Vector2(9, -8)
const TRY1_END_POS = Vector2(-17, 246) - Vector2(-100, 183.5) - Vector2(9, -8)
const TRY2_END_POS = Vector2(-7, 255) - Vector2(-100, 183.5) - Vector2(9, -8)
const END_LEG_SPREAD = 3.0


var male
var opponent
var winSkeleton : MaleWinSkeleton
var flose : FLose1
var startPos
var opponentStartPos
var opponentHandStartPos
var tryStartPos
var tryStartPenRot
var bumpTrigger
var sounds


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent


func start():
	winSkeleton = male.get_node("Skeleton2D_win")
	opponent.perform(FLose1.new(opponent))
	startPos = male.pos
	opponentStartPos = opponent.pos
	opponentHandStartPos = opponent.trueGlobalHandPos()
	flose = opponent.action
	bumpTrigger = false
	male.get_node("polygons/Back/Penis").z_index = Utility.getAbsZIndex(opponent.get_node("polygons/Body/Body/VagR")) - 1
	
	sounds = [
		[PRY1_TIME + 0.2, 6],
		[PRY1_TIME + 2.0, 1],
		[PRY1_TIME + WORK_TIME + 0.2, 7],
		[PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + 2.0, 6],
		[PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME + TRY2_TIME + 0.2, 5],
		[PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME + TRY2_TIME + 2.0, 2],
		[PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME + TRY2_TIME + 4.8, 3]
	]


func canStop():
	return true

func isDone():
	return false


func perform(time, delta):
	
	for event in sounds:
		if event[1] != null && time > event[0]:
			flose.human.crySounds.playDb(event[1], -3)
			event[1] = null
	
	var legDepth = 0
	
	if time < PRY1_TIME:
		var dt = time
		if time < HANDR_MOVE_TIME:
			var handMoveAmt = dt/HANDR_MOVE_TIME
			handMoveAmt = 2*handMoveAmt - handMoveAmt*handMoveAmt
			var handRPos = opponent.pos + PRY_POS + (1-handMoveAmt)*Vector2(50, -80)
			winSkeleton.placeHandR(handRPos, Vector2.ZERO, 0.0)
		var pryAmt = clamp((dt - HANDR_MOVE_TIME)/(PRY1_TIME - HANDR_MOVE_TIME), 0, 1)
		flose.setLegsOpen(pryAmt, 0)
		opponent.get_node("polygons/Lay1/LegL2").set_visible(false)
		var moveAmt = clamp((dt - 1.0)/(PRY1_TIME - 1.0 - 0.1), 0, 1)
		male.pos = startPos + moveAmt*POKE_POS
	elif time < PRY1_TIME + WORK_TIME:
		var dt = time - PRY1_TIME
		var workAmt = dt/WORK_TIME
		var moveTime = fmod(2.5*workAmt, 1.0)
		var moveAround = moveFunc(moveTime)
		if moveTime < 0.1:
			bumpTrigger = false
		elif moveTime > 0.2:
			bumpTrigger = true
			flose.bump(0.2)
		legDepth = workAmt
		male.pos = startPos + POKE_POS + Vector2(-4*moveAround - 10*legDepth, 15*legDepth)
		winSkeleton.penis.set_rotation(-0.1*moveAround)
		flose.targetSquirmRate = 2.0
		flose.human.face.setPain(0.5)
	elif time < PRY1_TIME + WORK_TIME + TRY1_TIME:
		if tryStartPos == null:
			tryStartPos = male.pos
			tryStartPenRot = winSkeleton.penis.get_rotation()
		
		var dt = time - PRY1_TIME - WORK_TIME
		var amt = dt/TRY1_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var downAmt = min(1, 2*amt)
		var downAmt2 = downAmt*downAmt
		downAmt = 0.3*downAmt + 1.5*downAmt2 - 1.2*downAmt2
		var forwardAmt = 0.2*amt + 1.8*amt2 - 1.0*amt4
		
		male.pos = Vector2((1-forwardAmt)*tryStartPos.x + forwardAmt*(opponentStartPos.x + TRY1_END_POS.x), \
							(1-downAmt)*tryStartPos.y + downAmt*(opponentStartPos.y + TRY1_END_POS.y))
		
		var penRotAmt = clamp((dt - 0.85)/(TRY1_TIME - 1.2), 0, 1)
		var penRotAmt2 = penRotAmt*penRotAmt
		penRotAmt = -0.2*penRotAmt + 2.8*penRotAmt2 - 1.6*penRotAmt2*penRotAmt2
		winSkeleton.penis.set_rotation((1-penRotAmt)*tryStartPenRot + penRotAmt*0.5 + amt*0.2)
		
		legDepth = clamp(1 - penRotAmt, 0, 1)
		flose.human.face.setShock(0.8)
	elif time < PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME:
		tryStartPos = null
		
		var dt = time - PRY1_TIME - WORK_TIME - TRY1_TIME
		var amt = dt/RESET_TIME
		var amt2 = amt*amt
		var vertAmt = 0.3*amt + 1.7*amt2 - 1.0*amt2*amt2
		var horAmt = 2.0*amt2 - 1.0*amt2*amt2
		var resetPos = startPos + POKE_POS
		male.pos = Vector2((1-horAmt)*(opponentStartPos.x + TRY1_END_POS.x) + horAmt*resetPos.x, \
							(1-vertAmt)*(opponentStartPos.y + TRY1_END_POS.y) + vertAmt*resetPos.y)
		winSkeleton.penis.set_rotation(max(0, 0.7 - 1.0*amt2))
		flose.human.face.setPain(0.5)
	elif time <  PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME:
		var dt = time - (PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME)
		var workAmt = dt/WORK2_TIME
		var moveTime = fmod(1.5*workAmt, 1.0)
		var moveAround = moveFunc(moveTime)
		if moveTime < 0.1:
			bumpTrigger = false
		elif moveTime > 0.2 && bumpTrigger == false:
			bumpTrigger = true
			flose.bump(0.3)
		legDepth = workAmt
		male.pos = startPos + POKE_POS + Vector2(-4*moveAround - 10*legDepth, 15*legDepth)
		winSkeleton.penis.set_rotation(-0.1*moveAround)
		flose.targetSquirmRate = 2.0
	elif time < PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME + TRY2_TIME:
		if tryStartPos == null:
			tryStartPos = male.pos
			tryStartPenRot = winSkeleton.penis.get_rotation()
		
		var dt = time - (PRY1_TIME + WORK_TIME + TRY1_TIME + RESET_TIME + WORK2_TIME)
		var amt = dt/TRY2_TIME
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var downAmt = min(1, 2*amt)
		var downAmt2 = downAmt*downAmt
		downAmt = 0.4*downAmt + 1.0*downAmt2 - 0.4*downAmt2*downAmt2
		var forwardAmt = 0.2*amt + 1.8*amt2 - 1.0*amt4
		
		male.pos = Vector2((1-forwardAmt)*tryStartPos.x + forwardAmt*(opponentStartPos.x + TRY2_END_POS.x), \
							(1-downAmt)*tryStartPos.y + downAmt*(opponentStartPos.y + TRY2_END_POS.y))
		flose.setVagOpen(0.25*amt)
		
		var penRotAmt = downAmt
		winSkeleton.penis.set_rotation(tryStartPenRot + penRotAmt*0.33)
		legDepth = 1
		flose.human.face.setShock(0.8)
	elif time < PREP_TIME + THRUST_TIME:
		
		var dt = time - PREP_TIME
		var thrustPeriod = 1.5
		var cycle = fmod(dt/thrustPeriod, 1.0)
		
		var moveTime = 12*cycle
		var thrust = 1.847264*exp(-moveTime)*(moveTime*moveTime)
		
		male.pos = opponentStartPos + TRY2_END_POS + thrust*Vector2(-12, 5)
		
		if thrust < 0.1:
			bumpTrigger = false
		elif thrust > 0.2 && bumpTrigger == false:
			bumpTrigger = true
			flose.bump(0.8)
		
		legDepth = 1
		flose.targetSquirmRate = 0.5
		
		var legsOpenAmt = dt/THRUST_TIME
		flose.setLegsOpen(1 + legsOpenAmt*(END_LEG_SPREAD-1), legsOpenAmt*END_LEG_SPREAD)
		opponent.skeleton.placeLayArms(opponentHandStartPos)
		
		if dt > 4*thrustPeriod:
			flose.human.face.setPain(0.3)
		elif dt > 2*thrustPeriod:
			flose.human.face.setEyesClosed()
	
	
	var legPush = min(1, 2.0*sqrt(legDepth))
	opponent.skeleton.setLaySkinMove(max(0, legPush*(0.5 - flose.legsOpenAmt[L])),
										max(0, legPush*(0.5 - flose.legsOpenAmt[R])))
	
	winSkeleton.placeLegs([opponentStartPos + MPushBack.FOOTL_POS, opponentStartPos + MPushBack.FOOTR_POS], \
							[1.0, 1.0 - 0.005*(male.pos.y - startPos.y)], \
							[1.0, 1.0])
	winSkeleton.placeHandL(male.handGlobalPos[L], 1.0)
	
	if time > HANDR_MOVE_TIME:
		winSkeleton.placeHandR(opponent.pos + PRY_POS + flose.legsOpenAmt[L]*PRY_POS_SHIFT, Vector2.ZERO, 0.0)
	
	winSkeleton.hip.position = male.pos


func moveFunc(moveTime):
	var cycle = -3 + 6*moveTime
	var move = 3.474*(cycle - pow(cycle,5))/exp(2*cycle*cycle)
	return move + pow(0.5*(1 - cos(2*PI*moveTime)), 1)


func performWin2():
	opponent.get_node("polygons/Lay1/LegLLine").set_visible(false)
	male.performWin2()


func stop():
	pass

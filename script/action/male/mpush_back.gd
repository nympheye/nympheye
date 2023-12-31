extends Action
class_name MPushBack

func get_class():
	return "MPushBack"


const REACH = 500
const LEAN = 20*PI/180
const FOOTL_POS = Vector2(300, 280)
const FOOTR_POS = Vector2(290, 130)
const PUSH_TIME = FFallBack.FALL_TIME + 0.6
const HIPROT = -80*PI/180


var male
var opponent
var startPos
var opponentStartPos
var done
var pushTime
var isLay
var isGrab
var isLegBehind
var winSkeleton
var footRStartPos
var startPenZ
var fhandLStartPos


func _init(maleIn).(maleIn):
	male = maleIn
	opponent = male.opponent


func start():
	pushTime = 0
	isLay = false
	isGrab = false
	isLegBehind = false
	winSkeleton = male.get_node("Skeleton2D_win")
	footRStartPos = male.footGlobalPos[R]
	startPenZ = male.get_node("polygons_win/Penis").z_index
	startPos = male.pos
	opponentStartPos = opponent.pos
	fhandLStartPos = opponent.handGlobalPos[L]


func canStop():
	return pushTime > PUSH_TIME

func isDone():
	return false


func perform(time, delta):
	male.targetAbAng = -LEAN - 0.2*pushTime
	male.approachTargetAbAng(delta)
	
	winSkeleton.hip.position = male.pos
	
	if pushTime > 0:
		isGrab = true
		male.setHandLMode(MConst.HANDL_GRAB)
	
	if time > 0.1:
		male.setIsTurn(true)
	
	var fallAmt = 0
	if pushTime > 0:
		pushTime = pushTime + delta
		var ratio = min(1, pushTime/(0.9*PUSH_TIME))
		var ratio2 = ratio*ratio
		var ratio3 = ratio2*ratio
		var ratio4 = ratio3*ratio
		
		fallAmt = 2.0*ratio2 - 1.0*ratio4
		male.targetHeight = 245*fallAmt
		male.approachTargetHeight(0.4*delta)
		male.pos.y += male.vel.y*delta
		
		var targetPosX = opponentStartPos.x + FFallBack.FALL_SHIFT.x + 125
		var moveXAmt = 0.2*ratio + 1.5*ratio2 - 0.7*ratio4
		male.pos.x = (1-moveXAmt)*startPos.x + moveXAmt*targetPosX
		var armLMove = 0.3*ratio + 1.0*ratio2 + 0.9*ratio3 - 1.2*ratio4
		opponent.targetGlobalHandPos[L] = fhandLStartPos + armLMove*Vector2(-505, 300)
	
	if pushTime < 0.1 && male.footGlobalPos[L].y >= 0:
		male.footGlobalPos[L].y = -0.001
	if pushTime > 0.0 && male.footGlobalPos[L].y < 0:
		male.moveFoot(delta, L, opponent.pos.x + 110)
	
	if pushTime > 0.4:
		var footRMove = min(1.0, 0.6*(pushTime - 0.4))
		male.footGlobalPos[R] = (1 - footRMove)*footRStartPos + footRMove*Vector2(opponent.pos.x + 580, -40)
		male.footAngles[R] = -1.1*footRMove
	
	if !isLegBehind && pushTime > (0.6*PUSH_TIME):
		isLegBehind = true
		var legPoly = male.get_node("polygons/LegR")
		legPoly.get_node("CalfR").z_index = -61
		legPoly.get_node("LegR").z_index = -60
	
	if !isLay && pushTime > (0.65*PUSH_TIME):
		isLay = true
		male.get_node("polygons").set_visible(false)
		male.get_node("polygons_win").set_visible(true)
		male.get_node("polygons_win/Penis").z_index = male.get_node("polygons_win/Body").z_index - 1
		winSkeleton.hip.set_rotation(HIPROT)
	
	var farmAng = opponent.skeleton.forearmAbsAngle[L]
	var farmVect = Vector2(cos(farmAng), sin(farmAng))
	var farmOrthoVect = Vector2(farmVect.y, -farmVect.x)
	
	# = Vector2(40, -60) - 30*farmVect + 0*40*farmOrthoVect + \
	male.targetGlobalHandPos[L] = Vector2(-20, -80) + \
				male.femaleGlobalHandPos(L) - male.skeleton.handHipOffset[L]
	male.approachTargetHandPos(0.5*delta)
	if isGrab:
		male.handGlobalPos[L] = male.targetGlobalHandPos[L]
		male.handAngles[L] = 0.5*(farmAng - male.skeleton.forearmAbsAngle[L] + 1.5)
	
	if pushTime == 0 && (male.handGlobalPos[L] - male.targetGlobalHandPos[L]).length() < 10:
		if opponent.perform(FFallBack.new(opponent)):
			pushTime = delta
	
	if isLay:
		winSkeleton.placeLegs([opponent.pos + FOOTL_POS, opponent.pos + FOOTR_POS], \
					[1.0, fallAmt], [1.0, 1.0])
		winSkeleton.placeHandL(male.handGlobalPos[L], 1.0)
		


func stop():
	male.get_node("polygons_win/Penis").z_index = startPenZ


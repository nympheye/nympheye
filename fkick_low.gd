extends Action
class_name FKickLow

func get_class():
	return "FKickLow"


const TURNLEN = 0.38
const KICKLEN = 0.3
const UNKICKLEN = 0.3
const UNTURNLEN = 0.38

const STAMINA = 0.35
const HIP_ROT = -0.8

const TAN_VECT = Vector2(1, 0.3)/sqrt(1 + pow(0.3, 2))
const RAD_VECT = Vector2(TAN_VECT.y, -TAN_VECT.x)


var female
var opponent
var turnSkeleton : FKickSkeleton
var isTurn
var startRelFootPos
var startFootAngles
var isContact
var turnFootPos
var done


func _init(humanIn).(humanIn):
	female = humanIn


func start():
	opponent = female.opponent
	isContact = null
	done = false
	turnSkeleton = female.get_node("Skeleton2D_turn")
	turnSkeleton.head.set_rotation(0.27)
	turnSkeleton.hair.set_rotation(0.5)
	startRelFootPos = [female.footGlobalPos[L] - female.pos, female.footGlobalPos[R] - female.pos]
	startFootAngles = [female.footAngles[L], female.footAngles[R]]
	female.gruntSounds.playRandom()
	female.tire(STAMINA)
	setZOrder()
	female.setHandLMode(FConst.HANDL_OPEN)


func canStop():
	return done


func isDone():
	return done


func perform(time, delta):
	female.slideFeet(delta, 0, 0)
	
	if time < TURNLEN:
		var amt
		if TURNLEN - time < delta:
			amt = 1.0
		else:
			amt = time/TURNLEN
		female.skeleton.hip.set_rotation(-0.9*amt)
		female.targetHeight = 120 + 120*amt
		female.targetRelHandPos[L] = amt*Vector2(-300,100)
		female.targetRelHandPos[R] = amt*Vector2(-100,100)
		female.approachTargetHeight(delta)
		female.approachTargetHandPos(delta)
		female.footGlobalPos[L] = female.pos + (1-amt)*startRelFootPos[L] + amt*Vector2(-200, -200)
		female.footGlobalPos[R] = female.pos + (1-amt)*startRelFootPos[R] + amt*Vector2(150, -220)
		female.footAngles[L] = (1-amt)*startFootAngles[L] + amt*0.7
		female.footAngles[R] = (1-amt)*startFootAngles[R] + amt*0.5
		if amt > 0.7:
			female.setIsTurn(true)
	elif time < TURNLEN + KICKLEN:
		if !isTurn:
			setIsTurn(true)
			female.owner.swingSounds.playRandom()
		var dt = time - TURNLEN
		var amt = dt/KICKLEN
		var amt2 = amt*amt
		var amt4 = amt2*amt2
		var amt8 = amt4*amt4
		turnSkeleton.footL.position = Vector2(female.pos.x + 152, 612)
		var thighScale = 1.0 + 0.1*(1 - amt4)
		var calfScale = 1.0 + 0.1*(1 - amt4)
		var groinPos = opponent.pos + Vector2(5, 85) - \
				(turnSkeleton.footL.position + female.skeleton.heightDiff*Vector2.DOWN)
		groinPos.x = min(groinPos.x, 225)
		var radPos = -74 + 33*amt4 + 1000*(1 - pow(amt, 0.18))
		var tanPos = -30 - 120*sqrt(amt) + 190*amt2 + 750*amt4 - 480*amt8
		turnFootPos = groinPos - radPos*RAD_VECT - tanPos*TAN_VECT
		turnSkeleton.setConfig(turnFootPos, HIP_ROT, HIP_ROT, thighScale, calfScale)
		if amt > 0.38 && isContact == null:
			isContact = checkContact()
			if isContact:
				if opponent.perform(FKickLowRec.new(opponent)):
					setZOrder()
	elif time < TURNLEN + KICKLEN + UNKICKLEN:
		var dt = time - TURNLEN - KICKLEN
		var amt = dt/UNKICKLEN
		var amt2 = amt*amt
		var thighScale = 1.0
		var calfScale = 1.0
		var targetFootPos = Vector2(150, -270)
		var footPos = Vector2((1-amt)*turnFootPos.x + amt*targetFootPos.x, \
							(1-amt)*turnFootPos.y + amt*targetFootPos.y)
		turnSkeleton.setConfig(footPos, HIP_ROT, HIP_ROT, thighScale, calfScale)
	elif time < TURNLEN + KICKLEN + UNKICKLEN + UNTURNLEN:
		setIsTurn(false)
		var dt = time - TURNLEN - KICKLEN - UNKICKLEN
		var amt = dt/UNTURNLEN
		female.skeleton.hip.set_rotation(-0.9*(1-amt))
		female.targetHeight = 250 - 200*amt
		female.targetRelHandPos[L] = (1-amt)*Vector2(-300,100)
		female.targetRelHandPos[R] = (1-amt)*Vector2(-100,100)
		female.approachTargetHeight(delta)
		female.approachTargetHandPos(delta)
		female.footGlobalPos[L] = Vector2(female.pos.x, 0) + (1-amt)*Vector2(-200, 10)
		female.footGlobalPos[R] = Vector2(female.pos.x, 0) + (1-amt)*Vector2(150, -20)
		female.footAngles[L] = (1-amt)*0.7 + amt*startFootAngles[L]
		female.footAngles[R] = (1-amt)*0.5 + amt*startFootAngles[R]
	else:
		done = true
	
	if time > TURNLEN && time < TURNLEN + KICKLEN + UNKICKLEN:
		var hairAmt = time - TURNLEN
		hairAmt = hairAmt/0.29 - 1
		hairAmt = 1 - hairAmt*hairAmt
		turnSkeleton.hair.set_rotation(0.3 + 0.5*hairAmt)
		
		if !female.hasTop:
			var ratio = (time - TURNLEN)/(KICKLEN + UNKICKLEN)
			var breastAmt = 0.8*ratio
			var breastAmt2 = breastAmt*breastAmt
			var breastAmt4 = breastAmt2*breastAmt2
			breastAmt = (1.5*breastAmt2 - 6.0*breastAmt4)*exp(-8*breastAmt2)
			turnSkeleton.setBreastPos(breastAmt/0.04*Vector2(-5, -30))


func checkContact():
	var toePos = turnSkeleton.toeR.get_global_position() + Vector2(-24, -140)
	var dist = (opponent.skeleton.groin.get_global_position() - toePos).length()
	return dist < 30


func setIsTurn(newTurn):
	if newTurn != isTurn:
		isTurn = newTurn
		female.setIsTurn(isTurn)
		female.get_node("polygons").set_visible(!isTurn)
		var poly = female.get_node("polygons_turn")
		poly.set_visible(isTurn)
		poly.z_index = opponent.get_node("polygons/Body").z_index
		poly.get_node("CalfR").set_visible(isTurn)
		poly.get_node("FootR_low").set_visible(isTurn)
		poly.get_node("FootR").set_visible(!isTurn)
		poly.get_node("ArmL").set_visible(!isTurn)
		poly.get_node("ArmL_back").set_visible(isTurn)
		poly.get_node("ArmR").set_visible(!isTurn)
		poly.get_node("ArmR_back").set_visible(isTurn)
		poly.get_node("LegL_back").set_visible(isTurn)
		poly.get_node("LegL").set_visible(!isTurn)
		poly.get_node("CalfR_high").set_visible(!isTurn)


func stop():
	pass


func setZOrder():
	female.setDefaultZOrder()
	opponent.setDefaultZOrder()


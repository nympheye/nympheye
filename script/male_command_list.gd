extends CommandList
class_name MaleCommandList

func get_class():
	return "MaleCommandList"


const PASS = 0
const PUNCH = 1
const STRIP_TOP = 2
const STRIP_BOTTOM = 3
const BLOCK_LOW = 4
const UNBLOCK = 5
const GRAB_ARMR = 6
const GRAB_BOTH = 7
const PUSH_BACK = 8
const WIN1 = 9
const WIN2 = 10
const GRAB_PEN_UP = 11
const GRAB_PEN_DOWN = 12
const GRAB_PEN_LEFT = 13
const GRAB_PEN_RIGHT = 14
const GRAB_PEN_STOP = 15
const GRAB_ARMR_PUNCH = 16
const GRAB_ARMR_STRIP = 17
const GRAB_ARMR_FEEL = 18
const GRAB_ARMR_STOP = 19
const GRAB_REC_PUNCH = 20
const QUIT = 21
const STRIP_SELF = 22
const SUICIDE = 23
const BLOCK_HIGH = 24
const NCOMMAND = 25


func _init(humanIn).(humanIn, NCOMMAND):
	controlMap[PUNCH] = InputController.C_HIT
	isPressControl[PUNCH] = true
	controlMap[STRIP_TOP] = InputController.C_STRIP
	isPressControl[STRIP_TOP] = true
	controlMap[STRIP_BOTTOM] = InputController.C_STRIP
	isPressControl[STRIP_BOTTOM] = true
	controlMap[BLOCK_LOW] = InputController.C_BLOCK
	controlMap[BLOCK_HIGH] = InputController.C_BLOCK
	controlMap[UNBLOCK] = InputController.C_BLOCK
	isReleaseControl[UNBLOCK] = true
	controlMap[GRAB_ARMR] = InputController.C_GRAB
	isPressControl[GRAB_ARMR] = true
	controlMap[GRAB_BOTH] = InputController.C_STRIP
	isPressControl[GRAB_BOTH] = true
	controlMap[PUSH_BACK] = InputController.C_STRIP
	isPressControl[PUSH_BACK] = true
	controlMap[WIN1] = InputController.C_STRIP
	isPressControl[WIN1] = true
	controlMap[WIN2] = InputController.C_STRIP
	isPressControl[WIN2] = true
	controlMap[GRAB_PEN_UP] = InputController.C_DOWN
	controlMap[GRAB_PEN_DOWN] = InputController.C_UP
	controlMap[GRAB_PEN_LEFT] = InputController.C_BACK
	controlMap[GRAB_PEN_RIGHT] = InputController.C_FORWARD
	controlMap[GRAB_PEN_STOP] = InputController.C_STOP
	controlMap[GRAB_ARMR_PUNCH] = InputController.C_HIT
	controlMap[GRAB_ARMR_STRIP] = InputController.C_STRIP
	controlMap[GRAB_ARMR_FEEL] = InputController.C_STRIP
	controlMap[GRAB_ARMR_STOP] = InputController.C_STOP
	controlMap[GRAB_REC_PUNCH] = InputController.C_HIT
	controlMap[QUIT] = InputController.C_QUIT
	isPressControl[QUIT] = true
	controlMap[STRIP_SELF] = InputController.C_STRIP
	isPressControl[STRIP_SELF] = true
	controlMap[SUICIDE] = InputController.C_STRIP
	isPressControl[SUICIDE] = true
	



func updateValid():
	var noAction = human.action == null
	var isDown = human.isDown()
	var isUp = human.isUp()
	var isActive = human.opponent.isActive
	var isOpponentKnees = human.opponent.isPerforming("FFallKnees")
	
	isValid[PASS] = human.isAi
	isValid[PUNCH] = noAction && isActive
	isValid[STRIP_TOP] = noAction && isActive && human.opponent.hasTop && (!isDown || human.isAi)
	isValid[STRIP_BOTTOM] = noAction && isActive && human.opponent.hasBottom && (!human.opponent.hasTop || isDown)
	isValid[BLOCK_LOW] = (noAction && !isUp)
	isValid[BLOCK_HIGH] = (noAction && isUp)
	isValid[UNBLOCK] = human.isPerforming("MBlock")
	isValid[GRAB_ARMR] = noAction && isActive && !isOpponentKnees
	isValid[GRAB_BOTH] = noAction && isActive && !isOpponentKnees && human.options.sexEnabled && !human.opponent.hasTop && !human.opponent.hasBottom && !human.hasCloth && !human.isImpotent
	isValid[PUSH_BACK] = noAction && human.options.sexEnabled && isOpponentKnees && !human.hasCloth && human.opponent.action.time > 1.5
	isValid[WIN1] = human.isPerforming("MPushBack") && human.action.pushTime > 2.5
	isValid[WIN2] = human.isPerforming("MWin1") && human.action.time > MWin1.PREP_TIME + MWin1.THRUST_TIME
	isValid[GRAB_PEN_UP] = human.isPerforming("MGrabArmsPen")
	isValid[GRAB_PEN_DOWN] = human.isPerforming("MGrabArmsPen")
	isValid[GRAB_PEN_LEFT] = human.isPerforming("MGrabArmsPen")
	isValid[GRAB_PEN_RIGHT] = human.isPerforming("MGrabArmsPen")
	isValid[GRAB_PEN_STOP] = human.isPerforming("MGrabArmsPen")
	isValid[GRAB_ARMR_PUNCH] = human.isPerforming("MGrabArmR")
	isValid[GRAB_ARMR_STRIP] = human.isPerforming("MGrabArmR") && human.opponent.hasBottom
	isValid[GRAB_ARMR_FEEL] = human.isPerforming("MGrabArmR") && !human.opponent.hasBottom
	isValid[GRAB_ARMR_STOP] = human.isPerforming("MGrabArmR")
	isValid[GRAB_REC_PUNCH] = human.isPerforming("FGrabBallRec")
	isValid[QUIT] = !(human.isActive && human.opponent.isActive)
	isValid[STRIP_SELF] = noAction && human.options.sexEnabled && !human.opponent.hasTop && !human.opponent.hasBottom && human.hasCloth && !human.isImpotent
	isValid[SUICIDE] = noAction && human.options.sexEnabled && human.opponent.isPerforming("FDie") && human.opponent.action.time > 5
	


func isReady(type):
	if type == PASS:
		return true
	elif type == PUNCH:
		return human.stamina >= MPunch.STAMINA
	elif type == STRIP_TOP:
		return human.stamina >= MGrabTop.STAMINA
	elif type == STRIP_BOTTOM:
		return human.stamina >= MGrabCloth.STAMINA
	elif type == BLOCK_LOW:
		return true
	elif type == BLOCK_HIGH:
		return true
	elif type == UNBLOCK:
		return true
	elif type == GRAB_ARMR:
		return human.stamina >= MGrabArmR.STAMINA && !human.opponent.isRecoiling()
	elif type == GRAB_BOTH:
		return human.stamina >= MGrabArms.STAMINA && human.erect > 0.65 && human.targetErect > 0.8 && !human.opponent.isRecoiling()
	elif type == PUSH_BACK:
		return true
	elif type == WIN1:
		return true
	elif type == WIN2:
		return true
	elif type == GRAB_PEN_UP:
		return true
	elif type == GRAB_PEN_DOWN:
		return true
	elif type == GRAB_PEN_LEFT:
		return true
	elif type == GRAB_PEN_RIGHT:
		return true
	elif type == GRAB_PEN_STOP:
		return true
	elif type == GRAB_ARMR_PUNCH:
		return human.stamina >= MGrabArmR.SUBACT_STAMINA[MGrabArmR.PUNCH_GUT]
	elif type == GRAB_ARMR_STRIP:
		return human.stamina >= MGrabArmR.SUBACT_STAMINA[MGrabArmR.TEAR]
	elif type == GRAB_ARMR_FEEL:
		return true
	elif type == GRAB_ARMR_STOP:
		return true
	elif type == GRAB_REC_PUNCH:
		return human.stamina >= FGrabBallRec.PUNCH_STAMINA
	elif type == STRIP_SELF:
		return human.stamina >= 0.3
	elif type == QUIT:
		return true
	elif type == SUICIDE:
		return true
	return true


func tryExecuteCommand(type):
	
	if type == PASS:
		pass
	elif type == PUNCH:
		return human.perform(MPunch.new(human))
	elif type == STRIP_TOP:
		return human.perform(MGrabTop.new(human))
	elif type == STRIP_BOTTOM:
		return human.perform(MGrabCloth.new(human))
	elif type == BLOCK_LOW:
		if human.isPerforming("MBlock"):
			human.action.blockLow = true
			return true
		else:
			return human.perform(MBlock.new(human, true, false))
	elif type == BLOCK_HIGH:
		if human.isPerforming("MBlock"):
			human.action.blockHigh = true
			return true
		else:
			return human.perform(MBlock.new(human, false, true))
	elif type == UNBLOCK:
		return human.stopActionClass("MBlock")
	elif type == GRAB_ARMR:
		return human.perform(MGrabArmR.new(human))
	elif type == GRAB_BOTH:
		return human.perform(MGrabArms.new(human))
	elif type == PUSH_BACK:
		return human.perform(MPushBackApproach.new(human))
	elif type == WIN1:
		return human.perform(MWin1.new(human))
	elif type == WIN2:
		return human.action.performWin2()
	elif type == GRAB_PEN_UP:
		return human.action.shiftTargetY(false)
	elif type == GRAB_PEN_DOWN:
		return human.action.shiftTargetY(true)
	elif type == GRAB_PEN_LEFT:
		return human.action.shiftTargetX(false)
	elif type == GRAB_PEN_RIGHT:
		return human.action.shiftTargetX(true)
	elif type == GRAB_PEN_STOP:
		return human.action.release()
	elif type == GRAB_ARMR_PUNCH:
		return human.action.startSubaction(MGrabArmR.PUNCH_GUT)
	elif type == GRAB_ARMR_STRIP:
		return human.action.startSubaction(MGrabArmR.TEAR)
	elif type == GRAB_ARMR_FEEL:
		return human.action.startSubaction(MGrabArmR.FEEL)
	elif type == GRAB_ARMR_STOP:
		return human.action.startSubaction(MGrabArmR.STOP_GRAB)
	elif type == GRAB_REC_PUNCH:
		return human.action.startPunch()
	elif type == QUIT:
		return human.game.endGame()
	elif type == STRIP_SELF:
		return human.perform(MStrip.new(human))
	elif type == SUICIDE:
		human.recDamage(1.0)
	return true


func getCommandName(type):
	if type == PASS:
		return "Pass"
	elif type == PUNCH:
		return "Punch"
	elif type == STRIP_TOP:
		return "Strip her"
	elif type == STRIP_BOTTOM:
		return "Strip her"
	elif type == BLOCK_LOW:
		return "Block"
	elif type == BLOCK_HIGH:
		return "Block high"
	elif type == UNBLOCK:
		return "Block"
	elif type == GRAB_ARMR:
		return "Grab her"
	elif type == GRAB_BOTH:
		return "Violate her"
	elif type == PUSH_BACK:
		return "Pin her down"
	elif type == WIN1:
		return "Violate her"
	elif type == WIN2:
		return "Pry her open"
	elif type == GRAB_PEN_UP:
		return "Deeper"
	elif type == GRAB_PEN_DOWN:
		return "Pull out"
	elif type == GRAB_PEN_LEFT:
		return "Left"
	elif type == GRAB_PEN_RIGHT:
		return "Right"
	elif type == GRAB_PEN_STOP:
		return "Stop"
	elif type == GRAB_ARMR_PUNCH:
		return "Punch"
	elif type == GRAB_ARMR_STRIP:
		return "Strip her"
	elif type == GRAB_ARMR_FEEL:
		return "Feel her"
	elif type == GRAB_ARMR_STOP:
		return "Stop"
	elif type == GRAB_REC_PUNCH:
		return "Punch"
	elif type == QUIT:
		return "End Game"
	elif type == STRIP_SELF:
		return "Strip"
	elif type == SUICIDE:
		return "Violate her"


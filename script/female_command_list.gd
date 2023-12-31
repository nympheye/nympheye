extends CommandList
class_name FemaleCommandList

func get_class():
	return "FemaleCommandList"


const PASS = 0
const KICK = 1
const KICK_LOW = 2
const KICK_HIGH = 3
const STAB = 4
const SLASH = 5
const GRAB = 6
const GRAB_CLOTH = 7
const STAB_BALLS = 8
const UNSTAB_BALLS = 9
const WIN = 10
const WIN_GRAB = 11
const WIN_STROKE = 12
const WIN_CUT_SOFT = 13
const WIN_CUT_HARD = 14
const GRAB_STAB = 15
const GRAB_TWIST = 16
const GRAB_PULL = 17
const GRAB_REC_GRAB = 18
const GRAB_REC_KICK = 19
const STOP_GRAB = 20
const QUIT = 21
const BOLT_LOW = 22
const BOLT_HIGH = 23
const PUNCH_BALLS = 24
const NCOMMAND = 25


func _init(humanIn).(humanIn, NCOMMAND):
	controlMap[KICK] = InputController.C_KICK
	controlMap[KICK_LOW] = InputController.C_KICK
	controlMap[KICK_HIGH] = InputController.C_KICK
	controlMap[STAB] = InputController.C_HIT
	isPressControl[STAB] = true
	controlMap[SLASH] = InputController.C_HIT
	isPressControl[SLASH] = true
	controlMap[GRAB] = InputController.C_GRAB
	isPressControl[GRAB] = true
	controlMap[GRAB_CLOTH] = InputController.C_GRAB
	isPressControl[GRAB_CLOTH] = true
	controlMap[STAB_BALLS] = InputController.C_HIT
	isPressControl[STAB_BALLS] = true
	controlMap[UNSTAB_BALLS] = InputController.C_HIT
	isPressControl[UNSTAB_BALLS] = true
	controlMap[WIN] = InputController.C_GRAB
	isPressControl[WIN] = true
	controlMap[WIN_GRAB] = InputController.C_GRAB
	isPressControl[WIN_GRAB] = true
	controlMap[WIN_STROKE] = InputController.C_GRAB
	isPressControl[WIN_STROKE] = true
	controlMap[WIN_CUT_SOFT] = InputController.C_HIT
	isPressControl[WIN_CUT_SOFT] = true
	controlMap[WIN_CUT_HARD] = InputController.C_HIT
	isPressControl[WIN_CUT_HARD] = true
	controlMap[GRAB_STAB] = InputController.C_HIT
	isPressControl[GRAB_STAB] = true
	controlMap[GRAB_TWIST] = InputController.C_GRAB
	controlMap[GRAB_PULL] = InputController.C_GRAB
	controlMap[GRAB_REC_GRAB] = InputController.C_GRAB
	controlMap[GRAB_REC_KICK] = InputController.C_KICK
	controlMap[STOP_GRAB] = InputController.C_STOP
	isPressControl[STOP_GRAB] = true
	controlMap[QUIT] = InputController.C_QUIT
	isPressControl[QUIT] = true
	controlMap[BOLT_LOW] = InputController.C_HIT
	controlMap[BOLT_HIGH] = InputController.C_HIT
	controlMap[PUNCH_BALLS] = InputController.C_HIT
	
	validDelay[KICK_LOW] = 0.0
	validDelay[KICK_HIGH] = 0.0
	validDelay[SLASH] = 0.1


func _ready():
	pass


func updateValid():
	var noAction = human.action == null
	var opponentAlive = human.opponent.getHealth() > 0
	var isDown = human.isDown()
	var isUp = human.isUp()
	
	isValid[PASS] = human.isAi && noAction
	isValid[KICK] = noAction && (human.isAi || (!isDown && !isUp))
	isValid[KICK_LOW] = noAction && isDown
	isValid[KICK_HIGH] = noAction && (isUp || human.isAi)
	isValid[STAB] = noAction && human.weapon == FConst.WEAPON_KNIFE && (human.isAi || !isDown)
	isValid[SLASH] = noAction && human.weapon == FConst.WEAPON_KNIFE && isDown
	isValid[GRAB] = noAction && opponentAlive && !human.opponent.hasCloth
	isValid[GRAB_CLOTH] = noAction && opponentAlive && human.opponent.hasCloth
	isValid[STAB_BALLS] = human.isPerforming("FGrabBall") && human.action.both && human.weapon == FConst.WEAPON_KNIFE
	isValid[UNSTAB_BALLS] = human.isPerforming("FStabBalls") && human.action.isDone
	isValid[WIN] = human.opponent.isPerforming("MFallBack")
	isValid[WIN_GRAB] = human.isPerforming("FWin")
	isValid[WIN_STROKE] = human.options.sexEnabled && !human.opponent.pen1.isCutBottom && !human.opponent.pen1.isCutHead && human.isPerforming("FWinGrab") && human.opponent.getNumBalls() > 0
	isValid[WIN_CUT_SOFT] = human.options.goreEnabled && human.isPerforming("FWinGrab")
	isValid[WIN_CUT_HARD] = human.options.goreEnabled && human.isPerforming("FWinStroke")
	isValid[GRAB_STAB] = human.weapon == FConst.WEAPON_KNIFE && human.isPerforming("FGrabBall") && human.action.isGrab && !human.action.both
	isValid[GRAB_TWIST] = human.isPerforming("FGrabBall") && human.action.isGrab && human.action.both == false && !human.opponent.ball[human.action.iball].isExposed
	isValid[GRAB_PULL] = human.isPerforming("FGrabBall") && human.action.isGrab && human.action.both == false && human.opponent.ball[human.action.iball].isExposed
	isValid[GRAB_REC_GRAB] = human.isPerforming("MGrabArmRRec")
	isValid[GRAB_REC_KICK] = human.isPerforming("MGrabArmsRec")
	isValid[STOP_GRAB] = human.isPerforming("FGrabBall")
	isValid[QUIT] = !(human.isActive && human.opponent.isActive)
	isValid[BOLT_LOW] = noAction && human.weapon == FConst.WEAPON_CAST && (human.isAi || !isUp)
	isValid[BOLT_HIGH] = noAction && human.weapon == FConst.WEAPON_CAST && (human.isAi || isUp)
	isValid[PUNCH_BALLS] = human.isPerforming("FGrabBall") && human.action.both && human.weapon != FConst.WEAPON_KNIFE


func isReady(type):
	var opponentAlive = human.opponent.getHealth() > 0
	
	if type == PASS:
		return true
	elif type == KICK:
		return human.stamina >= FKick.STAMINA && human.pos.y < 30
	elif type == KICK_LOW:
		return human.stamina >= FKickLow.STAMINA && opponentAlive
	elif type == KICK_HIGH:
		return human.stamina >= FKick.STAMINA && human.pos.y < 30
	elif type == STAB:
		return human.stamina >= FStab.STAMINA && opponentAlive
	elif type == SLASH:
		return human.stamina >= FSlash.STAMINA && !human.opponent.isRecoiling()
	elif type == GRAB:
		return human.stamina >= FGrabBall.STAMINA && !human.opponent.isRecoiling() && FGrabBall.inReach(human)
	elif type == GRAB_CLOTH:
		return human.stamina >= FGrabCloth.STAMINA && !human.opponent.isRecoiling() && FGrabCloth.inReach(human)
	elif type == STAB_BALLS:
		return human.stamina >= FStabBalls.STAMINA && human.action.time > 0.8
	elif type == UNSTAB_BALLS:
		return human.action.isDone
	elif type == WIN:
		return human.opponent.action.time > 2.5
	elif type == WIN_GRAB:
		return human.action.time > FWin.HAND_END_TIME + 0.5
	elif type == WIN_STROKE:
		return human.action.time > FWinGrab.END_TIME
	elif type == WIN_CUT_SOFT:
		return human.action.time > FWinGrab.END_TIME
	elif type == WIN_CUT_HARD:
		return human.opponent.erect >= 1
	elif type == GRAB_STAB:
		return human.stamina >= FGrabBall.STAB_STAMINA
	elif type == GRAB_TWIST:
		return human.stamina >= FTwist.STAMINA && human.opponent.action.time > 0.7
	elif type == GRAB_PULL:
		return human.stamina >= FPull.STAMINA && human.opponent.action.time > 0.7
	elif type == GRAB_REC_GRAB:
		return human.stamina >= MGrabArmRRec.GRAB_STAMINA
	elif type == GRAB_REC_KICK:
		return human.stamina >= MGrabArmsRec.KICK_STAMINA
	elif type == STOP_GRAB:
		return true
	elif type == QUIT:
		return true
	elif type == BOLT_LOW:
		return human.stamina >= FCast.STAMINA
	elif type == BOLT_HIGH:
		return human.stamina >= FCast.STAMINA
	elif type == PUNCH_BALLS:
		return human.stamina >= FPunchBalls.STAMINA && human.action.time > 0.8


func tryExecuteCommand(type):
	if type == PASS:
		pass
	elif type == KICK:
		return human.perform(FKick.new(human, false))
	elif type == KICK_LOW:
		return human.perform(FKickLow.new(human))
	elif type == KICK_HIGH:
		return human.perform(FKick.new(human, true))
	elif type == STAB:
		return human.perform(FStab.new(human))
	elif type == SLASH:
		return human.perform(FSlash.new(human))
	elif type == GRAB:
		return human.perform(FGrabBall.new(human))
	elif type == GRAB_CLOTH:
		return human.perform(FGrabCloth.new(human))
	elif type == STAB_BALLS:
		human.action.dontStopGrabbing = true
		return human.perform(FStabBalls.new(human))
	elif type == UNSTAB_BALLS:
		return human.perform(FUnstabBalls.new(human))
	elif type == WIN:
		return human.perform(FWinApproach.new(human))
	elif type == WIN_GRAB:
		return human.perform(FWinGrab.new(human))
	elif type == WIN_STROKE:
		return human.perform(FWinStroke.new(human))
	elif type == WIN_CUT_SOFT:
		return human.perform(FWinCutSoft.new(human))
	elif type == WIN_CUT_HARD:
		human.action.cutHard()
	elif type == GRAB_STAB:
		human.action.startStab()
	elif type == GRAB_TWIST:
		human.action.dontStopGrabbing = true
		return human.perform(FTwist.new(human.action))
	elif type == GRAB_PULL:
		human.action.dontStopGrabbing = true
		return human.perform(FPull.new(human.action))
	elif type == GRAB_REC_GRAB:
		human.action.startSubaction(MGrabArmRRec.GRAB)
	elif type == GRAB_REC_KICK:
		return human.action.startKick()
	elif type == STOP_GRAB:
		human.stopAction()
		human.opponent.recoil(false, false, Human.GRAB_GROIN)
	elif type == QUIT:
		human.game.endGame()
	elif type == BOLT_LOW:
		return human.perform(FCast.new(human, FCast.TGT_CLASS_LOW))
	elif type == BOLT_HIGH:
		return human.perform(FCast.new(human, FCast.TGT_CLASS_HIGH))
	elif type == PUNCH_BALLS:
		human.action.dontStopGrabbing = true
		return human.perform(FPunchBalls.new(human))
	return true


func getCommandName(type):
	if type == PASS:
		return "Pass"
	elif type == KICK:
		return "Kick"
	elif type == KICK_LOW:
		return "Low Kick"
	elif type == KICK_HIGH:
		return "High Kick"
	elif type == STAB:
		return "Stab"
	elif type == SLASH:
		return "Slash"
	elif type == GRAB:
		return "Grab"
	elif type == GRAB_CLOTH:
		return "Grab"
	elif type == STAB_BALLS:
		return "Skewer"
	elif type == UNSTAB_BALLS:
		return "..."
	elif type == WIN:
		return "Pin him down"
	elif type == WIN_GRAB:
		return "Grab"
	elif type == WIN_STROKE:
		return "Stroke"
	elif type == WIN_CUT_SOFT:
		return "Slice it off"
	elif type == WIN_CUT_HARD:
		return "Slice it off"
	elif type == GRAB_STAB:
		return "Stab"
	elif type == GRAB_TWIST:
		return "Twist & Pull"
	elif type == GRAB_PULL:
		return "Pull"
	elif type == GRAB_REC_GRAB:
		return "Grab"
	elif type == GRAB_REC_KICK:
		return "Kick"
	elif type == STOP_GRAB:
		return "Stop"
	elif type == QUIT:
		return "End Game"
	elif type == BOLT_LOW:
		return "Cast"
	elif type == BOLT_HIGH:
		return "Cast High"
	elif type == PUNCH_BALLS:
		return "Flatten"


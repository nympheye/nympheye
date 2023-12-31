extends AIPlayer
class_name MaleAIPlayer

func get_class():
	return "MaleAIPlayer"


const AIM_PEN_OFFSET = Vector2(5.0, 29.0)


var penAimOffset


func _init(humanIn).(humanIn):
	direction = -1
	
	retreatSprintBias = -0.32
	
	maxRange[MaleCommandList.PUNCH] = 600
	maxRange[MaleCommandList.STRIP_TOP] = 450
	maxRange[MaleCommandList.STRIP_BOTTOM] = 380
	maxRange[MaleCommandList.GRAB_ARMR] = 380
	maxRange[MaleCommandList.GRAB_BOTH] = 450
	
	impactDelay[MaleCommandList.PUNCH] = 0.2
	impactDelay[MaleCommandList.STRIP_TOP] = 0.3
	impactDelay[MaleCommandList.STRIP_BOTTOM] = 0.35
	impactDelay[MaleCommandList.GRAB_ARMR] = 0.29
	impactDelay[MaleCommandList.GRAB_BOTH] = 0.35
	
	repeatTime[MaleCommandList.PASS] = 0.0
	repeatTime[MaleCommandList.BLOCK_LOW] = 0.1
	repeatTime[MaleCommandList.BLOCK_HIGH] = 0.1
	repeatTime[MaleCommandList.GRAB_PEN_UP] = 0.1
	repeatTime[MaleCommandList.GRAB_PEN_DOWN] = 0.1
	repeatTime[MaleCommandList.GRAB_PEN_LEFT] = 0.1
	repeatTime[MaleCommandList.GRAB_PEN_RIGHT] = 0.1
	
	setPenAim()


func getTargetSeparation():
	return defaultTargetSeparation


func getPriority(type, separation, retreatAmt):
	var noAction = human.action == null
	
	var kicking = opponent.isKicking()
	var castLow = false
	var castHigh = false
	var casting = false
	if opponent.isCasting():
		casting = true
		castLow = opponent.bolt.targetClass == FCast.TGT_CLASS_LOW
		castHigh = opponent.bolt.targetClass == FCast.TGT_CLASS_HIGH
	
	var penDelta
	var isPenAimed
	if human.isPerforming("MGrabArmsPen"):
		penDelta = human.action.penOffset - penAimOffset
		isPenAimed = penDelta.length() < 7
	
	var punchFact
	if human.isImpotent:
		punchFact = 0.7
	else:
		punchFact = 0.32*(opponent.stamina - 0.25)*max(0, opponent.getPhysicalHealth() - 0.25)
	
	if type == MaleCommandList.PASS:
		return 0.3 if !noAction else 0.2 + 0.4*(1 - human.getStamina())
	elif type == MaleCommandList.PUNCH:
		return 0.6*punchFact
	elif type == MaleCommandList.STRIP_TOP:
		return 0.7 - 0.2*retreatAmt - (0.2 if human.isImpotent else 0.0)
	elif type == MaleCommandList.STRIP_BOTTOM:
		return 0 if human.isImpotent else 0.4 - 0.2*retreatAmt
	elif type == MaleCommandList.BLOCK_LOW:
		return (0.7 if casting else 0) + (0.2 if castLow else 0) + (0.8 if kicking else 0)
	elif type == MaleCommandList.BLOCK_HIGH:
		return (0.7 if casting else 0) + (0.2 if castHigh else 0)
	elif type == MaleCommandList.UNBLOCK:
		return 0 if kicking || casting else 1
	elif type == MaleCommandList.GRAB_ARMR:
		return (0.2 if human.isImpotent else 0.5) - 0.25*retreatAmt - (0.1 if opponent.hasTop else 0.0)
	elif type == MaleCommandList.GRAB_BOTH:
		return 0 if human.isImpotent else 1.0 - 0.2*retreatAmt
	elif type == MaleCommandList.PUSH_BACK:
		return 0.5
	elif type == MaleCommandList.WIN1:
		return 0.5
	elif type == MaleCommandList.WIN2:
		return 0.5
	elif type == MaleCommandList.GRAB_PEN_UP:
		return 0.9 if isPenAimed else (0.48 if penDelta.y > 0 else 0)
	elif type == MaleCommandList.GRAB_PEN_DOWN:
		return 0.6 if abs(penDelta.x) > 12 && penDelta.y < 15 else (0.6 if penDelta.y < 0 else 0)
	elif type == MaleCommandList.GRAB_PEN_LEFT:
		return 0.5 + abs(penDelta.x)/100 if penDelta.x > 3 else 0
	elif type == MaleCommandList.GRAB_PEN_RIGHT:
		return 0.5 + abs(penDelta.x)/100 if penDelta.x < -3 else 0
	elif type == MaleCommandList.GRAB_PEN_STOP:
		var lowHealthness = max(0, (0.15 - opponent.getHealth())/0.15)
		var opponentStaminaAmt = 2*(opponent.stamina/MGrabArmsRec.KICK_STAMINA - 0.5)
		return 1.0 if opponent.getHealth() <= 0 else opponentStaminaAmt*((0.29 if difficulty >= 2 else 0.2)*(1 - lowHealthness))
	elif type == MaleCommandList.GRAB_ARMR_PUNCH:
		return 1.3*punchFact
	elif type == MaleCommandList.GRAB_ARMR_STRIP:
		return 0 if human.isImpotent else 0.5
	elif type == MaleCommandList.GRAB_ARMR_FEEL:
		return 0 if human.isImpotent else 0.5
	elif type == MaleCommandList.GRAB_ARMR_STOP:
		var opponentStaminaAmt = 2*(opponent.stamina/MGrabArmRRec.GRAB_STAMINA - 0.5)
		return 1.0 if opponent.getHealth() <= 0 else opponentStaminaAmt*(0.22 if difficulty >= 2 else 0.15)
	elif type == MaleCommandList.GRAB_REC_PUNCH:
		return 0.5
	elif type == MaleCommandList.STRIP_SELF:
		return 1.0 if opponent.isSurrender || (retreatAmt < -0.2 && human.erect > 0.6 && human.targetErect > 0.8 && !opponent.hasBottom) else 0.0
	
	return 0.0


func commandExecuted(type):
	if type == MaleCommandList.GRAB_PEN_UP:
		setPenAim()


func setPenAim():
	penAimOffset = AIM_PEN_OFFSET + Vector2(0.8*(2*randf()-1), 0.8*(2*randf()-1))



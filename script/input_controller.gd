extends Node
class_name InputController

func get_class():
	return "InputController"


const C_FORWARD = 0
const C_BACK = 1
const C_UP = 2
const C_DOWN = 3
const C_HIT = 4
const C_GRAB = 5
const C_KICK = 6
const C_BLOCK = 7
const C_STRIP = 8
const C_STOP = 9
const C_QUIT = 10
const NCONTROL = 11

const DOUBLE_TIME = 220
const MIN_SEPARATION = 305
const MAX_SEPARATION = 2000


var human
var moveState
var controlStr
var direction
var runTimer
var isPressed


func _init(humanIn):
	human = humanIn
	moveState = 0
	runTimer = 0
	controlStr = []
	isPressed = []
	for i in range(NCONTROL):
		controlStr.append("")
		isPressed.append(false)
	
	direction = 1 if human.direction else -1
	if direction > 0:
		controlStr[C_FORWARD] = "right"
		controlStr[C_BACK] = "left"
	else:
		controlStr[C_FORWARD] = "left"
		controlStr[C_BACK] = "right"
	controlStr[C_UP] = "up"
	controlStr[C_DOWN] = "down"
	controlStr[C_HIT] = "hit"
	controlStr[C_GRAB] = "grab"
	controlStr[C_KICK] = "kick"
	controlStr[C_BLOCK] = "block"
	controlStr[C_STRIP] = "strip"
	controlStr[C_STOP] = "stop"
	controlStr[C_QUIT] = "quit"
	
	setInputMap()


func setInputMap():
	var profile = human.options.keyProfiles[human.options.keys]
	
	for inputName in profile.keys():
		var events = InputMap.get_action_list(inputName)
		for event in events:
			InputMap.action_erase_event(inputName, event)
		
		var ev = InputEventKey.new()
		var scancode = OS.find_scancode_from_string(profile[inputName])
		ev.set_scancode(scancode)
		InputMap.action_add_event(inputName, ev)


func movementStep():
	
	if Input.is_action_just_pressed("K"):
		if human.opponent.isAi:
			human.opponent.aiPlayer.disabled = !human.opponent.aiPlayer.disabled
	
	
	if Input.is_action_pressed(controlStr[C_FORWARD]) == Input.is_action_pressed(controlStr[C_BACK]):
		moveState = 0
	elif Input.is_action_pressed(controlStr[C_FORWARD]) && moveState <= 0:
		moveState = 1
	elif Input.is_action_pressed(controlStr[C_BACK]):
		moveState = -1
	if Input.is_action_just_pressed(controlStr[C_FORWARD]):
		if OS.get_ticks_msec() - runTimer < DOUBLE_TIME && human.canRun():
			moveState = 2
		runTimer = OS.get_ticks_msec()
	
	var stopDist = 1.2*human.vel.x*human.vel.x/(2*human.getAccel())
	stopDist -= 1.2*sign(human.vel.x)*sign(human.opponent.vel.x)*human.opponent.vel.x*human.opponent.vel.x/(2*human.getAccel())
	if moveState > 0 && abs(human.pos.x - human.opponent.pos.x) < MIN_SEPARATION + stopDist:
		moveState = 0
	
	if moveState < 0 && abs(human.pos.x - human.opponent.pos.x) > MAX_SEPARATION:
		moveState = 0
	
	var speed = 0
	if moveState == 1:
		speed = human.walkSpeed
	elif moveState == 2:
		speed = human.runSpeed
	elif moveState == -1:
		speed = -human.walkSpeed
	human.targetSpeed = speed*direction
	
	human.isRunning = moveState == 2
	
	if moveState == 2:
		human.targetHeight = -1.0*human.runningFrac*human.upHeight
	else:
		if Input.is_action_pressed(controlStr[C_DOWN]):
			human.targetHeight = human.downHeight*(1 if moveState == 0 else 0.7)
		elif Input.is_action_pressed(controlStr[C_UP]):
			human.targetHeight = -human.upHeight*(1 if moveState == 0 else 0.5)


func actionStep(commandList):
	for type in commandList.list:
		var control = commandList.controlMap[type]
		var pressed = Input.is_action_pressed(controlStr[control])
		if commandList.isReleaseControl[type]:
			if !pressed:
				commandList.executeCommand(type)
		elif commandList.isPressControl[type]:
			if pressed && !isPressed[control]:
				commandList.executeCommand(type)
		else:
			if pressed:
				commandList.executeCommand(type)
		isPressed[control] = pressed



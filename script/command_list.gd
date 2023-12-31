extends Node
class_name CommandList

func get_class():
	return "CommandList"


var human
var list : Array
var isValid : Array
var controlMap : Array
var isPressControl : Array
var isReleaseControl : Array
var validTime : Array
var validDelay : Array
var executeTime : Array


func _init(humanIn, ntype):
	human = humanIn
	list = []
	isValid = []
	controlMap = []
	isPressControl = []
	isReleaseControl = []
	validTime = []
	validDelay = []
	executeTime = []
	for i in range(ntype):
		isValid.append(false)
		controlMap.append(0)
		isPressControl.append(false)
		isReleaseControl.append(false)
		validTime.append(0.0)
		validDelay.append(0.07)
		executeTime.append(0.0)


func step(delta):
	updateValid()
	updateList()
	for type in range(isValid.size()):
		if isValid[type]:
			validTime[type] += delta
		else:
			validTime[type] = 0.0


func updateList():
	list.clear()
	for type in range(isValid.size()):
		if isValid[type]:
			list.append(type)


func canExecute(type):
	if !isValid[type]:
		return false
	if validTime[type] < validDelay[type]:
		return false
	return isReady(type)


func executeCommand(type):
	if !canExecute(type):
		return false
	if !tryExecuteCommand(type):
		return false
	list.clear()
	executeTime[type] = human.game.time
	return true


func updateValid():
	pass


func isReady(type):
	pass


func tryExecuteCommand(type):
	return false


func getCommandName(type):
	pass

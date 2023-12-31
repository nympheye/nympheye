extends Node
class_name Action

const L = 0
const R = 1

var human
var time

func _init(humanIn):
	human = humanIn
	time = 0

func process(delta):
	time += delta
	perform(time, delta)

func start():
	pass

func canStop():
	return false

func isDone():
	return false

func perform(time, delta):
	pass

func stop():
	pass

func interrupted():
	pass



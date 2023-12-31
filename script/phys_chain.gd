extends Node2D
class_name PhysChain


const L = 0
const R = 1

const GRAVITY = 1700


var dir
var physActive
var timescale

var vel : Vector2

var child : PhysChain


func _init(dirIn):
	dir = dirIn
	physActive = true
	vel = Vector2(0.0, 0.0)
	timescale = 1.0


func _ready():
	pass


func _physics_process(delta):
	if !physActive:
		return
	delta *= timescale
	
	var angForce = getAngForce()
	if angForce == null:
		return
	
	var globalRot = get_global_rotation()
	var unitRad = Vector2(cos(globalRot), sin(globalRot))
	var unitTan = Vector2(-unitRad.y, unitRad.x)
	
	var force = externalForce()
	
	var dVel = vel - parentVel()
	var dTanVel = dVel.dot(unitTan)
	var dRadVel = dVel.dot(unitRad)
	
	var length = getLength()
	
	var torque = linInterp(angForce, getRotation())
	
	var dampConst = getAngDamp()
	var damp = (dTanVel + delta*torque/(2*length))*dampConst
	
	var maxDamp = abs(dTanVel)*length/delta
	damp = clamp(damp, -maxDamp, maxDamp)
	torque -= damp
	
	var accel = force + torque*unitTan/length
	
	rotate(delta*(dTanVel + 1.2*delta*accel.dot(unitTan))/length)
	vel += delta*accel - unitRad*dRadVel


func gravityForce():
	return GRAVITY*Vector2.DOWN


func externalForce():
	return gravityForce()


func getAngForce():
	return [[0,0]]


func getAngDamp():
	return 0


func getLength():
	return 1


func parentVel():
	return null


func getRotation():
	var ang = rad2deg(get_rotation())
	if ang < -100:
		ang += 360
	return ang


func linInterp(arr, val):
	if val < arr[0][0]:
		return arr[0][1]
	for i in range(0, arr.size()-1):
		if val < arr[i+1][0]:
			var ratio = (val - arr[i][0])/(arr[i+1][0] - arr[i][0])
			return ratio*arr[i+1][1] + (1-ratio)*arr[i][1]
	return arr.back()[1]

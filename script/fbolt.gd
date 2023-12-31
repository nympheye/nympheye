extends Bolt
class_name FBolt

func get_class():
	return "FBolt"


const VEL = 6000.0
const WAVELEN = 0.12
const FADE_OUT_DIST = 340
const FADE_IN_TIME = 120/VEL
const START_SLOPELIM = 0.7
const END_SLOPELIM = 0.24


var target
var targetClass
var shaderDisabled


func _ready():
	shaderDisabled = false


func castFBolt(from, to):
	shaderDisabled = get_owner().options.shadersDisabled
	
	cast(from, to, VEL, target == FCast.TGT_MISS_LOW)
	if shaderDisabled:
		material.set_shader_param("disabled", true)
	else:
		material.set_shader_param("wavelen", WAVELEN)
		material.set_shader_param("wavenum", (2*PI)/WAVELEN)


func _physics_process(delta):
	if !isActive:
		return
	
	if targetClass == FCast.TGT_CLASS_LOW && human.opponent.isBlockingLow():
		targetSize = 30
	elif targetClass == FCast.TGT_CLASS_HIGH && human.opponent.isBlockingHigh():
		targetSize = 150
	else:
		targetSize = 5
	
	var dist = targetDisp.length() - targetSize
	
	var fadeIn = max(0, (FADE_IN_TIME-time)/FADE_IN_TIME)
	var fadeOut = max(0, (FADE_OUT_DIST-dist)/FADE_OUT_DIST)
	
	var hsv = human.options.fboltColor
	var alpha = 0.7*max(0, 1.0 - 0.4*fadeIn - 0.7*fadeOut)
	modulate.a = alpha
	
	if !shaderDisabled:
		material.set_shader_param("rearFade", max(fadeIn, 0.8*fadeOut))
		material.set_shader_param("frontFade", max(0.3*fadeIn, 0.9*fadeOut))
		
		var slopeLim = fadeIn*START_SLOPELIM + (1-fadeIn)*END_SLOPELIM
		material.set_shader_param("lensSlopeFadeScale", 1.0/slopeLim)
		
		var phase = 0.90*(2*PI*vel*time/WAVELEN)/texture.get_width()
		material.set_shader_param("phase", phase)
	

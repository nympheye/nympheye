extends Sprite
class_name GlowEffect

func get_class():
	return "GlowEffect"


const GROW_AMT = 0.90


var isActive
var amt
var shaderDisabled


func _ready():
	setAmt(0.0)
	shaderDisabled = false


func setAmt(amtIn):
	amt = amtIn
	isActive = !shaderDisabled && amt > 0 && amt < 1
	
	set_visible(isActive)
	
	if !isActive:
		return
	
	var growAmt = amt/GROW_AMT
	var shrinkAmt = (amt - GROW_AMT)/(2.0 - GROW_AMT)
	
	modulate.a = growAmt if amt < GROW_AMT else 1.0 - shrinkAmt
	
	var ringWidth2
	var ringWidth4
	var ringRadius
	var lensStrength
	
	if amt < GROW_AMT:
		growAmt = pow(growAmt, 4)
		ringWidth2 = 30.0 + 100.0*growAmt
		ringWidth4 = 300.0*growAmt
		ringRadius = 0.2*growAmt
		lensStrength = 0.1*growAmt
	else:
		shrinkAmt = sqrt(shrinkAmt)
		ringWidth2 = 130.0 + 1000.0*shrinkAmt
		ringWidth4 = 300.0 + 3000.0*shrinkAmt
		ringRadius = 0.2*(1 - shrinkAmt)
		lensStrength = 0.1*(1 - 0.6*shrinkAmt)
	
	material.set_shader_param("ringWidth2", ringWidth2)
	material.set_shader_param("ringWidth4", ringWidth4)
	material.set_shader_param("ringRadius", ringRadius)
	material.set_shader_param("lensStrength", lensStrength)
	
	var b = 1.0 - ringRadius
	var b2 = b*b
	var b4 = b2*b2
	var offset = 1.0/(1.0 + ringWidth2*b2 + ringWidth4*b4)
	material.set_shader_param("ringOffset", offset)
	
	

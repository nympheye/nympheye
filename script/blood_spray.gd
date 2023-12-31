extends Sprite
class_name BloodSpray


var length
var isActive
var time
var shaderDisabled


func _ready():
	shaderDisabled = false


func _process(delta):
	if !isActive:
		return
	
	time += delta
	
	if time > length:
		isActive = false
		set_visible(false)
		return
	
	var amt = time/length
	
	modulate.a = 0.8*(1.0 - amt*amt)
	
	material.set_shader_param("start", 0.6*(1.0 - amt))
	material.set_shader_param("end", 1.5 - 1.0*amt)
	


func spray(pos, scale):
	if scale <= 0.0 || shaderDisabled:
		return
	time = 0.0
	isActive = true
	set_visible(true)
	position = pos
	set_scale(Vector2(scale, scale))
	length = 0.15*(0.5 + 0.5*scale)


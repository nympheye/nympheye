extends Node


const M = Human.M
const F = Human.F


var options
var armed
var optionBox
var sexOption


func _ready():
	armed = false
	options = get_node("/root/Options")
	
	optionBox = get_node("OptionBox/VBoxContainer")
	
	sexOption = [null, null]
	for i in [M,F]:
		var sexStr = "Male" if i == M else "Female"
		sexOption[i] = optionBox.get_node(sexStr + "/" + sexStr + "Mode")
		sexOption[i].add_item("Disabled")
		sexOption[i].add_item("Easy AI")
		sexOption[i].add_item("Normal AI")
		sexOption[i].add_item("Player")
		if options.isPlayer[i]:
			sexOption[i].select(3)
		else:
			sexOption[i].select(options.difficulty[i])
	
	var keysOption = optionBox.get_node("KeysOption")
	for profileName in options.keyProfileNames:
		keysOption.add_item(profileName)
	
	optionBox.get_node("GoreButton").pressed = options.goreEnabled
	optionBox.get_node("SexButton").pressed = options.sexEnabled
	optionBox.get_node("InterfaceButton").pressed = options.showInterface
	optionBox.get_node("KeysOption").select(options.keys)
	
	var fweaponOption = optionBox.get_node("FWeapon/FemaleWeapon")
	fweaponOption.add_item("Knife", FConst.WEAPON_KNIFE)
	fweaponOption.add_item("Energy Bolt", FConst.WEAPON_KNIFE)
	fweaponOption.add_item("None", FConst.WEAPON_NONE)
	fweaponOption.select(options.fweapon)
	
	updateFiltered()
	
	if Time.get_ticks_msec()/1000 < 5:
		var size = OS.window_size
		var screenSize = OS.get_screen_size()
		var ratio = 0.75*min(screenSize.x/size.x, screenSize.y/size.y)
		OS.window_size =  ratio*size
		OS.window_position = 0.5*(screenSize - ratio*size)
	


func _process(delta):
	if !Input.is_action_pressed("quit"):
		armed = true
	if armed && Input.is_action_pressed("quit"):
		get_tree().quit()


func updateFiltered():
	optionBox.get_node("SexButton").set_visible(!options.filtered)


func setHumanMode(index, sex):
	var other = ~sex & 1
	options.isPlayer[sex] = index == 3
	if options.isPlayer[sex] && options.isPlayer[other]:
		options.isPlayer[other] = false
		sexOption[other].select(options.difficulty[other])
	if index <= 2:
		options.difficulty[sex] = index


func _on_StartButton_pressed():
	get_tree().change_scene("res://scene/scene.tscn")


func _on_GoreButton_toggled(buttonPressed):
	options.goreEnabled = buttonPressed


func _on_SexButton_toggled(buttonPressed):
	options.sexEnabled = buttonPressed


func _on_MaleMode_item_selected(index):
	setHumanMode(index, M)


func _on_FemaleMode_item_selected(index):
	setHumanMode(index, F)


func _on_FemaleWeapon_item_selected(index):
	options.fweapon = index


func _on_InterfaceButton_toggled(buttonPressed):
	options.showInterface = buttonPressed


func _on_KeysOption_item_selected(index):
	options.keys = index


func _on_Background_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if (event.position - Vector2(1017, 725)).length() < 10:
				options.filtered = false
				updateFiltered()


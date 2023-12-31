extends Node
class_name Gui

func get_class():
	return "Gui"


const HEALTH_RATE = 0.3
const FONT_DISABLED_COLOR = Color(0.2, 0.2, 0.2)


var human
var healthValue
var healthBar : TextureProgress
var staminaBar : TextureProgress
var controls : Array
var fonts
var fontStartColor
var commandTypes : Array
var commandsVisible
var interfaceVisible


func _ready():
	pass


func initialize(humanIn):
	human = humanIn
	healthValue = 1.0
	healthBar = get_node("VBoxContainer/TopCorner/Bars/Health/TextureProgress")
	staminaBar = get_node("VBoxContainer/TopCorner/Bars/Stamina/TextureProgress")
	controls = [get_node("VBoxContainer/BottomCorner/Controls/Control1"), get_node("VBoxContainer/BottomCorner/Controls/Control2"), \
				get_node("VBoxContainer/BottomCorner/Controls/Control3"), get_node("VBoxContainer/BottomCorner/Controls/Control4")]
	fonts = []
	for i in range(controls.size()):
		fonts.append(controls[i].get_node("Label").get_font("font"))
	fontStartColor = fonts[0].outline_color
	commandTypes = []
	commandsVisible = true
	interfaceVisible = true
	


func _process(delta):
	healthValue =  max(human.getHealth(), healthValue - delta*HEALTH_RATE)
	healthBar.value = 100*healthValue
	staminaBar.value = 100*human.getStamina()
	if interfaceVisible != human.options.showInterface:
		interfaceVisible = human.options.showInterface
		get_node("VBoxContainer").set_visible(interfaceVisible)
	if commandsVisible == human.isAi:
		commandsVisible = !human.isAi
		get_node("VBoxContainer/BottomCorner/Controls").set_visible(commandsVisible)
	if !human.isAi:
		updateCommands()
		for i in range(commandTypes.size()):
			fonts[i].outline_color = (fontStartColor if human.commandList.canExecute(commandTypes[i]) else FONT_DISABLED_COLOR)


func updateCommands():
	var newTypes = human.commandList.list
	var isEqual = newTypes.size() == commandTypes.size()
	if isEqual:
		for i in range(commandTypes.size()):
			isEqual = isEqual && (newTypes[i] == commandTypes[i])
	if !isEqual:
		commandTypes.clear()
		for i in range(controls.size()):
			if i < newTypes.size():
				controls[i].set_visible(true)
				commandTypes.append(newTypes[i])
				var commandName = human.commandList.getCommandName(newTypes[i])
				controls[i].get_node("Label").set_text(commandName)
				var keyName = InputMap.get_action_list(human.input.controlStr[human.commandList.controlMap[newTypes[i]]])[0].as_text()
				if keyName == "Control":
					keyName = "Ctrl"
				elif keyName == "Escape":
					keyName = "Esc"
				controls[i].get_node("TextureRect/KeyLabel").set_text(keyName)
			else:
				controls[i].set_visible(false)
	


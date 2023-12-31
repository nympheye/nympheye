extends PopupDialog

var armed

func _ready():
	pass
	

func popup(bounds=Rect2(0, 0, 0, 0)):
	.popup(bounds)
	armed = false
	get_tree().paused = true


func _process(delta):
	armed = armed || (!Input.is_action_pressed("quit") && !Input.is_action_pressed("pause"))
	
	if armed && Input.is_action_pressed("quit"):
		get_tree().paused = false
		get_tree().change_scene("res://scene/menu.tscn")
	
	if armed && Input.is_action_just_pressed("pause"):
		unpause()


func _on_PauseDialog_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			unpause()


func unpause():
	get_tree().paused = false
	hide()

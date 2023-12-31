extends Node
class_name Game

func get_class():
	return "Game"


const L = 0
const R = 1

const STEP_VOLUME = 2
const VOICE_VOLUME = -2
const FEMALE_PITCH = 1.10
const MALE_PITCH = 1.10

const SEPARATION = 1000
const CAMERA_HEIGHT = -40
const MAP_LIMIT = 1650
const CAMERA_LIMIT = 1060


var male
var female
var options
var camera
var pauseDialog
var groundPos
var background
var background2
var background3

var stepSounds
var fallSounds
var cutSounds
var kickSounds
var kickKillSounds
var punchSounds
var swingSounds
var tearSounds
var slideSounds
var clapSounds
var castSounds

var time
var restartTimer
var startingSlowmo
var isFinished


func _ready():
	randomize()
	
	time = 0.0
	restartTimer = 0.0
	isFinished = false
	
	Engine.time_scale = 0.1
	startingSlowmo = true
	
	male = get_node("Male")
	female = get_node("Female")
	camera = get_node("Camera2D")
	pauseDialog = get_node("CanvasLayer/PauseDialog")
	background = get_node("Background")
	background2 = get_node("BG2Layer/Background2")
	background3 = get_node("BG3Layer/Background3")
	
	var heightDiff = (female.get_global_position() - male.get_global_position()).y
	female.skeleton.heightDiff = heightDiff
	female.get_node("Skeleton2D_win").heightDiff = heightDiff
	male.position = Vector2.ZERO
	female.position = Vector2(0, heightDiff)
	male.place(SEPARATION/2)
	female.place(-SEPARATION/2)
	groundPos = 5 + male.skeleton.toe[L].get_global_position().y - male.skeleton.hip.get_global_position().y
	
	background2.scale = Vector2(1.05/camera.zoom.x, 1/camera.zoom.y)
	background3.scale = Vector2(0.9/camera.zoom.x, 1/camera.zoom.y)
	
	fallSounds = Sounds.new(get_node("Sounds/Fall"), 0, 1)
	cutSounds = Sounds.new(get_node("Sounds/Cut"), 0, 1)
	kickSounds = Sounds.new(get_node("Sounds/Kick"), 0, 1)
	kickKillSounds = Sounds.new(get_node("Sounds/KickKill"), 0, 1)
	punchSounds = Sounds.new(get_node("Sounds/Punch"), 0, 1)
	swingSounds = Sounds.new(get_node("Sounds/Swing"), 0, 1)
	tearSounds = Sounds.new(get_node("Sounds/Tear"), 0, 1)
	slideSounds = Sounds.new(get_node("Sounds/Slide"), 0, 1)
	clapSounds = Sounds.new(get_node("Sounds/Clap"), 0, 1)
	stepSounds = Sounds.new(get_node("Sounds/Step"), STEP_VOLUME, 1)
	castSounds = Sounds.new(get_node("Sounds/Cast"), 0, 1)
	


func _process(delta):
	
	if startingSlowmo && time > 0.2:
		startingSlowmo = false
		setSlowmo(1.0)
	
	if time > 0:
		camera.smoothing_enabled = true
	time += delta
	
	var fps = Engine.get_frames_per_second()
	Engine.iterations_per_second = max(Engine.iterations_per_second, round(fps))
	
	var cameraPosX = (male.pos.x + female.pos.x)/2 + 100
	cameraPosX = clamp(cameraPosX, -CAMERA_LIMIT, CAMERA_LIMIT)
	camera.position = Vector2(cameraPosX, CAMERA_HEIGHT)
	
	var camPos = camera.get_camera_screen_center()
	background.position = Vector2(0, -105)
	background2.position = background.position + Vector2(890, 523) + Vector2(-0.60*camPos.x, -camPos.y)
	background3.position = background.position + Vector2(930, 140) + Vector2(-0.15*camPos.x, -camPos.y)
	
	if Input.is_action_just_pressed("slow_time"):
		if Engine.time_scale <= 1.0:
			setSlowmo(0.1)
		else:
			setSlowmo(1.0)
	if Input.is_action_just_pressed("fast_time"):
		if Engine.time_scale >= 1.0:
			setSlowmo(2.0)
		else:
			setSlowmo(1.0)
	
	if Input.is_action_just_pressed("switch"):
		male.isAi = !male.isAi
		female.isAi = !male.isAi
	
	if Input.is_action_just_pressed("quit"):
		pauseDialog.popup()
	
	if Input.is_action_just_pressed("pause"):
		pauseDialog.popup()
	
	if Input.is_action_just_pressed("L"):
		male.removeCloth()
		if female.hasTop:
			female.removeTop()
		else:
			female.removeBottom()
	
	if isFinished && options.autoRestartDelay > 0:
		restartTimer += delta
		if restartTimer > options.autoRestartDelay:
			get_tree().change_scene("res://scene/scene.tscn")


func endGame():
	get_tree().change_scene("res://scene/menu.tscn")


func mark(pos):
	get_node("mark").transform.origin = pos
	get_node("mark").set_visible(true)


func mark2(pos):
	get_node("mark2").transform.origin = pos
	get_node("mark2").set_visible(true)


func setSlowmo(rate):
	Engine.time_scale = options.gameSpeed*(rate if options.slowmo else 1.0)


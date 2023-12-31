extends Node


var keyProfiles
var keyProfileNames

var goreEnabled
var sexEnabled
var difficulty
var isPlayer
var showInterface
var keys
var filtered

var allOnDefault
var gameSpeed
var slowmo
var shadersDisabled
var autoRestartDelay
var masterVolume

var mbottomless
var mbottomColor
var mcolor
var msoftScale
var mhardScale
var mballScale
var mregenRateMult

var fweapon
var fwrap
var ftopless
var fbottomless
var fhairCenter
var fhairSide
var fhairColor
var fwrapColor
var ftopColor
var fbottomColor
var fskinColor
var fboltColor
var fbreastScale
var fregenRateMult


func _init():
	goreEnabled = false
	sexEnabled = false
	difficulty = [2, 2]
	isPlayer = [false, false]
	showInterface = true
	keys = 0
	filtered = true
	shadersDisabled = false
	fweapon = FConst.WEAPON_KNIFE
	
	readConfig()
	
	if allOnDefault:
		filtered = false
		goreEnabled = true
		sexEnabled = true


func readConfig():
	var dict = readJson("config.json")
	
	allOnDefault = dict.get("disable_censor")
	gameSpeed = dict.get("game_speed")
	slowmo = !dict.get("disable_slow_motion")
	autoRestartDelay = dict.get("auto_restart_delay_seconds")
	shadersDisabled = dict.get("disable_shaders")
	masterVolume = dict.get("master_volume_decibels")
	
	var maleDict = dict.get("male")
	mbottomless = maleDict.get("bottomless")
	mbottomColor = maleDict.get("bottom_color_hsv")
	mcolor = maleDict.get("skin_color_hsv")
	msoftScale = maleDict.get("penis_soft_scale")
	mhardScale = maleDict.get("penis_hard_scale")
	mballScale = maleDict.get("balls_scale")
	mregenRateMult = maleDict.get("stamina_regen_rate")
	
	var femaleDict = dict.get("female")
	fwrap = femaleDict.get("hairwrap")
	ftopless = femaleDict.get("topless")
	fbottomless = femaleDict.get("bottomless")
	fhairCenter = femaleDict.get("hair_center")
	fhairSide = femaleDict.get("hair_side")
	fhairColor = femaleDict.get("hair_color_hsv")
	fwrapColor = femaleDict.get("hairwrap_color_hsv")
	ftopColor = femaleDict.get("top_color_hsv")
	fbottomColor = femaleDict.get("bottom_color_hsv")
	fskinColor = femaleDict.get("skin_color_hsv")
	fboltColor = femaleDict.get("bolt_color_hsv")
	fbreastScale = femaleDict.get("breast_scale")
	fregenRateMult = femaleDict.get("stamina_regen_rate")
	
	var keyDict = dict.get("keys")
	keyProfiles = []
	keyProfileNames = []
	for profileName in keyDict.keys():
		keyProfileNames.append(profileName)
		keyProfiles.append(keyDict[profileName])


func readJson(filename):
	var file = File.new()
	file.open("res://" + filename, File.READ)
	var jsonStr = file.get_as_text()
	file.close()
	var dict = JSON.parse(jsonStr).result
	print(JSON.parse(jsonStr).error_string)
	return dict
	

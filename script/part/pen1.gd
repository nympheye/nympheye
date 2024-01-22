extends PhysChain
class_name Pen1

func get_class():
	return "Pen1"


const PEN_SCALE = 0.97
const ERECT_ANG = 85
const ANG = 20


var male
var cloth1 : Bone2D
var bulge : Polygon2D
var penPoly : Polygon2D
var isCutBottom
var isCutSide
var isCutHead
var clapTrigger
var headBleedTimer


func _init().(false):
	isCutBottom = false
	isCutHead = false


func _ready():
	male = owner.get_node("Male")
	cloth1 = male.get_node("Skeleton2D/Hip/ClothF1")
	bulge = male.get_node("polygons/Body/Bulge")
	penPoly = male.get_node("polygons/Body/Penis/Penis1")
	headBleedTimer = -9999


func parentVel():
	return male.vel


func getAngForce():
	var erect
	var e = male.erect*male.erect*male.erect
	erect = (2*e - e*e)*ERECT_ANG
	var ang = ANG
	if male.retract > 0.8 && male.erect < 0.5 && !male.ball[R].isSevered && !male.ball[L].isSevered && !male.hasCloth:
		ang += 15*(male.retract - 0.8)*(1 - 2*male.erect)
	return [[ang-16,						30e4],
			[ang+erect-12,					3e4],
			[ang+erect-0.1,					0],
			[ang+max(erect,60),				0],
			[ERECT_ANG+ang+25-5*male.erect,	-7e4],
			[ERECT_ANG+ang+40-5*male.erect,	-20e4]]


func getAngDamp():
	var ballDamp = 50*clamp((ANG-10) - rotation_degrees, 0, 10)
	return ballDamp + 100*(1 + 0.9*male.erect)


func getLength():
	return 25.0


func _physics_process(delta):
	var erect = male.erect
	set_scale(getScale(erect))
	
	if male.hasCloth:
		var maxRot = cloth1.getRotation() - 86
		if getRotation() > maxRot:
			set_rotation(deg2rad(maxRot))
		var closeness = max(0, 1 - (maxRot - getRotation())/5)
		bulge.color = Color(1, 1, 1, closeness)
	
	if male.isPerforming("FGrabBallRec"):
		var minRot = 20 if (male.action.ball.isExposed) else (30 + 2*male.retract)
		if getRotation() < minRot:
			set_rotation(deg2rad(minRot))
			vel /= 2
	
	if physActive:
		if male.legsClosedFrac > 0.9 && erect < 0.3 && male.partGrabFrac > 0.8:
			var maxRot = 0
			set_rotation(deg2rad(maxRot))
	
	if getRotation() > 50 && erect < 0.5:
		clapTrigger = true
	if clapTrigger && getRotation() < 15:
		clapTrigger = false
		male.game.clapSounds.playRandomDb(-3)
	
	if isCutHead:
		headBleedTimer -= delta
		if headBleedTimer <= 0:
			if headBleedTimer > -99:
				if male.action == null && male.pen1.rotation_degrees < 45:
					male.bleed(male.pen2, Vector2(-3, 6), false, penPoly, 5 + 12*randf(), 0.0)
			headBleedTimer = 1 + 4*randf()
	

func cutBottom():
	isCutBottom = true

func cutSide():
	isCutSide = true

func cutHead():
	isCutHead = true


func getScale(erect):
	return PEN_SCALE*Vector2(male.options.msoftScale + 1.68*male.options.mhardScale*erect, \
							male.options.mpenWidth*(male.options.msoftScale + 0.16*male.options.mhardScale*erect))

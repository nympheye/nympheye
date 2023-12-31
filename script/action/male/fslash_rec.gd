extends Action
class_name FSlashRec

func get_class():
	return "FSlashRec"


const LEN = 0.4


var male
var fslash
var expBall
var isBleeding
var isCut


func _init(maleIn, fslashIn).(male):
	male = maleIn
	fslash = fslashIn
	expBall = -1
	isBleeding = false
	isCut = false


func start():
	expBall = -1
	if fslash.targetBallL:
		expBall = L
	elif fslash.targetBallR:
		expBall = R
	male.owner.cutSounds.playRandom()
	male.face.setPain(-0.2)


func canStop():
	return time >= LEN

func isDone():
	return time >= LEN


func perform(time, delta):
	var ratio = time/fslash.SLASHLEN
	
	if !isBleeding:
		if ratio > (0.2 if fslash.targetPenSide else 0.0):
			isBleeding = true
			if fslash.targetBallL:
				var poly = male.get_node("polygons/Body/BallL/BallL")
				male.bleed(male.ball[L], Vector2(0, 37 if male.ball[L].isExposed else 33), \
						false, poly, 10 if male.ball[L].isExposed else 50, 0.1)
			elif fslash.targetBallR:
				var poly = male.get_node("polygons/Body/BallR/BallR")
				male.bleed(male.ball[R], Vector2(0, 35 if male.ball[L].isExposed else 30), \
						false, poly, 10 if male.ball[L].isExposed else 50, 0.1)
			elif fslash.targetPen:
				var poly = male.get_node("polygons/Body/ClothF")
				if fslash.targetPenSide:
					male.bleed(null, Vector2(-31, 51) if male.hasCloth else Vector2(-31, 42), false, poly, 10, 0.1)
				elif fslash.targetPenBottom:
					male.bleed(null, Vector2(-35, 55), false, poly, 30, 0.1)
				elif fslash.targetPenHead:
					male.bleed(null, Vector2(-31, 68), false, poly, 50, 0.1)
			elif fslash.targetCloth:
				var poly = male.get_node("polygons/Body")
				male.bleed(null, Vector2(-53, 7), false, poly, 10, 0.1)
	
	if male.hasCloth && !fslash.targetCloth && ratio < 0.12:
		male.skeleton.clothF1.vel.x -= delta*12000;
		male.skeleton.clothF1.vel.y -= delta*10000;
		male.skeleton.clothF2.vel.x -= delta*8000;
		male.skeleton.clothF3.vel.x -= delta*8000;
	if ratio < (0.1 if !fslash.targetPen else (0.3 if fslash.targetPenSide else 0.8)):
		male.pen1.vel.y -= delta*10000;
		male.pen1.vel.x -= delta*15000;
		male.pen2.vel.x -= delta*10000;
	
	if time > LEN && !fslash.targetCloth:
		male.closingLegs = true
		var ballCutOff = !fslash.targetPen && male.ball[expBall].isSevered
		male.recoil((fslash.targetPenBottom || fslash.targetPenHead) || ballCutOff, \
					ballCutOff || fslash.targetPenHead, \
					Human.GRAB_GROIN)
	
	if expBall >= 0:
		var ball = male.ball[expBall]
		if ratio > 0.5 && !isCut:
			isCut = true
			if !ball.isExposed:
				ball.expose()
			elif !ball.isSevered:
				ball.sever()
				ball.fall()
				var otherBall = male.ball[~expBall & 1]
				if otherBall.isExposed && !otherBall.isSevered:
					otherBall.sever()
					otherBall.fall()
	
	if fslash.targetPen && !isCut && ratio > (0.7 if fslash.targetPenSide else 0.4):
		isCut = true
		if fslash.targetPenSide:
			male.cutPenSide()
		elif fslash.targetPenHead:
			male.cutPenHead()
		elif fslash.targetPenBottom:
			male.cutPenBottom()
	
	if fslash.targetCloth && !isCut && ratio > 0.6:
		male.removeCloth()
	
	male.targetGlobalHandPos[L] = null
	male.targetRelHandPos[L] = Vector2.ZERO
	
	male.approachTargetHandPos(delta)
	male.updateLegsClosed(delta)
	male.approachTargetAbAng(delta)


func stop():
	male.face.setNeutral()

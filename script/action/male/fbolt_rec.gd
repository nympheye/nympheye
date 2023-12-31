extends Action
class_name FBoltRec

func get_class():
	return "FBoltRec"


const LEN = 0.4
const HITLEN = 0.1


var male
var bolt
var isHit
var tgt

var targetPen
var targetBall
var isCritical
var isRecoil
var penMoveMult


func _init(boltIn).(boltIn.human.opponent):
	male = human
	bolt = boltIn
	isHit = false


func start():
	male.owner.cutSounds.playRandom()
	male.face.setPain(-0.2)
	
	tgt = bolt.target
	targetPen = tgt == FCast.TGT_PEN_HEAD || tgt == FCast.TGT_PEN_SIDE || tgt == FCast.TGT_PEN_BOTTOM
	targetBall = tgt == FCast.TGT_BALL_L || tgt == FCast.TGT_BALL_R
	
	penMoveMult = 2*randf() - 1
	
	bleed(tgt)


func canStop():
	return time >= LEN

func isDone():
	return time >= LEN


func perform(time, delta):
	var ratio = time/HITLEN
	var ballSide = L if tgt == FCast.TGT_BALL_L else R
	
	if male.hasCloth && tgt != FCast.TGT_CLOTH && ratio < 0.12:
		male.skeleton.clothF1.vel.x -= delta*12000;
		male.skeleton.clothF1.vel.y -= delta*10000;
		male.skeleton.clothF2.vel.x -= delta*8000;
		male.skeleton.clothF3.vel.x -= delta*8000;
	if targetPen:
		if ratio < (0.3 if tgt == FCast.TGT_PEN_SIDE else 0.8):
			male.pen1.vel.y -= delta*10000;
			male.pen1.vel.x -= delta*15000;
			male.pen2.vel.x -= delta*10000;
	else:
		if ratio < 0.15:
			male.pen1.vel.x += delta*10000*penMoveMult;
			male.pen2.vel.x += delta*10000*penMoveMult;
	
	if ratio > 0.3 && !isHit:
		isHit = true
		
		isCritical = false
		isRecoil = true
		
		if targetPen:
			if tgt == FCast.TGT_PEN_SIDE:
				male.cutPenSide()
			elif tgt == FCast.TGT_PEN_HEAD:
				male.cutPenHead()
				isCritical = true
			elif tgt == FCast.TGT_PEN_BOTTOM:
				male.cutPenBottom()
				isCritical = true
		
		if tgt == FCast.TGT_CLOTH:
			male.removeCloth()
			isRecoil = false
		
		if targetPen || targetBall:
			male.cutCloth()
		
		if targetBall:
			var ball = male.ball[ballSide]
			var otherBall = male.ball[~ballSide & 1]
			if randf() < 0.5:
				if !ball.isExposed:
					ball.expose()
				elif !ball.isSevered:
					ball.sever()
					ball.fall()
					if otherBall.isExposed && !otherBall.isSevered:
						otherBall.sever()
						otherBall.fall()
					isCritical = true
			else:
				if ball.isExposed && otherBall.isExposed:
					otherBall.crush()
				male.groin.bolt(ballSide)
				ball.crush()
				isCritical = true
		
		if tgt == FCast.TGT_AB:
			male.recStabAb()
			isRecoil = false
		
		if tgt == FCast.TGT_FACE:
			male.recStabFace(bolt.position)
		
		if isCritical || tgt == FCast.TGT_PEN_SIDE:
			male.game.setSlowmo(0.10)
			male.face.setShock(-0.4)
		
	
	if ratio > 0.95 && !male.groin.isActive():
		male.game.setSlowmo(1.0)
	
	male.targetGlobalHandPos[L] = null
	male.targetRelHandPos[L] = Vector2.ZERO
	
	male.approachTargetHandPos(delta)
	male.updateLegsClosed(delta)
	male.approachTargetAbAng(delta)


func stop():
	if isRecoil:
		male.recoil(isCritical, isCritical, male.GRAB_FACE if tgt == FCast.TGT_FACE else male.GRAB_GROIN)
	else:
		male.face.setNeutral()


func bleed(tgt):
	var bleedObject = null
	var bleedPos = null
	var bleedPoly = null
	var bleedAmt = 10
	var bleedSpraySize = 0.7
	if tgt == FCast.TGT_AB:
		bleedPoly = male.get_node("polygons/Body")
		bleedAmt = 0
		bleedSpraySize = 0.5
		bleedPos = bolt.position - male.pos
	elif tgt == FCast.TGT_FACE:
		pass
	elif male.hasCloth:
		if tgt == FCast.TGT_CLOTH:
			bleedPoly = male.get_node("polygons/Body/ClothF")
			bleedPos = Vector2(-98, 20)
			bleedAmt = 0
		else:
			bleedPoly = male.get_node("polygons/Body/ClothF")
			bleedPos = Vector2(-31, 78)
	else:
		if tgt == FCast.TGT_BALL_L:
			bleedPoly = male.get_node("polygons/Body/BallL/BallL")
			bleedPos = male.ball[L].position + Vector2(0, 37 if male.ball[L].isExposed else 33)
		elif tgt == FCast.TGT_BALL_R:
			bleedPoly = male.get_node("polygons/Body/BallR/BallR")
			bleedPos = male.ball[R].position + Vector2(0, 35 if male.ball[R].isExposed else 30)
		elif targetPen:
			bleedPoly = male.get_node("polygons/Body/ClothF")
			if tgt == FCast.TGT_PEN_SIDE:
				bleedObject = male.pen2
				bleedPos = Vector2(-15, 25)
				bleedAmt = 10
			elif tgt == FCast.TGT_PEN_BOTTOM:
				bleedPos = Vector2(-35, 55)
				bleedAmt = 30
			elif tgt == FCast.TGT_PEN_HEAD:
				bleedPos = Vector2(-31, 72)
				bleedAmt = 50
	if bleedPos != null:
		male.bleed(bleedObject, bleedPos, false, bleedPoly, bleedAmt, bleedSpraySize)


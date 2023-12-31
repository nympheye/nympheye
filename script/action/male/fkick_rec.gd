extends Action
class_name FKickRec

const BALL_GROW = 1.0
const BALL_SHIFT = [10, 20]
const BALL_YI = [0.7, 0.5]
const BALL_YSHIFT = [-0.5, -0.6]

var male
var fkick
var deadBall
var done


func _init(maleIn, fkickIn).(male):
	male = maleIn
	fkick = fkickIn
	deadBall = -1
	done = false


func start():
	male.setDefaultZOrder()
	male.tire(0.3)
	
	var targetBall
	if male.ball[R].health <= 0:
		targetBall = L
	elif male.ball[L].health <= 0:
		targetBall = R
	else:
		targetBall = L if (randf() < 0.5) else R
	male.ball[targetBall].recDamage(1.0 if male.ball[targetBall].isExposed else 0.61)
	if male.ball[targetBall].health <= 0:
		deadBall = targetBall
	
	var kickPosX
	if fkick.type == fkick.FRONT:
		kickPosX = fkick.turnSkeleton.toeR.get_global_position().x - male.skeleton.hip.get_global_position().x
	else:
		kickPosX = fkick.turnSkeleton.calfR.get_global_position().x - male.skeleton.hip.get_global_position().x
	male.groin.kick(deadBall, kickPosX, Groin.KICK_KNEE if (fkick.type == fkick.KNEE) else Groin.KICK_FRONT)
	male.vel = Vector2.ZERO
	
	if deadBall == -1:
		male.game.kickSounds.playRandom()
	else:
		male.game.kickKillSounds.playRandom()


func canStop():
	return isDone()

func isDone():
	return time > fkick.IMPACTLEN0


func perform(time, delta):
	var ratio = time/fkick.IMPACTLEN0
	if ratio < 0.2:
		male.pen1.vel.y -= delta*8000
		male.pen1.vel.x -= delta*12000
		male.pen2.vel.x -= delta*10000
		male.skeleton.clothF1.vel.x -= delta*12000
		male.skeleton.clothF1.vel.y -= delta*10000
		male.skeleton.clothF2.vel.x -= delta*8000
		male.skeleton.clothF3.vel.x -= delta*8000
	
	if ratio > 0.35:
		male.closingLegs = true
	
	for i in [L,R]:
		var ball = male.ball[i]
		
		ball.transform.origin.x = ball.basePos.x - BALL_SHIFT[i]*ratio
		if ball.isCrushed:
			ball.transform.origin.y = ball.basePos.y
		else:
			ball.transform.origin.y = ball.basePos.y*(BALL_YI[i] + BALL_YSHIFT[i]*(ratio - 0.2*ratio*ratio*ratio))
		
		var ballScaleY = 1
		if deadBall == i:
			if ratio > 0.5:
				ball.crush()
			ballScaleY = 1 + BALL_GROW*(1 - pow(2*ratio - 1, 2))
		else:	
			if ratio > 0.1 && ratio < 0.9:
				ballScaleY = 1 + BALL_GROW*(1 - pow(2*(ratio - 0.1)/0.8 - 1, 2))
		ball.setScale(1, ballScaleY)
	
	male.pos.y = -fkick.liftR + fkick.accelLift + \
			35*ratio - (40 if fkick.type == fkick.FRONT else 50)*ratio*ratio*ratio*ratio
	male.limitArmExtents()
	male.footAngles = male.getFootAngles(male.skeleton.footPos)
	
	male.approachTargetHandPos(delta)
	male.updateLegsClosed(delta)
	

func stop():
	male.recoil(deadBall >= 0, deadBall >= 0, Human.GRAB_GROIN)

extends Action
class_name FKickLowRec

func get_class():
	return "FKickLowRec"


const LEN = 0.25

const BALL_GROW = 1.0
const BALL_SHIFT = [10, 20]
const BALL_YI = [0.7, 0.5]
const BALL_YSHIFT = [-0.5, -0.6]


var male
var severed


func _init(maleIn).(male):
	male = maleIn
	severed = null


func start():
	
	male.vel.y = 0
	male.vel.x *= max(0, 0.9 - 0.6*abs(male.vel.x/male.walkSpeed)) 
	
	male.face.setShock(-0.4)
	male.owner.clapSounds.playDb(6, 10)
	male.game.setSlowmo(0.07)
	
	male.tire(0.3)
	for i in [L,R]:
		male.ball[i].recDamage(0.4*male.ball[i].health)


func canStop():
	return time > LEN


func isDone():
	return time > LEN


func perform(time, delta):
	var amt = time/LEN
	
	if amt < 0.2:
		male.pen1.vel.y -= delta*8000;
		male.pen1.vel.x -= delta*12000;
		male.pen2.vel.x -= delta*10000;
		male.skeleton.clothF1.vel.x -= delta*12000;
		male.skeleton.clothF1.vel.y -= delta*10000;
		male.skeleton.clothF2.vel.x -= delta*8000;
		male.skeleton.clothF3.vel.x -= delta*8000;
		for i in [L,R]:
			male.ball[i].vel.x -= delta*(28000 if male.ball[i].isExposed else 23000)
	
	if amt >= 0.21 && severed == null:
		severed = false
		for i in [L,R]:
			var ball = male.ball[i]
			if ball.isExposed && !ball.isSevered:
				if randf() < (0.4 if ball.health <= 0 else 0.4 + 0.4*(1 - ball.health)):
					severed = true
					ball.sever()
					male.groin.snapSounds.playRandom()
					ball.fallPos(Vector2(-30, 20), \
								Vector2(-1200 if i == L else -1600, -600 - 300*randf())*(1.0 + 0.4*randf()), \
								-3.0 + 10.0*randf())
				
	
	if amt > 0.35:
		male.closingLegs = true
	
	male.slideFeet(delta, 0, 0)
	
	male.targetHeight = -40*amt + 40*amt*amt*amt*amt
	male.approachTargetHeight(4.0*delta)
	male.limitArmExtents(delta)
	
	male.footAngles = male.getFootAngles(male.skeleton.footPos)
	
	male.approachTargetHandPos(1.4*delta)
	male.updateLegsClosed(delta)
	
	if amt > 0.3:
		male.setHandLMode(MConst.HANDL_OPEN)
	
	if amt > 0.95:
		male.recoil(severed, severed, Human.GRAB_GROIN)
	
	if amt > 0.45:
		male.game.setSlowmo(1.0)


func stop():
	pass

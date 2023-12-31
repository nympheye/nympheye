extends Node
class_name Math


static func inverted(t0):
	var detInv = 1/(t0.x.x*t0.y.y - t0.x.y*t0.y.x)
	var t1 = Transform2D()
	t1.x.x = t0.y.y*detInv
	t1.x.y = -t0.x.y*detInv
	t1.y.x = -t0.y.x*detInv
	t1.y.y = t0.x.x*detInv
	return t1


static func scaledTrans(ang, scale):
	var nx = cos(ang)
	var ny = sin(ang)
	var t = Transform2D()
	t.x.x = 1 + (scale - 1)*nx*nx
	t.x.y = (scale - 1)*nx*ny
	t.y.x = (scale - 1)*nx*ny
	t.y.y = 1 + (scale - 1)*ny*ny
	return t


static func compose(t1, t2):
	var t3 = Transform2D()
	t3.x.x = t1.x.x*t2.x.x + t1.x.y*t2.y.x
	t3.x.y = t1.x.x*t2.x.y + t1.y.x*t2.x.y
	t3.y.x = t1.x.x*t2.y.x + t1.y.x*t2.y.y
	t3.y.y = t1.x.y*t2.y.x + t1.y.y*t2.y.y
	return t3


static func angleDiff(from, to):
	var ans = fposmod(to - from, TAU)
	if ans > PI:
		ans -= TAU
	return ans


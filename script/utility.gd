extends Node
class_name Utility


static func getAbsZIndex(target: Node2D) -> int:
	var node = target
	var z_index = 0
	while node and node.is_class('Node2D'):
		z_index += node.z_index
		if !node.z_as_relative:
			break
		node = node.get_parent()
	return z_index


static func approach2D(pos, dest, rate):
	var dpos = dest - pos
	var dlen = dpos.length()
	if dlen < rate:
		return dest
	else:
		return pos + (rate/dlen)*dpos


static func approach1D(pos, dest, rate):
	var dpos = dest - pos
	var dlen = abs(dpos)
	if dlen < rate:
		return dest
	else:
		return pos + rate*sign(dpos)


static func getAllChildren(node, type) -> Array:
	var nodes : Array = []
	for child in node.get_children():
		if child.get_class() == type:
			nodes.append(child)
		if child.get_child_count() > 0:
			nodes.append_array(getAllChildren(child, type))
	return nodes

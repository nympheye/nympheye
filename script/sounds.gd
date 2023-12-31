extends Node
class_name Sounds


var players
var lastRandom
var baseVolume


func _init(node, volume, pitch):
	lastRandom = 1
	players = node.get_children()
	baseVolume = []
	for sound in players:
		baseVolume.append(sound.volume_db + node.get_owner().options.masterVolume + volume)
		sound.pitch_scale = sound.pitch_scale*pitch


func playRandom():
	playRandomDb(0)


func playRandomDb(volume):
	playRandomSetDb(1, players.size(), volume)


func playRandomSetDb(minIdx, maxIdx, volume):
	var index = minIdx + randi()%(1 + maxIdx - minIdx)
	while index == lastRandom && maxIdx > minIdx:
		index = minIdx + randi()%(1 + maxIdx - minIdx)
	lastRandom = index
	playDb(index, volume)


func play(index):
	playDb(index, 0)


func playDb(index, volume):
	var player = players[index - 1]
	player.volume_db = baseVolume[index - 1] + volume
	player.play()

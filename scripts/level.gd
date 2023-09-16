class_name Level
extends Node

var map:Array[PackedScene]
var currentLevel:int 	= 0
var loadedLevel

#Selects random levels from the planet level pool
func generateMap(planet:Planet) -> Array[PackedScene]:
	var rng = RandomNumberGenerator.new()
	var levels:Array[PackedScene] = planet.levelArray
	for level in planet.planet_numLevels:
		var num = rng.randi_range(0, levels.size()-1)
		if(!map.has(levels[num])):
			map.push_back(levels[num])
	return map
		
	
func next_level():
	if currentLevel < map.size()-1:
		currentLevel += 1
		
func prev_level():
	if currentLevel > 0:
		currentLevel -= 1

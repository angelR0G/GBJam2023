class_name Level
extends Node

var map:Array[PackedScene]
var currentLevel:int 	= 0
var loadedLevel
var lastLevel:bool = false

#Selects random levels from the planet level pool
func generateMap(planet:Planet) -> Array[PackedScene]:
	var rng = RandomNumberGenerator.new()
	var levels:Array[PackedScene] = planet.levelArray
	
	while map.size() < planet.planet_numLevels:
		var num = rng.randi_range(0, levels.size()-1)
		if(!map.has(levels[num])):
			map.push_back(levels[num])
			
	return map
	
func next_level() -> bool:
	if currentLevel < map.size()-1:
		currentLevel += 1
	if currentLevel < map.size():
		lastLevel = true
	return lastLevel
		
func prev_level() -> bool:
	if currentLevel > 0:
		currentLevel -= 1
	if lastLevel && currentLevel == 0:
		#change planet
		currentLevel = 0
		return true
	return false
		

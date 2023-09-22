class_name Level
extends Node

signal levelCompleted
signal mapCompleted

var map:Array[PackedScene]
var loadedLevel
var currentLevel:int	= 0
var lastLevel:bool		= false
var lastLevelC:bool		= false
var levelForward:bool 	= true
var enemyNum:int		= 0

#Cooling capsule
var coolantSources:Array[Node]
var lastCoolantSource:int

#Selects random levels from the planet level pool
func generateMap(planet:Planet) -> Array[PackedScene]:
	var rng = RandomNumberGenerator.new()
	var levels:Array[PackedScene] = planet.levelArray
	
	while map.size() < min(levels.size(), planet.planet_numLevels):
		var num = rng.randi_range(0, levels.size()-1)
		if !map.has(levels[num]):
			map.push_back(levels[num])
			
	return map

func getTotalEnemiesLevel():
	var enemies = loadedLevel.get_node("Enemies").get_children()
	enemyNum = enemies.size()
	for e in enemies:
		e.connect("enemyDead", Callable(self, "_enemyDead"))
		
		
func getCoolantSources():
	coolantSources = loadedLevel.get_node("Coolant").get_children()
		
func getLadder() -> Node2D:
	return loadedLevel.get_node("Ladder")

func _enemyDead():
	enemyNum -= 1
	if(enemyNum <= 0):
		emit_signal("levelCompleted", levelForward)

func next_level() -> bool:
	if currentLevel < map.size():
		currentLevel += 1
	if currentLevel == map.size():
		lastLevel = true
	return lastLevel
		
func prev_level() -> bool:
	if currentLevel >= 0:
		currentLevel -= 1
		if lastLevel:
			levelForward 	= false
			lastLevelC		= true
		lastLevel 		= false
		
	if lastLevelC && currentLevel < 0:
		#change planet
		mapCompleted.emit()
		return true
	return false

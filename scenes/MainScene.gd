extends Node2D

var planets:Array[Planet] = [Planet1]
var currentPlanet:int = 0
var levelScript = preload("res://scripts/level.gd").new()
var levelMap:Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	levelMap = levelScript.generateMap(planets[currentPlanet])
	renderLevel()
	for i in levelMap:
		print(i.instantiate().get_name())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		levelScript.prev_level()
		renderLevel()
	if Input.is_action_just_pressed("ui_right"):
		levelScript.next_level()
		renderLevel()

func renderLevel():
	if levelScript.loadedLevel != null:
		remove_child(levelScript.loadedLevel)
	levelScript.loadedLevel = levelMap[levelScript.currentLevel].instantiate()
	add_child(levelScript.loadedLevel)

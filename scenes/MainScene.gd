extends Node2D

var planets:Array[Planet] = [Planet1, Planet2]
var currentPlanet:int = 0
var levelScript = preload("res://scripts/level.gd").new()
var levelMap:Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	newMap()
	
func newMap():
	levelMap = levelScript.generateMap(planets[currentPlanet])
	renderLevel()
	for i in levelMap:
		print(i.instantiate().get_name())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		var changePlanet = levelScript.prev_level()
		changePlanet(changePlanet)
		renderLevel()
	if Input.is_action_just_pressed("ui_right"):
		levelScript.next_level()
		renderLevel()

func changePlanet(changePlanet:bool):
	if(changePlanet && currentPlanet < planets.size()-1):
		currentPlanet += 1
		newMap()

func renderLevel():
	#Remove previous level
	if levelScript.loadedLevel != null:
		remove_child(levelScript.loadedLevel)
	
	#Get new level
	var lvl = levelMap[levelScript.currentLevel].instantiate()
	#Change palette
	var mat = get_material()
	mat.set_shader_parameter("replacePalette", planets[currentPlanet].planet_palette);
	
	#Create new level
	add_child(lvl)
	levelScript.loadedLevel = lvl


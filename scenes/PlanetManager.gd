extends Node2D

var planets:Array[Planet] = [Planet1, Planet2]
var currentPlanet:int = 0
var levelScript = preload("res://scripts/level.gd").new()
var levelMap:Array[PackedScene]

#Variables for nodes
var player
var transitionScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $Player
	transitionScreen = $TransitionScreen
	
	newMap()
	
func newMap():
	levelMap = levelScript.generateMap(planets[currentPlanet])
	renderLevel()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Prev_level"):
		_levelComplete(false)
		
	if Input.is_action_just_pressed("Next_level"):
		_levelComplete(true)
	
#When a level is completed
#dir indicates if player is going forward or backwards through the map
func _levelComplete(dir:bool):
	if dir:
		var lastLevel = levelScript.next_level()
	else:
		var chPlanet = levelScript.prev_level()
		changePlanet(chPlanet)
	transitionScreen.setTransitionPalette(planets[currentPlanet].planet_palette)
	transitionScreen.transition()
	player.setLockMovement(true)

func changePlanet(chPlanet:bool):
	if(chPlanet && currentPlanet < planets.size()-1):
		currentPlanet += 1
		newMap()

func renderLevel():
	#Remove previous level
	if levelScript.loadedLevel != null:
		remove_child(levelScript.loadedLevel)
	
	#Get new level
	var lvl = levelMap[levelScript.currentLevel].instantiate()
	
	#Change world palette
	var mat = get_material()
	mat.set_shader_parameter("replacePalette", planets[currentPlanet].planet_palette);
	
	#Create new level
	var marker:Marker2D = lvl.get_child(1)
	player.position = marker.position
	add_child(lvl)
	levelScript.loadedLevel = lvl


func _on_transition_screen_fade_in_ended():
	renderLevel()


func _on_transition_screen_fade_out_ended():
	player.setLockMovement(false)

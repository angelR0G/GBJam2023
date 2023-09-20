extends Node2D

var currentPlanet:int = 0
var levelScript = preload("res://scripts/level.gd").new()
var levelMap:Array[PackedScene]

#Variables for nodes
@onready var player 			= $Player
@onready var transitionScreen 	= $TransitionScreen
@onready var levelSelection 	= $LevelSelection

# Called when the node enters the scene tree for the first time.
func _ready():
	player.hide()
	player.setLockMovement(true)
	player.setLockCamera(true)
	levelSelection.planetSelected.connect(Callable(self, "newMap"), currentPlanet)
	
	
func newMap(cPlanet):
	currentPlanet = cPlanet
	print(currentPlanet)
	levelMap = levelScript.generateMap(PlanetContainer.planets[currentPlanet].planet)
	renderLevel()
	player.show()
	player.setLockMovement(false)
	player.setLockCamera(false)
	levelSelection.setLockControls(true)

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
	transitionScreen.setTransitionPalette(PlanetContainer.planets[currentPlanet].planet.planet_palette)
	transitionScreen.transition()
	player.setLockMovement(true)

func changePlanet(chPlanet:bool):
	if(chPlanet && currentPlanet < PlanetContainer.planets[currentPlanet].size()-1):
		currentPlanet += 1
		newMap(currentPlanet)

func renderLevel():
	#Remove previous level
	if levelScript.loadedLevel != null:
		remove_child(levelScript.loadedLevel)
	
	#Get new level
	var lvl = levelMap[levelScript.currentLevel].instantiate()
	
	#Change world palette
	var mat = get_material()
	mat.set_shader_parameter("replacePalette", PlanetContainer.planets[currentPlanet].planet.planet_palette);
	
	#Create new level
	var marker:Marker2D = lvl.get_child(1)
	player.position = marker.position
	add_child(lvl)
	levelScript.loadedLevel = lvl


func _on_transition_screen_fade_in_ended():
	renderLevel()


func _on_transition_screen_fade_out_ended():
	player.setLockMovement(false)

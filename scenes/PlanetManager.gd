extends Node2D

var levelScript = preload("res://scripts/level.gd").new()
var lastLevel	= preload("res://scenes/levels/LevelEnd.tscn")
var currentPlanet:int = 0
var levelMap:Array[PackedScene]
var isLastLevel:bool 	= false
var chaningPlanet:bool 	= false
var createNewMap:bool   = false
var numLevelInPlanet:int = 1
var worldMaterial:ShaderMaterial

#Signal variables
var lvlForw:bool = true

#Variables for nodes
@onready var player 			= $Player
@onready var transitionScreen 	= $TransitionScreen
@onready var levelSelection 	= $LevelSelection

# Called when the node enters the scene tree for the first time.
func _ready():
	#disable player
	player.hide()
	player.showHud(false)
	player.setLockMovement(true)
	player.setLockCamera(true)
	
	#store world material to change palette
	worldMaterial = get_material()
	
	#connect signals
	levelSelection.planetSelected.connect(Callable(self, "_storePlanetSelection"), currentPlanet)
	levelScript.levelCompleted.connect(Callable(self, "_levelComplete"), lvlForw)
	levelScript.mapCompleted.connect(Callable(self, "_mapCompleted"))
	
func _storePlanetSelection(cPlanet):
	currentPlanet = cPlanet
	createNewMap  = true
	worldMaterial.set_shader_parameter("replacePalette", 
				PlanetContainer.planets[currentPlanet].planet.planet_palette)
	transitionScreen.setTextPalette(PlanetContainer.planets[currentPlanet].planet.planet_palette)
	transitionScreen.setCurrentPalette(PlanetContainer.planets[currentPlanet].planet.planet_palette)
	transitionScreen.setTransitionType(1)
	transitionScreen.transition()
	
func newMap():
	levelSelection.setLockControls(true)
	levelMap = levelScript.generateMap(PlanetContainer.planets[currentPlanet].planet)
	renderLevel()
	player.show()
	player.showHud(true)
	player.setLockMovement(false)
	player.setLockCamera(false)

func _mapCompleted():
	transitionScreen.setTransitionType(2)
	chaningPlanet = true
	PlanetContainer.planets[currentPlanet].completed = true
	if levelScript.loadedLevel != null:
		levelScript.loadedLevel.call_deferred("queue_free")
	levelMap = []
	numLevelInPlanet = 1
	player.hide()
	player.setLockMovement(true)
	player.setLockCamera(true)
	
	levelSelection.renderPlanets()
	levelSelection.setLockControls(false)

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
		isLastLevel = levelScript.next_level()
		numLevelInPlanet+=1
	else:
		var chPlanet = levelScript.prev_level()
		numLevelInPlanet-=1
	
	transitionScreen.levelNum = numLevelInPlanet
	transitionScreen.setTransitionType(1)
	transitionScreen.isLevelForward = dir
	transitionScreen.transition()
	player.setLockMovement(true)
	player.showHud(false)

#func changePlanet(chPlanet:bool):
#	if(chPlanet):
#		newMap(currentPlanet)
		
func _createLastLevel():
	var lvlLast = lastLevel.instantiate()
	var marker:Marker2D = lvlLast.get_node("PlayerSpawn")
	player.position = marker.position
	add_child(lvlLast)
	levelScript.loadedLevel = lvlLast

func renderLevel():
	#Remove previous level
	if levelScript.loadedLevel != null:
		levelScript.loadedLevel.call_deferred("queue_free")
	
	#Change world palette
	worldMaterial.set_shader_parameter("replacePalette", PlanetContainer.planets[currentPlanet].planet.planet_palette)
	if (levelScript.lastLevel):
		_createLastLevel()
	else:
		#Get new level
		var lvl = levelMap[levelScript.currentLevel].instantiate()
		_createLevel(lvl)
	

func _createLevel(lvl):
	#Create new level
	var marker:Marker2D = lvl.get_node("PlayerSpawn")
	player.position = marker.position
	add_child(lvl)
	levelScript.loadedLevel = lvl
	levelScript.getTotalEnemiesLevel()

func _on_transition_screen_transition_ended():
	if (createNewMap && levelMap.size() <= 0):
		newMap()
		createNewMap = false
	player.setLockMovement(false)
	
	if !chaningPlanet:
		renderLevel()
	else:
		levelSelection.show()
		chaningPlanet = false




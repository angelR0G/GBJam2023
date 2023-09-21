extends Node2D

var currentPlanet:int = 0
var levelScript = preload("res://scripts/level.gd").new()
var levelMap:Array[PackedScene]
var lastLevel = preload("res://scenes/levels/LevelEnd.tscn")
var isLastLevel:bool 	= false
var chaningPlanet:bool 	= false
#Signal variables
var lvlForw:bool = true

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
	levelScript.levelCompleted.connect(Callable(self, "_levelComplete"), lvlForw)
	levelScript.mapCompleted.connect(Callable(self, "_mapCompleted"))
	
	
func newMap(cPlanet):
	levelSelection.setLockControls(true)
	currentPlanet = cPlanet
	levelMap = levelScript.generateMap(PlanetContainer.planets[currentPlanet].planet)
	renderLevel()
	transitionScreen.transition()
	player.show()
	player.setLockMovement(false)
	player.setLockCamera(false)

func _mapCompleted():
	print(currentPlanet)
	chaningPlanet = true
	PlanetContainer.planets[currentPlanet].completed = true
	if levelScript.loadedLevel != null:
		levelScript.loadedLevel.call_deferred("queue_free")
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
	else:
		var chPlanet = levelScript.prev_level()
	transitionScreen.setTransitionPalette(PlanetContainer.planets[currentPlanet].planet.planet_palette)
	transitionScreen.transition()
	player.setLockMovement(true)

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
	var mat = get_material()
	mat.set_shader_parameter("replacePalette", PlanetContainer.planets[currentPlanet].planet.planet_palette);
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

func _on_transition_screen_fade_in_ended():
	if !chaningPlanet:
		renderLevel()
	else:
		levelSelection.show()
		chaningPlanet = false


func _on_transition_screen_fade_out_ended():
	player.setLockMovement(false)

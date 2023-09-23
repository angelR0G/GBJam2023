extends Node2D

#signals
signal exitMainMenu


var levelScript = preload("res://scripts/level.gd").new()
var lastLevel	= preload("res://scenes/levels/LevelEnd.tscn")
var currentPlanet:int = 0
var levelMap:Array[PackedScene]
var isLastLevel:bool 	= false
var chaningPlanet:bool 	= false
var createNewMap:bool   = false
var numLevelInPlanet:int = 1
var worldMaterial:ShaderMaterial
var coolingCapsule 	= preload("res://scenes/characters/CoolCapsule.tscn")
var pauseMenu 		= preload("res://scenes/menus/PauseMenu.tscn")
var pauseMenuInstance
var gamePaused:bool 	= false
var transitioning:bool 	= false

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
	transitioning = true
	
	#store world material to change palette
	worldMaterial = get_material()
	
	#connect signals
	levelSelection.planetSelected.connect(Callable(self, "_storePlanetSelection"), currentPlanet)
	levelScript.levelCompleted.connect(Callable(self, "_levelLadder"), lvlForw)
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
	transitioning = true
	
func newMap():
	levelSelection.setLockControls(true)
	levelMap = levelScript.generateMap(PlanetContainer.planets[currentPlanet].planet)
	renderLevel()
	player.show()
	player.showHud(true)
	player.setLockMovement(false)
	player.setLockCamera(false)
	transitioning = false

func _mapCompleted():
	transitionScreen.setTransitionType(2)
	chaningPlanet = true
	PlanetContainer.planets[currentPlanet].completed = true
	if levelScript.loadedLevel != null:
		levelScript.loadedLevel.call_deferred("queue_free")
	levelMap = []
	numLevelInPlanet = 1
	
	transitionScreen.resetTransition()
	transitioning = true
	player.hide()
	player.showHud(false)
	player.setLockMovement(true)
	player.setLockCamera(true)
	
	levelSelection.renderPlanets()
	levelSelection.setLockControls(false)

func _unhandled_input(event):
	if !transitioning && event.is_action_pressed("menu"):
		gamePaused = !gamePaused
		
	get_tree().paused = gamePaused
	if gamePaused:
		pauseMenuInstance = pauseMenu.instantiate()
		add_sibling(pauseMenuInstance)
		pauseMenuInstance.connect("resume_game", Callable(self, "resumeGame"))
		pauseMenuInstance.connect("return_to_main_menu", Callable(self, "toGameMenu"))
		player.hide()
		player.showHud(false)
		player.setLockMovement(true)
		player.setLockCamera(true)
		pauseMenuInstance.setPlanetTexture(PlanetContainer.planets[currentPlanet].planet.planet_sprite)
		pauseMenuInstance.setPlanetName(PlanetContainer.planets[currentPlanet].planet.planet_name)
		pauseMenuInstance.setLevel(numLevelInPlanet)
		pauseMenuInstance.setCoreCollected(!lvlForw)

func toGameMenu():
	gamePaused = false
	pauseMenuInstance.queue_free()
	exitMainMenu.emit()

func resumeGame():
	if pauseMenuInstance != null:
		gamePaused = false
		player.show()
		player.showHud(true)
		player.setLockMovement(false)
		player.setLockCamera(false)
		pauseMenuInstance.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Prev_level"):
		lvlForw = false
		_levelComplete()
		
	if Input.is_action_just_pressed("Next_level"):
		lvlForw = true
		_levelComplete()
	
	

#When a level is completed
#dir indicates if player is going forward or backwards through the map
func _levelLadder(dir:bool):
	lvlForw = dir
	var ladder = levelScript.getLadder()
	ladder.openLadder(dir)
	ladder.connect("ladder_entered", Callable(self, "_levelComplete"))


func _levelComplete():
	if lvlForw:
		isLastLevel = levelScript.next_level()
		numLevelInPlanet+=1
	else:
		var chPlanet = levelScript.prev_level()
		numLevelInPlanet-=1
	get_tree().call_group("CoolCapsule", "queue_free")
	transitionScreen.levelNum = numLevelInPlanet
	transitionScreen.setTransitionType(1)
	transitionScreen.isLevelForward = lvlForw
	transitionScreen.transition()
	transitioning = true
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
	var core:Node2D = lvlLast.find_child("*Core*")
	core.connect("core_collected", Callable(self, "_coreCollected"))
	levelScript.loadedLevel = lvlLast

func _coreCollected():
	lvlForw = false
	player.toggleCoreStats(!lvlForw)
	_levelComplete()

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
	#await get_tree().create_timer(2).timeout
	levelScript.loadedLevel = lvl
	levelScript.getTotalEnemiesLevel()
	levelScript.getCoolantSources()
	_spawnCoolingCapsule()
	if !lvlForw:
		levelScript.getLadder().showLadder()

func _on_transition_screen_transition_ended():
	transitioning = false
	if (createNewMap && levelMap.size() <= 0):
		newMap()
		createNewMap = false
	player.setLockMovement(false)
	
	if !chaningPlanet:
		renderLevel()
		player.showHud(true)
	else:
		lvlForw = true
		transitionScreen.isLevelForward = lvlForw
		levelSelection.show()
		chaningPlanet = false

func _spawnCoolingCapsule():
	var sources = levelScript.coolantSources
	var gen:bool = false
	var rng = RandomNumberGenerator.new()
	while gen == false:
		if(sources.size()==0):
			return
		if(sources.size()==1):
			var cC = coolingCapsule.instantiate()
			levelScript.lastCoolantSource = 0
			cC.position = sources[0].position
			add_child(cC)
			gen = true
			return
		var num = rng.randi_range(0, max(0, sources.size()-1))
		if (num != levelScript.lastCoolantSource):
			var cC = coolingCapsule.instantiate()
			levelScript.lastCoolantSource = num
			cC.position = sources[num].position
			add_child(cC)
			gen = true
			return


func _on_player_cool_capsule_collected():
	await get_tree().create_timer(2).timeout
	_spawnCoolingCapsule()
	pass

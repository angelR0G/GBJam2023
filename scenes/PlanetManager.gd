extends Node2D

#signals
signal exitMainMenu


var levelScript = preload("res://scripts/level.gd").new()
var lastLevel	= preload("res://scenes/levels/LevelEnd.tscn")
var currentPlanet:int = 0
var currentPhase:int = 0
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

#Cinematics
var startAnimation 		= preload("res://scenes/animation/StartAnimation.tscn")
var travelingAnimation 	= preload("res://scenes/animation/TravelingAnimation.tscn")
var endAnimation 		= preload("res://scenes/animation/EndAnimation.tscn")
var gameOverAnimation 	= preload("res://scenes/animation/GameOverAnimation.tscn")

#Signal variables
var lvlForw:bool = true

#Variables for nodes
@onready var player 			= $Player
@onready var transitionScreen 	= $TransitionScreen
@onready var levelSelection 	= $LevelSelection
@onready var gameOverSound		= $GameOverSound

# Called when the node enters the scene tree for the first time.
func _ready():
	#disable player
	renderPlayer(false)
	
	transitioning = true
	levelSelection.hide()
	levelSelection.setLockControls(true)
	createStartAnimation()
	
	#store world material to change palette
	worldMaterial = get_material()
	
	#connect signals
	levelSelection.planetSelected.connect(Callable(self, "_storePlanetSelection"), currentPlanet)
	levelScript.levelCompleted.connect(Callable(self, "_levelLadder"), lvlForw)
	levelScript.mapCompleted.connect(Callable(self, "_mapCompleted"))
	player.player_dead.connect(Callable(self, "playerDead"))
	
func renderPlayer(vis:bool):
	player.visible = vis
	player.showHud(vis)
	player.setLockMovement(!vis)
	player.setLockCamera(!vis)

func createStartAnimation():
	transitioning = true
	var anim = startAnimation.instantiate()
	var animPlayer:AnimationPlayer = anim.get_node("AnimationPlayer")
	animPlayer.play("startAnimation")
	add_child(anim)
	await animPlayer.animation_finished
	anim.queue_free()
	
	createTravelingAnimation()
	
func createTravelingAnimation():
	transitioning = true
	var anim = travelingAnimation.instantiate()
	var animPlayer:AnimationPlayer = anim.get_node("AnimationPlayer")
	animPlayer.play("traveling")
	add_child(anim)
	await animPlayer.animation_finished
	anim.queue_free()
	
	levelSelection.show()
	levelSelection.setLockControls(false)
	
func createEndAnimation():
	transitioning = true
	var anim = endAnimation.instantiate()
	var animPlayer:AnimationPlayer = anim.get_node("AnimationPlayer")
	animPlayer.play("end_animation")
	add_child(anim)
	await animPlayer.animation_finished
	anim.queue_free()
	exitMainMenu.emit()
	
	
func _storePlanetSelection(cPlanet):
	currentPlanet = cPlanet
	createNewMap  = true
	worldMaterial.set_shader_parameter("replacePalette", 
				PlanetContainer.planets[currentPhase][currentPlanet].planet.planet_palette)
	transitionScreen.setTextPalette(PlanetContainer.planets[currentPhase][currentPlanet].planet.planet_palette)
	transitionScreen.setCurrentPalette(PlanetContainer.planets[currentPhase][currentPlanet].planet.planet_palette)
	transitionScreen.setTransitionType(1)
	transitionScreen.transition()
	transitioning = true
	
func newMap():
	levelSelection.setLockControls(true)
	levelMap = levelScript.generateMap(PlanetContainer.planets[currentPhase][currentPlanet].planet)
	renderLevel()
	renderPlayer(true)
	transitioning = false

func _mapCompleted():
	transitionScreen.setTransitionType(2)
	chaningPlanet = true
	PlanetContainer.planets[currentPhase][currentPlanet].completed = true
	if levelScript.loadedLevel != null:
		levelScript.loadedLevel.call_deferred("queue_free")
	levelMap = []
	numLevelInPlanet = 1
	currentPhase+=1
	levelSelection.currentPhase = currentPhase
	
	if(currentPhase >= 2):
		createEndAnimation()
	
	transitionScreen.resetTransition()
	transitioning = true
	renderPlayer(false)
	
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
		renderPlayer(false)
		pauseMenuInstance.setPlanetTexture(PlanetContainer.planets[currentPhase][currentPlanet].planet.planet_sprite)
		pauseMenuInstance.setPlanetName(PlanetContainer.planets[currentPhase][currentPlanet].planet.planet_name)
		pauseMenuInstance.setLevel(numLevelInPlanet)
		pauseMenuInstance.setCoreCollected(!lvlForw)

func toGameMenu():
	gamePaused = false
	pauseMenuInstance.queue_free()
	exitMainMenu.emit()

func playerDead():
	transitioning = true
	
	# Play sound
	gameOverSound.play()
	
	# Play animation
	var anim = gameOverAnimation.instantiate()
	var animPlayer:AnimationPlayer = anim.get_node("AnimationPlayer")
	add_child(anim)
	
	await animPlayer.animation_finished
	exitMainMenu.emit()
	
func resumeGame():
	if pauseMenuInstance != null:
		gamePaused = false
		renderPlayer(true)
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
	
	renderPlayer(false)


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
		levelScript.loadedLevel.queue_free()
	
	#Change world palette
	worldMaterial.set_shader_parameter("replacePalette", PlanetContainer.planets[currentPhase][currentPlanet].planet.planet_palette)
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
		renderPlayer(true)
	else:
		lvlForw = true
		transitionScreen.isLevelForward = lvlForw
		createTravelingAnimation()
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

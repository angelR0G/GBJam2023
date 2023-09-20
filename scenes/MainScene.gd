extends Node2D

signal load_scene_request

# Constants
const MAX_WINDOW_INITIAL_SCALE 	= 4

# Scenes
var mainMenuScene 		:= preload("res://scenes/menus/MainMenu.tscn")
var creditsMenuScene 	:= preload("res://scenes/menus/CreditsMenu.tscn")
var controlsMenuScene	:= preload("res://scenes/menus/ControlsMenu.tscn")
var planetManagerScene	:= preload("res://scenes/PlanetManager.tscn")

var loadedScene:Node	= null

func _ready():
	updateWindowSize()
	loadMainMenu()

func loadMainMenu():
	removeLastScene()
	
	# Create an instance of the main menu
	loadedScene = mainMenuScene.instantiate()
	
	# Connect  signals to functions
	loadedScene.start_game.connect(Callable(self, "loadPlanetManager"))
	loadedScene.show_credits.connect(Callable(self, "loadCredits"))
	loadedScene.show_controls.connect(Callable(self, "loadControls"))
	
	# Add the scene to the scene tree
	add_child(loadedScene)
	

func loadCredits():
	removeLastScene()
	
	# Create an instance of the main menu
	loadedScene = creditsMenuScene.instantiate()
	
	# Connect  signals to functions
	loadedScene.go_back.connect(Callable(self, "loadMainMenu"))
	
	# Add the scene to the scene tree
	add_child(loadedScene)
	

func loadControls():
	removeLastScene()
	
	# Create an instance of the main menu
	loadedScene = controlsMenuScene.instantiate()
	
	# Connect  signals to functions
	loadedScene.go_back.connect(Callable(self, "loadMainMenu"))
	
	# Add the scene to the scene tree
	add_child(loadedScene)
	
func loadPlanetManager():
	removeLastScene()
	
	# Create an instance of the main menu
	loadedScene = planetManagerScene.instantiate()
	
	# Add the scene to the scene tree
	add_child(loadedScene)


func removeLastScene():
	# If the scenes array is empty, it cannot unload any scene
	if loadedScene == null:
		return
		
	# Unload the scene and remove it from the array
	loadedScene.queue_free()
	loadedScene = null
	


func updateWindowSize():
	var width 	= get_window().size.x
	var height 	= get_window().size.y
	
	# Get screen size and tries to make screen as big as posible
	var screenSize = DisplayServer.screen_get_size()
	var screenScale = 1
	
	while screenScale <= MAX_WINDOW_INITIAL_SCALE && (width * screenScale < screenSize.x && height * screenScale < screenSize.y):
		screenScale += 1
		
	# When the scale is calculated, resize window
	screenScale -= 1
	get_window().size = Vector2(width, height) * screenScale
	get_window().position = (screenSize - get_window().size)/2.0

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
	#Engine.set_time_scale(0.3)
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
	loadedScene.connect("exitMainMenu", Callable(self, "loadMainMenu"))
	
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
	var screenIndex = DisplayServer.window_get_current_screen()
	var width 	= get_window().size.x
	var height 	= get_window().size.y
	
	# Get screen size and tries to make screen as big as posible
	var screenRect = DisplayServer.screen_get_usable_rect(screenIndex)
	var screenScale = 1
	
	while screenScale <= MAX_WINDOW_INITIAL_SCALE && (width * screenScale < screenRect.size.x && height * screenScale < screenRect.size.y):
		screenScale += 1
		
	# When the scale is calculated, resize window
	screenScale -= 1
	get_window().size = Vector2(width, height) * screenScale
	get_window().position = screenRect.position + (screenRect.size - get_window().size)/2

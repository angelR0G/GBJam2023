extends Node2D

signal planetSelected(planetSel)

var selected:int 		= 0
var lockControls:bool	= false
var currentPhase:int = 0

#Class to store planet info selection
class PlanetPos:
	var planet:Planet
	var index:int
	func _init(p, i):
		planet 	= p
		index 	= i
		
var options:Array[PlanetPos]

#Nodes
@onready var planets:Array[Sprite2D] 	= [$PlanetSprites/PlanetLeft, $PlanetSprites/PlanetRight]
@onready var borders:Array[Sprite2D] 	= [$PlanetSprites/BorderLeft, $PlanetSprites/BorderRight]
@onready var planetName 				= $Text/PlanetName
@onready var selectionTimer				= $SelectionFlash


func setLockControls(lock:bool):
	lockControls = lock

func _ready():
	renderPlanets()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !lockControls:
		if Input.is_action_just_pressed("right"):
			selectionTimer = 0
			selected = (selected + 1) % options.size()
		if Input.is_action_just_pressed("left"):
			selectionTimer = 0
			selected = (selected - 1) % options.size()
			if selected < 0:
				selected += options.size()
		if Input.is_action_just_pressed("shot"):
			emit_signal("planetSelected", options[selected].index)
			hide()
				
		_updateUI()

func _resetValues():
	options 	= []
	selected	= 0
	for p in planets:
		p.texture = null

func _selectRandomPlanets(num:int):
	_resetValues()
	var rng = RandomNumberGenerator.new()
	var indexAdded:Array[int] = []
	var availablePlanets:int = _checkAvailablePlanets()
	while options.size() < min(availablePlanets, num):
		var rand = rng.randi_range(0, PlanetContainer.planets.size()-1)
		if !PlanetContainer.planets[rand].completed && !indexAdded.has(rand):
			indexAdded.append(rand)
			options.append(PlanetPos.new(PlanetContainer.planets[currentPhase][rand].planet, rand))

func _checkAvailablePlanets() -> int:
	var avPlanets:int=0
	for p in PlanetContainer.planets:
		if (!p.completed):
			avPlanets+=1
	return avPlanets

func renderPlanets():
	_selectRandomPlanets(2)
	for i in options.size():
		planets[i].texture = options[i].planet.planet_sprite
	
func _updateUI():
	planetName.text = options[selected].planet.planet_name
	var index= 0
	while index < borders.size():
		if selected != index:
			borders[index].visible = false
		index+=1


func _on_selection_flash_timeout():
	borders[selected].visible = !borders[selected].visible

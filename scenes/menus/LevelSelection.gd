extends Node2D

signal planetSelected(planetSelection)

const numPlanets:int 	= 2 
var selected:int 		= 0
var lockControls:bool	= false

#Class to store planet info selection
class PlanetPos:
	var planet:Planet
	var index:int
	func _init(p, i):
		planet 	= p
		index 	= i
		
var options:Array[PlanetPos]

#Nodes
@onready var planetLeft 				= $PlanetSprites/PlanetLeft
@onready var planetRight				= $PlanetSprites/PlanetRight
@onready var borders:Array[Sprite2D] 	= [$PlanetSprites/BorderLeft, $PlanetSprites/BorderRight]
@onready var planetName 				= $Text/PlanetName
@onready var selectionTimer				= $SelectionFlash


func setLockControls(lock:bool):
	lockControls = lock

func _ready():
	_renderPlanets()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !lockControls:
		if Input.is_action_just_pressed("right"):
			selectionTimer = 0
			selected = (selected + 1) % numPlanets
		if Input.is_action_just_pressed("left"):
			selectionTimer = 0
			selected = (selected - 1) % numPlanets
			if selected < 0:
				selected += numPlanets
		if Input.is_action_just_pressed("shot"):
			emit_signal("planetSelected", options[selected].index)
			hide()
				
		_updateUI()

func _selectRandomPlanets(num:int):
	var rng = RandomNumberGenerator.new()
	var indexAdded:Array[int] = []
	while options.size() < num:
		var rand = rng.randi_range(0, PlanetContainer.planets.size()-1)
		if !PlanetContainer.planets[rand].completed && !indexAdded.has(rand):
			indexAdded.append(rand)
			options.append(PlanetPos.new(PlanetContainer.planets[rand].planet, rand))

func _renderPlanets():
	_selectRandomPlanets(numPlanets)
	planetLeft.texture  = options[0].planet.planet_sprite
	planetRight.texture = options[1].planet.planet_sprite
	
func _updateUI():
	planetName.text = options[selected].planet.planet_name
	var index= 0
	while index < borders.size():
		if selected != index:
			borders[index].visible = false
		index+=1


func _on_selection_flash_timeout():
	borders[selected].visible = !borders[selected].visible

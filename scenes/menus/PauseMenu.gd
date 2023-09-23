extends CanvasLayer

signal resume_game
signal return_to_main_menu

const ARROW_SPEED 	= 10
var selected:int 	= 0
var optionsPositions:Array[Vector2] = [Vector2(47, 103), Vector2(36, 123)]
var previousPosition:Vector2 = Vector2(-1, -1)

# Escene elements
@onready var selectArrow	:= $SelectArrow
@onready var lerpTimer		:= $LerpTimer
@onready var planetImage	:= $PlanetImage
@onready var planetName 	:= $PlanetName
@onready var levelNumber	:= $LevelLabel/LevelNumber
@onready var coreImage		:= $CoreImage

func _ready():
	resetMenu()

func setPlanetTexture(tex:Texture2D):
	planetImage.texture = tex
	

func setPlanetName(pName:String):
	planetName.text = pName
	

func setLevel(number:int):
	levelNumber.text = str(number)
	

func setCoreCollected(collected:bool):
	if collected:
		coreImage.region_rect.position.x = 24
	else:
		coreImage.region_rect.position.x = 16

func _process(_delta):
	if previousPosition.x > -1 && previousPosition != optionsPositions[selected]:
		# Key pressed, moving arrow to the selected option
		selectArrow.position = previousPosition + (optionsPositions[selected] - previousPosition) * (1 - lerpTimer.time_left / lerpTimer.wait_time) 

	else:
		# Waitting for input
		if Input.is_action_just_pressed("down"):
			selected = (selected + 1) % 2
			updateStyle()
		if Input.is_action_just_pressed("up"):
			selected = (selected + 1) % 2
			updateStyle()
		if Input.is_action_just_pressed("shot"):
			optionSelected()
	
func updateStyle():
	previousPosition = selectArrow.position
	
	if previousPosition != optionsPositions[selected]:
		# Check direction to flip sprite
		selectArrow.flip_v = selectArrow.position.y > optionsPositions[selected].y
			
		# Start a timer for interpolation
		lerpTimer.start()
		
		# Play arrow animation
		selectArrow.play("turn")


func resetMenu():
	# Reset variables to default values
	previousPosition = Vector2(-1, -1)
	selected = 0
	
	# Move arrow to first option and start its animation
	selectArrow.position = optionsPositions[0]
	selectArrow.play("idle")
	

func optionSelected():
	if selected == 0:
		get_tree().paused = false
		resume_game.emit()
	elif selected == 1:
		get_tree().paused = false
		return_to_main_menu.emit()

func _on_lerp_timer_timeout():
	previousPosition = Vector2(-1, -1)
	selectArrow.play("idle")

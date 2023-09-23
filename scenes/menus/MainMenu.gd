extends Control

signal start_game
signal show_credits
signal show_controls

const ARROW_SPEED = 10
const STARS_INITIAL_FLICK_TIME = 2.0
var selected:int 	= 0
var optionsPositions:Array[Vector2] = [Vector2(53, 87), Vector2(40, 107), Vector2(48, 128)]
var previousPosition:Vector2 = Vector2(-1, -1)

# Escene elements
@onready var selectArrow	:= $SelectArrow
@onready var lerpTimer		:= $LerpTimer
@onready var selectSound	:= $SelectSound
@onready var moveSound		:= $MoveSound

func _ready():
	resetMenu()

func _process(_delta):
	if previousPosition.x > -1 && previousPosition != optionsPositions[selected]:
		# Key pressed, moving arrow to the selected option
		selectArrow.position = previousPosition + (optionsPositions[selected] - previousPosition) * (1 - lerpTimer.time_left / lerpTimer.wait_time) 

	else:
		# Waitting for input
		if Input.is_action_just_pressed("down"):
			moveSound.play()
			selected = (selected + 1) % 3
			updateStyle()
		elif Input.is_action_just_pressed("up"):
			moveSound.play()
			selected = (selected - 1) % 3
			if selected < 0:
				selected += 3
			updateStyle()
		elif Input.is_action_just_pressed("shot"):
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
	# Play sound
	selectSound.play()
	await selectSound.finished
	
	if selected == 0:
		start_game.emit()
	elif selected == 1:
		show_controls.emit()
	elif selected == 2:
		show_credits.emit()

func _on_lerp_timer_timeout():
	previousPosition = Vector2(-1, -1)
	selectArrow.play("idle")

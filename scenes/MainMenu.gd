extends Control

const ARROW_SPEED = 10
const MAX_WINDOW_INITIAL_SCALE = 4
const STARS_INITIAL_FLICK_TIME = 2.0
var selected:int 	= 0
var optionsPositions = [87, 107, 128]
var previousPosition:int = -1

# Escene elements
var selectArrow
var lerpTimer
var backgroundStars

func _ready():
	selectArrow 	= $SelectArrow
	lerpTimer		= $LerpTimer
	backgroundStars = $BackgroundStars
	
	resetMenu()
	updateWindowSize()

func _process(_delta):
	if previousPosition > -1 && previousPosition != optionsPositions[selected]:
		# Key pressed, moving arrow to the selected option
		selectArrow.position.y = previousPosition + (optionsPositions[selected] - previousPosition) * (1 - lerpTimer.time_left / lerpTimer.wait_time) 

	else:
		# Waitting for input
		if Input.is_action_just_pressed("down"):
			selected = (selected + 1) % 3
			updateStyle()
		if Input.is_action_just_pressed("up"):
			selected = (selected - 1) % 3
			updateStyle()
	
func updateStyle():
	previousPosition = selectArrow.position.y
	
	if previousPosition != optionsPositions[selected]:
		# Check direction to flip sprite
		selectArrow.flip_v = selectArrow.position.y > optionsPositions[selected]
			
		# Start a timer for interpolation
		lerpTimer.start()
		
		# Play arrow animation
		selectArrow.play("turn")
	


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


func resetMenu():
	# Reset variables to default values
	previousPosition = -1
	selected = 0
	
	# Move arrow to first option and start its animation
	selectArrow.position.y = optionsPositions[0]
	selectArrow.play("idle")
	
	# Play stars animation
	var stars = backgroundStars.get_children()
	var halfStars = (stars.size() / 2) - 1
	while not stars.is_empty():
		var star = stars.pop_back()
		if stars.size() >= halfStars:
			star.play("short")
		else:
			star.play("long")
		
		star.set_frame_and_progress(8, randf())
		

func _on_lerp_timer_timeout():
	previousPosition = -1
	selectArrow.play("idle")

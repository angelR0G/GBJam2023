extends Control

const STARS_INITIAL_FLICK_TIME = 2.0
var selected:int 	= 0

# Escene elements
var selectArrow
var creditsTimer
var backgroundStars
var labels

func _ready():
	selectArrow 	= $SelectArrow
	creditsTimer	= $CreditsTimer
	backgroundStars = $BackgroundStars
	labels			= $Credits.get_children()
	
	resetCredits()

func _process(_delta):
	if Input.is_action_just_pressed("shot"):
		exitCredits()


func updateCredits():
	var index:int = 0
	
	# Show one label
	while index < labels.size():
		labels[index].visible = selected == index
		index += 1
	


func resetCredits():
	# Reset variables to default values
	selected = 0
	updateCredits()
	
	# Start arrow animation
	selectArrow.play("idle")
	
	# Play stars animation
	var stars = backgroundStars.get_children()
	var halfStars = (stars.size() / 2)
	while not stars.is_empty():
		var star = stars.pop_back()
		if stars.size() >= halfStars:
			star.play("short")
		else:
			star.play("long")
		
		star.set_frame_and_progress(8, randf())
	

func exitCredits():
	pass


func _on_credits_timer_timeout():
	selected = (selected + 1) % labels.size()
	updateCredits()

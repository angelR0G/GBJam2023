extends Control

signal go_back

const STARS_INITIAL_FLICK_TIME = 2.0
var selected:int 	= 0

# Escene elements
var selectArrow
var creditsTimer
var labels
@onready var selectSound	:= $SelectSound

func _ready():
	selectArrow 	= $SelectArrow
	creditsTimer	= $CreditsTimer
	labels			= $Credits.get_children()
	
	resetCredits()

func _process(_delta):
	if Input.is_action_just_pressed("shot") || Input.is_action_just_pressed("menu"):
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
	

func exitCredits():
	# Play sound
	selectSound.play()
	await selectSound.finished
	
	go_back.emit()


func _on_credits_timer_timeout():
	selected = (selected + 1) % labels.size()
	updateCredits()

extends Control

const STARS_INITIAL_FLICK_TIME = 2.0
var showGB:bool 	= true

# Escene elements
var selectArrow
var controls

func _ready():
	selectArrow 	= $SelectArrow
	controls		= $Controls.get_children()
	
	resetControls()

func _process(_delta):
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
		showGB = not showGB
		updateControls()
		
	if Input.is_action_just_pressed("shot") || Input.is_action_just_pressed("menu"):
		exitControls()


func updateControls():
	# Show controls screen
	for node in controls[0].get_children():
		node.visible = showGB
	
	for node in controls[1].get_children():
		node.visible = not showGB
	


func resetControls():
	# Reset variables to default values
	showGB = true
	updateControls()
	
	# Start arrow animation
	selectArrow.play("idle")
	

func exitControls():
	pass

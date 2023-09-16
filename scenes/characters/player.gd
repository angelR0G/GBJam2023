class_name Player
extends CharacterBody2D

var shot_container = preload("res://scenes/shots/ShotContainer.gd")

# Movement values
var MAX_WALK_SPEED 	:int 	= 60
var SPEED 			:int 	= 400
var STOP_SPEED		:int 	= 300
var SPEED_DEADZONE	:float 	= 2.0

# Class variables
var linear_velocity :float = 0.0

func _process(delta):
	var dir := Vector2()
	
	# Check input to get character movement direction
	if Input.is_action_pressed("left"):
		dir.x -= 1.0
	if Input.is_action_pressed("right"):
		dir.x += 1.0
	if Input.is_action_pressed("up"):
		dir.y -= 1.0
	if Input.is_action_pressed("down"):
		dir.y += 1.0
	
	if dir.length() < 0.9:
		# No input movement, reduce velocity
		velocity -= velocity.normalized() * STOP_SPEED * delta
		if velocity.length() < SPEED_DEADZONE:
			velocity = Vector2()
	else :
		# Add input velocity
		linear_velocity = min(MAX_WALK_SPEED, linear_velocity + SPEED*delta)
		velocity = linear_velocity * dir.normalized()
	
	# Update player position
	move_and_slide()
	

func _unhandled_input(event):
	# Player shooting
	if event.is_action_pressed("shot"):
		if $ShotTimer.is_stopped():
			# Create a shot
			var shot = shot_container.create_shot()
			
			# Update its values
			shot.setShotDirection(velocity.angle())
			
			# Add it to the game
			add_child(shot)
			$ShotTimer.start()

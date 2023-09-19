class_name Player
extends CharacterBody2D

var shot_container = preload("res://scenes/shots/ShotContainer.gd")

# Movement values
var MAX_WALK_SPEED 	:int 	= 60
var SPEED 			:int 	= 400
var STOP_SPEED		:int 	= 300
var SPEED_DEADZONE	:float 	= 2.0

# Overheat values
var SHOT_HEAT		:int	= 1
var MAX_HEAT		:int	= 20
var COOL_LIMIT		:int	= 15
var COOL_INITIAL_TIME:float	= 2.0
var COOL_INTERVAL_TIME:float= 0.8

# Camera
var CAMERA_SPEED	:float	= 40.0
var MAX_CAMERA_OFFSET:float	= 20.0
var OFFSET_DEADZONE	:float	= 1.0

# Class variables
var linear_velocity :float 	= 0.0
var overheat		:int	= 0
var gun_overheated	:bool	= false
var playerWidth		:int	= 8
var playerHeight	:int	= 8
var shotDirection	:Vector2= Vector2(1, 0)
var lockMovement	:bool 	= false

func setLockMovement(lock:bool):
	lockMovement = lock

func _process(delta):
	var dir := Vector2()
	
	if !lockMovement:
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
			
		# Stop animation
		$AnimatedSprite2D.stop()
		
		# Reduce camera offset
		$Camera2D.offset -= $Camera2D.offset.normalized() * CAMERA_SPEED * delta
		if $Camera2D.offset.length() < OFFSET_DEADZONE:
			$Camera2D.offset = Vector2()
	else :
		# Add input velocity
		shotDirection = dir.normalized()
		linear_velocity = min(MAX_WALK_SPEED, linear_velocity + SPEED*delta)
		velocity = linear_velocity * shotDirection
		
		# Change animation depending on direction
		if abs(shotDirection.x) > 0.9:
			$AnimatedSprite2D.animation = "walk_right"
			$AnimatedSprite2D.flip_h = shotDirection.x < 0
		elif abs(shotDirection.y) > 0.9:
			$AnimatedSprite2D.flip_h = false
			if shotDirection.y > 0:
				$AnimatedSprite2D.animation = "walk_down"
			else:
				$AnimatedSprite2D.animation = "walk_up"
		$AnimatedSprite2D.play()
		
		# Update camera offset
		$Camera2D.offset += shotDirection * CAMERA_SPEED * delta
		if $Camera2D.offset.length() > MAX_CAMERA_OFFSET:
			$Camera2D.offset = $Camera2D.offset.normalized() * MAX_CAMERA_OFFSET
	
	# Update player position
	move_and_slide()
	

func _unhandled_input(event):
	# Player shooting
	if event.is_action_pressed("shot"):
		if $ShotTimer.is_stopped() && not gun_overheated:
			# Create a shot
			var shot = shot_container.create_shot()
			
			# Set shot initial position
			shot.position += velocity.normalized() * 16
			
			# Update its direction and prevent hitting player
			shot.setShotDirection(shotDirection.angle())
			shot.setHitPlayer(false)
			shot.setHitEnemies(true)
			
			# Add it to the game
			add_child(shot)
			
			# Gun fire rate
			$ShotTimer.start()
			
			# Gun overheats
			overheat += SHOT_HEAT
			if overheat >= MAX_HEAT:
				gun_overheated = true
			$CoolingTimer.start(COOL_INITIAL_TIME)

func gunCooling():
	# Gun reduces heat
	if overheat > 0:
		overheat -= 1
		
		# Enable shoting again when heat goes under COOL_LIMIT
		gun_overheated = gun_overheated && not (overheat < COOL_LIMIT)
		
		$CoolingTimer.start(COOL_INTERVAL_TIME)

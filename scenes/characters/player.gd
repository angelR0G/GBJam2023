class_name Player
extends CharacterBody2D

# Movement values
var MAX_WALK_SPEED 	:int 	= 60
var SPEED 			:int 	= 400
var STOP_SPEED		:int 	= 300
var SPEED_DEADZONE	:float 	= 2.0
var HIT_KNOCKBACK	:int	= 8

# Shot values
var SHOT_HEAT		:int	= 1
var MAX_HEAT		:int	= 20
var COOL_LIMIT		:int	= 15
var COOL_INITIAL_TIME:float	= 2.0
var COOL_INTERVAL_TIME:float= 0.8
var SHOT_SPEED		:int	= 200
var SHOT_BASE_DAMAGE:int	= 5

# Camera
var CAMERA_SPEED	:float	= 40.0
var MAX_CAMERA_OFFSET:float	= 20.0
var OFFSET_DEADZONE	:float	= 1.0

# Other
var INITIAL_LIFE	:int	= 10
var INVINCIBLE_TIME	:float	= 1.0

# Scene nodes
@onready var camera 		= $Camera2D
@onready var shotTimer		= $ShotTimer
@onready var coolingTimer	= $CoolingTimer
@onready var sprite			= $AnimatedSprite2D

# Class variables
var linear_velocity :float 	= 0.0
var overheat		:int	= 0
var gun_overheated	:bool	= false
var shotDirection	:Vector2= Vector2(1, 0)
var lockMovement	:bool 	= false
var life			:int	= INITIAL_LIFE
var canReceiveDamage:bool	= true

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
	
	if dir.length() < 0.5:
		# No input movement, reduce velocity
		velocity -= velocity.normalized() * STOP_SPEED * delta
		if velocity.length() < SPEED_DEADZONE:
			velocity = Vector2()
			
		# Stop animation
		sprite.stop()
		
		# Reduce camera offset
		camera.offset -= camera.offset.normalized() * CAMERA_SPEED * delta
		if camera.offset.length() < OFFSET_DEADZONE:
			camera.offset = Vector2()
	else :
		# Add input velocity
		shotDirection = dir.normalized()
		linear_velocity = min(MAX_WALK_SPEED, linear_velocity + SPEED*delta)
		velocity = linear_velocity * shotDirection
		
		# Change animation depending on direction
		if abs(shotDirection.x) > 0.9:
			sprite.animation = "walk_right"
			sprite.flip_h = shotDirection.x < 0
		elif abs(shotDirection.y) > 0.9:
			sprite.flip_h = false
			if shotDirection.y > 0:
				sprite.animation = "walk_down"
			else:
				sprite.animation = "walk_up"
		sprite.play()
		
		# Update camera offset
		camera.offset += shotDirection * CAMERA_SPEED * delta
		if camera.offset.length() > MAX_CAMERA_OFFSET:
			camera.offset = camera.offset.normalized() * MAX_CAMERA_OFFSET
	
	# Update player position
	move_and_collide(velocity*delta)
	

func _unhandled_input(event):
	# Player shooting
	if event.is_action_pressed("shot"):
		if shotTimer.is_stopped() && not gun_overheated:
			# Create a shot
			var shot = ShotContainer.create_shot()
			
			# Set shot initial position
			shot.position += velocity.normalized() * 16
			
			# Update its direction and prevent hitting player
			shot.setShotDirection(shotDirection.angle())
			shot.setVelocity()
			shot.setHitPlayer(false)
			shot.setHitEnemies(true)
			
			# Update shot damage
			shot.setDamage(SHOT_BASE_DAMAGE)
			
			# Add it to the game
			add_child(shot)
			
			# Gun fire rate
			shotTimer.start()
			
			# Gun overheats
			overheat += SHOT_HEAT
			if overheat >= MAX_HEAT:
				gun_overheated = true
			coolingTimer.start(COOL_INITIAL_TIME)

func gunCooling():
	# Gun reduces heat
	if overheat > 0:
		overheat -= 1
		
		# Enable shoting again when heat goes under COOL_LIMIT
		gun_overheated = gun_overheated && not (overheat < COOL_LIMIT)
		
		coolingTimer.start(COOL_INTERVAL_TIME)

func activateInvincibility(time:float = 1.0):
	# Prevent player from receiving damage
	canReceiveDamage = false
	
	# Prevent movement for a moment
	if not lockMovement:
		lockMovement = true
		velocity = Vector2()
		await get_tree().create_timer(0.5).timeout
		lockMovement = false
		
	# Wait the specified time
	await get_tree().create_timer(time).timeout
	
	# Activate damage again
	canReceiveDamage = true


func damage(dp:int = 1, pos:Vector2 = Vector2()):
	#Check if can receive damage
	if not canReceiveDamage:
		return
	
	# Reduce life
	life -= dp
	
	# Push player
	position += (global_position - pos).normalized() * HIT_KNOCKBACK
	
	# Prevent damage during a time
	activateInvincibility(INVINCIBLE_TIME)


func _on_enemy_detector_body_entered(body):
	if body is BasicEnemy:
		damage(1, body.global_position)


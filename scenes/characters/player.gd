class_name Player
extends CharacterBody2D

signal life_changed(newLife)
signal heat_changed(newHeat)
signal cool_capsule_collected
signal player_dead

# Movement values
var CORE_WALK_SPEED	:int	= 35
var NO_CORE_WALK_SPEED:int	= 60
var MAX_WALK_SPEED 	:int 	= 60
var SPEED 			:int 	= 400
var STOP_SPEED		:int 	= 300
var SPEED_DEADZONE	:float 	= 2.0
var HIT_KNOCKBACK	:int	= 12

# Shot values
var SHOT_HEAT		:int	= 1
var MAX_HEAT		:int	= 20
var SHOT_SPEED		:int	= 200
var SHOT_BASE_DAMAGE:int	= 5
var SHOT_CORE_DAMGE	:int	= 8
var SHOT_NORMAL_DAMAGE:int	= 5
var COOL_LIMIT		:int	= 15
var COOL_INITIAL_TIME		:float	= 2.0
var COOL_INTERVAL_TIME		:float	= 0.8
var CORE_COOL_INITIAL		:float	= 1.0
var CORE_COOL_INTERVAL		:float	= 0.3
var NO_CORE_COOL_INITIAL	:float	= 2.0
var NO_CORE_COOL_INTERVAL	:float	= 0.8

# Camera
var CAMERA_SPEED		:float	= 40.0
var MAX_CAMERA_OFFSET	:float	= 20.0
var OFFSET_DEADZONE		:float	= 1.0
var CAMERA_LIMIT_OFFSET	:int	= 6

# Other
var INITIAL_LIFE	:int	= 16
var INVINCIBLE_TIME	:float	= 1.0
var BLINK_TIME		:float	= 0.15

# Scene nodes
@onready var camera 		= $Camera2D
@onready var shotTimer		= $ShotTimer
@onready var coolingTimer	= $CoolingTimer
@onready var sprite			= $AnimatedSprite2D
@onready var hud			= $hud
@onready var shotSound		= $ShotSound
@onready var capsuleSound	= $CapsuleSound
@onready var hitSound		= $HitSound

# Class variables
var linear_velocity :float 	= 0.0
var overheat		:int	= 0
var gun_overheated	:bool	= false
var shotDirection	:Vector2= Vector2(1, 0)
var lockMovement	:bool 	= false
var life			:int	= INITIAL_LIFE
var canReceiveDamage:bool	= true
var enemiesBeingTouched:int	= 0
var blinkingElapsed	:float	= 0

func setLockMovement(lock:bool):
	lockMovement = lock

func setLockCamera(lock:bool):
	camera.enabled = !lock

func showHud(visibility:bool):
	hud.visible = visibility
	

func resetPlayer():
	overheat 			= 0
	canReceiveDamage 	= true
	enemiesBeingTouched = 0
	blinkingElapsed 	= 0
	SHOT_BASE_DAMAGE	= SHOT_NORMAL_DAMAGE
	camera.limit_left 	= -CAMERA_LIMIT_OFFSET
	camera.limit_top	= -CAMERA_LIMIT_OFFSET
	shotTimer.start()

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
	move_and_slide()
	
	# Blinking effect while invincible
	if not canReceiveDamage:
		blinkingElapsed += delta
		if blinkingElapsed >= BLINK_TIME:
			visible = not visible
			blinkingElapsed -= BLINK_TIME
		

func _unhandled_input(event):
	# Player shooting
	if not lockMovement && event.is_action_pressed("shot"):
		if shotTimer.is_stopped() && not gun_overheated:
			# Create a shot
			var shot = ShotContainer.create_shot()
			
			# Set shot initial position
			shot.position += shotDirection.normalized() * 16
			
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
			
			# Play sound
			shotSound.play()
			
			# Gun overheats
			overheat += SHOT_HEAT
			if overheat >= MAX_HEAT:
				gun_overheated = true
			coolingTimer.start(COOL_INITIAL_TIME)
			
			# Update heat bar in hud
			heat_changed.emit(overheat)

func gunCooling(coolPoints: int = 1):
	# Gun reduces heat
	if overheat > 0:
		overheat = max(overheat - max(coolPoints, 0), 0)
		
		# Update heat bar in hud
		heat_changed.emit(overheat)
		
		# Enable shoting again when heat goes under COOL_LIMIT
		gun_overheated = gun_overheated && not (overheat < COOL_LIMIT)
		
		coolingTimer.start(COOL_INTERVAL_TIME)

func activateInvincibility(time:float = 1.0):
	# Prevent player from receiving damage
	canReceiveDamage 	= false
	blinkingElapsed 	= 0
	
	# Prevent movement for a moment
	if not lockMovement:
		lockMovement = true
		velocity = Vector2()
		await get_tree().create_timer(0.5).timeout
		lockMovement = false
		
	# Wait the specified time
	await get_tree().create_timer(time).timeout
	
	visible = true
	
	# Activate damage again
	canReceiveDamage = true
	
	# Check if its colliding with enemies after invencibility
	if enemiesBeingTouched > 0:
		damage(1)

func toggleCoreStats(hasCore:bool):
	if hasCore:
		MAX_WALK_SPEED 		= CORE_WALK_SPEED
		COOL_INITIAL_TIME	= CORE_COOL_INITIAL
		COOL_INTERVAL_TIME	= CORE_COOL_INTERVAL
		SHOT_BASE_DAMAGE	= SHOT_CORE_DAMGE
	else:
		MAX_WALK_SPEED 		= NO_CORE_WALK_SPEED
		COOL_INITIAL_TIME	= NO_CORE_COOL_INITIAL
		COOL_INTERVAL_TIME 	= NO_CORE_COOL_INTERVAL
		SHOT_BASE_DAMAGE	= SHOT_NORMAL_DAMAGE
		
	

func updateCameraLimit(limits:Vector2):
	camera.limit_right 	= max(limits.x, 10) + CAMERA_LIMIT_OFFSET
	camera.limit_bottom = max(limits.y, 10) + CAMERA_LIMIT_OFFSET

func damage(dp:int = 1, pos:Vector2 = Vector2()):
	#Check if can receive damage
	if not canReceiveDamage:
		return
	
	# Play sound
	hitSound.play()
	
	# Reduce life
	life -= dp
	if life <= 0:
		player_dead.emit()
	else:
		# Update hud
		life_changed.emit(life)
		
		# Push player
		var knockback := (global_position - pos).normalized() * HIT_KNOCKBACK
		if not test_move(Transform2D(0, position), knockback):
			position += knockback
		
		# Prevent damage during a time
		activateInvincibility(INVINCIBLE_TIME)


func _on_objects_detector_body_entered(body):
	if body is BasicEnemy:
		enemiesBeingTouched += 1
		damage(1, body.global_position)
	elif body is Shot && body.get_collision_layer_value(6):
		damage(1, body.global_position)
		if body.has_method("destroyShot"):
			body.destroyShot()
		


func _on_objects_detector_body_exited(body):
	if body is BasicEnemy:
		enemiesBeingTouched -= 1


func _on_objects_detector_area_entered(area):
	if area.get_collision_layer_value(7):
		# Cooling capsule picked up
		gunCooling(MAX_HEAT)
		area.get_parent().queue_free()
		cool_capsule_collected.emit()
		
		# Play sound
		capsuleSound.play()

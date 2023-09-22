extends "res://scenes/characters/enemies/BasicEnemy.gd"

var RUN_TIME		:float	= 2.4
var RECOVER_TIME	:float 	= 5.0 
var RUN_SPEED		:float	= 45.0
var WALK_SPEED		:float	= 20.0
var ANGULAR_SPEED	:float	= PI
var SPRINT_DISTANCE	:float	= 65.0

var exhausted		:bool	= false
var currentSpeed	:float	= WALK_SPEED
var currentAngular	:float	= ANGULAR_SPEED

@onready var staminaTimer 	= $StaminaTimer
@onready var sprite			= $AnimatedSprite2D

func _ready():
	exhausted 		= false
	currentSpeed	= WALK_SPEED
	currentAngular	= ANGULAR_SPEED
	getPlayer()


func _process(delta):
	# Get player direction
	var targetVector:Vector2 = (player.global_position - global_position)
	var movDirection:Vector2 = targetVector.normalized()
	
	if enemyVelocity.length() < 1.0:
		# Move enemy towards player
		setEnemyVelocity(movDirection * currentSpeed)
	else:
		var currentAngle 	= enemyVelocity.angle()
		var targetAngle		= movDirection.angle()
		
		# Adjust enemy orientation
		setEnemyVelocity(Vector2.from_angle(lerp_angle(currentAngle, targetAngle, min(delta * ANGULAR_SPEED, 1.0))) * currentSpeed)
		
		if not exhausted:
			# If the player is close, enemy sprints
			if targetVector.length() <= SPRINT_DISTANCE:
				startSprint()
	updateAnimation()


func updateAnimation():
	# Check movement speed to change animation
	if abs(enemyVelocity.x) >= abs(enemyVelocity.y):
		# Flip sprite depending on direction
		if enemyVelocity.x >= 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		# Play animation
		sprite.play("right")
	else:
		# Play proper animation
		if enemyVelocity.y >= 0:
			sprite.play("down")
		else:
			sprite.play("up")

		sprite.flip_h = false
	

func startSprint():
	exhausted 		= true
	currentSpeed 	= RUN_SPEED
	currentAngular	= ANGULAR_SPEED * 2
	sprite.speed_scale = 3
	staminaTimer.start(RUN_TIME)

func stopSprint():
	currentSpeed 	= WALK_SPEED
	currentAngular 	= ANGULAR_SPEED
	sprite.speed_scale	= 1
	staminaTimer.stop()
	
	await get_tree().create_timer(RECOVER_TIME).timeout
	exhausted = false

func _on_body_entered(body):
	if body is Player:
		# Stop sprint
		stopSprint()

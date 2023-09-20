extends "res://scenes/characters/enemies/BasicEnemy.gd"

const EXIT_TIME		:float	= 2.8
const DIG_TIME		:float	= 3.6
const DIG_SPEED		:float	= 20.0
const ROTATION_SPEED:float	= PI
const ROTATION_TIME	:float	= 0.6

var changingState	:bool	= false
var underGround		:bool	= true
var turningTime		:float	= 0.0
var readyToShot		:bool	= true

@onready var digTimer		= $DigTimer
@onready var sprite			= $AnimatedSprite2D

func _ready():	
	digIn()
	digTimer.start(DIG_TIME)
	getPlayer()

func _process(delta):
	if changingState:
		return
	
	if underGround:
		# Move enemy when its underground
		if enemyVelocity.length() < 1.0:
			# Moves in a random direction
			setEnemyVelocity(Vector2(DIG_SPEED, 0).rotated(randf() * TAU))
		else:
			# Change direction randomly
			turningTime += delta
			if turningTime >= ROTATION_TIME:
				setEnemyVelocity(enemyVelocity.rotated((randf()-0.5) * ROTATION_SPEED * turningTime))
				turningTime -= ROTATION_TIME
	else:
		# When has been outside half of the time, shoots
		if readyToShot && digTimer.time_left <= digTimer.wait_time/2.0:
			shoot()
			readyToShot = false
	


func digOut():
	changingState = true
	
	# Stop enemy movement
	setEnemyVelocity()
	turningTime 	= 0.0
	
	# Play animation and wait
	sprite.play("out")
	await sprite.animation_finished
	
	# Modify state and colision
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_layer_value(5, true)
	underGround 	= false
	readyToShot		= true
	changingState	= false
	
	# Play animation
	sprite.play("idle")


func digIn():
	changingState = true
	
	# Play animation and wait
	sprite.play_backwards("out")
	await sprite.animation_finished
	
	# Modify state and colision
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_layer_value(5, false)
	underGround 	= true
	changingState	= false
	
	# Play animation
	sprite.play("dig")

func _on_dig_timer_timeout():
	if underGround:
		# Enemy get out and stay for a while
		digOut()
		digTimer.start(EXIT_TIME)
	else:
		# Enemy get inside
		digIn()
		digTimer.start(3.6)
	

func _on_body_entered(_body):
	setEnemyVelocity(-enemyVelocity)


func shoot():
	# Create a shot
	var shot = ShotContainer.create_shot(1)
	
	# Get player direction to shoot them
	var dir = player.position - position
	shot.setVelocity()
	shot.setShotDirection(dir.angle())
	
	# Set shot initial position
	shot.position += dir.normalized() * 4
	
	# Add it to the game
	add_child(shot)

extends "res://scenes/characters/enemies/BasicEnemy.gd"

const EXIT_TIME		:float	= 2.8
const DIG_TIME		:float	= 3.6
const DIG_SPEED		:float	= 20.0
const ROTATION_SPEED:float	= PI
const ROTATION_TIME	:float	= 0.6

var changingState	:bool	= false
var underGround		:bool	= true
var turningTime		:float	= 0.0

func _ready():
	$AnimatedSprite2D.play("dig")
	$DigTimer.start(DIG_TIME)

func _process(delta):
	if changingState || not underGround:
		return
	
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
	


func digOut():
	changingState = true
	
	# Stop enemy movement
	setEnemyVelocity()
	turningTime 	= 0.0
	
	# Play animation and wait
	$AnimatedSprite2D.play("out")
	await $AnimatedSprite2D.animation_finished
	
	# Modify state and colision
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_layer_value(5, true)
	underGround 	= false
	changingState	= false
	
	# Play animation
	$AnimatedSprite2D.play("idle")


func digIn():
	changingState = true
	
	# Play animation and wait
	$AnimatedSprite2D.play_backwards("out")
	await $AnimatedSprite2D.animation_finished
	
	# Modify state and colision
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_layer_value(5, false)
	underGround 	= true
	changingState	= false
	
	# Play animation
	$AnimatedSprite2D.play("dig")

func _on_dig_timer_timeout():
	if underGround:
		# Enemy get out and stay for a while
		digOut()
		$DigTimer.start(EXIT_TIME)
	else:
		# Enemy get inside
		digIn()
		$DigTimer.start(3.6)
	

func _on_body_entered(_body):
	setEnemyVelocity(-enemyVelocity)

extends "res://scenes/characters/enemies/BasicEnemy.gd"

var REST_TIME		:float	= 2.4
var MAX_CHARGE		:float	= 1.2
var MIN_CHARGE		:float	= 0.7
var CHARGE_SPEED	:int	= 120

var resting		:bool	= true

@onready var chargeTimer 	= $ChargeTimer
@onready var sprite			= $AnimatedSprite2D
@onready var collider		= $CollisionShape2D

func _ready():
	chargeTimer.start(REST_TIME)


func _on_charge_timer_timeout():
	if resting:
		var validDirection = true
		var tries = 5
		
		while validDirection && tries > 0:
			# Start moving in a random direction along axis during a random time
			setEnemyVelocity(Vector2(CHARGE_SPEED, 0).rotated(randi()%4 * PI/2))
			chargeTimer.start(randf_range(MIN_CHARGE, MAX_CHARGE))
			validDirection = test_move(transform, enemyVelocity * 0.1)
			
			# Prevent infinite loops
			tries -= 1
			
		updateAnimation()
	else:
		# Stop moving for a while
		setEnemyVelocity()
		sprite.stop()
		chargeTimer.start(REST_TIME)
		
	resting = not resting

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
		
	updateCollider()

func updateCollider():
	if sprite.animation == "right":
		collider.shape.size = Vector2(16, 6)
	else:
		collider.shape.size = Vector2(6, 17)


func _on_body_entered(body):
	if body is Shot:
		return
		
	# Go back and stop movement
	setEnemyVelocity()
	
	# Stop charge after hitting something
	chargeTimer.stop()
	chargeTimer.emit_signal("timeout")

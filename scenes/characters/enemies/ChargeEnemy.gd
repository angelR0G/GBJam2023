extends "res://scenes/characters/enemies/BasicEnemy.gd"

const REST_TIME		:float	= 2.4
const MAX_CHARGE	:float	= 1.2
const MIN_CHARGE	:float	= 0.7
const CHARGE_SPEED	:int	= 120

var resting		:bool	= true

@onready var chargeTimer = $ChargeTimer


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
	else:
		# Stop moving for a while
		setEnemyVelocity()
		chargeTimer.start(REST_TIME)
		
	resting = not resting


func _on_body_entered(body):
	if body is Shot:
		return
		
	# Go back and stop movement
	setEnemyVelocity()
	
	# Stop charge after hitting something
	chargeTimer.stop()
	chargeTimer.emit_signal("timeout")

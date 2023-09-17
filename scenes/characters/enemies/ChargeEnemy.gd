extends "res://scenes/characters/enemies/BasicEnemy.gd"

const REST_TIME		:float	= 2.4
const MAX_CHARGE	:float	= 1.2
const MIN_CHARGE	:float	= 0.7
const CHARGE_SPEED	:int	= 120

var resting		:bool	= true

func _ready():
	$ChargeTimer.start(REST_TIME)

func _on_charge_timer_timeout():
	if resting:
		# Start moving in a random direction along axis during a random time
		linear_velocity = Vector2(CHARGE_SPEED, 0).rotated(randi()%4 * PI/2)
		$ChargeTimer.start(randf_range(MIN_CHARGE, MAX_CHARGE))
	else:
		# Stop moving for a while
		linear_velocity = Vector2()
		$ChargeTimer.start(REST_TIME)
		
	resting = not resting


func _on_body_entered(_body):
	if $ChargeTimer.time_left >= MIN_CHARGE:
		# Hit something without moving hardly anything
		resting = true
		
	# Stop charge after hitting something
	$ChargeTimer.stop()
	$ChargeTimer.emit_signal("timeout")

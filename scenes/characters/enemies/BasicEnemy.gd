extends RigidBody2D

var life			:int	= 20
var enemyVelocity	:Vector2= Vector2()

func _integrate_forces(state):
	angular_velocity = 0
	linear_velocity = enemyVelocity

func setEnemyVelocity(vel:Vector2 = Vector2()):
	enemyVelocity = vel
	linear_velocity = vel

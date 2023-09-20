extends RigidBody2D

static var player	:Node	= null
var life			:int	= 20
var enemyVelocity	:Vector2= Vector2()

func getPlayer():
	var playerRef = get_tree().get_root().find_child("*Player*", true, false)
	if player == null:
		player = playerRef
	elif playerRef != null:
		player = playerRef

func _integrate_forces(_state):
	angular_velocity = 0
	linear_velocity = enemyVelocity

func setEnemyVelocity(vel:Vector2 = Vector2()):
	enemyVelocity = vel
	linear_velocity = vel

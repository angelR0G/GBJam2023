class_name BasicEnemy
extends RigidBody2D

signal enemyDead

static var player	:Node	= null
var life			:int	= 20
var enemyVelocity	:Vector2= Vector2()

@onready var deathSound = $DeathSound
@onready var hitSound 	= $HitSound

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

func damage(dp:int):
	life -= dp

	# If life reaches 0, destroy enemy
	if life <= 0:
		emit_signal("enemyDead")
		
		# Hide enemy and play death sound
		hide()
		deathSound.play()
		await deathSound.finished
		
		queue_free()
	else:
		# Play hit sound
		hitSound.play()

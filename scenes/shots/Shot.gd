class_name Shot
extends RigidBody2D

static var SHOT_SPEED:float = 200.0

func _init():
	linear_velocity = Vector2(SHOT_SPEED, 0)
	
func setHitPlayer(hit:bool):
	set_collision_layer_value(6, hit)
	set_collision_mask_value(1, hit)
	
func setHitEnemies(hit:bool):
	set_collision_layer_value(2, hit)
	set_collision_mask_value(5, hit)

func setVelocity(vel:float):
	linear_velocity = linear_velocity.normalized() * vel

func setShotDirection(rot:float):
	rotation = rot
	linear_velocity = Vector2(linear_velocity.length(), 0).rotated(rot)

func destroyShot():
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()

func _on_body_entered(_body):
	destroyShot()

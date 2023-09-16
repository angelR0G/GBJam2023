class_name Shot
extends RigidBody2D

static var SHOT_SPEED:float = 200.0

func _init():
	linear_velocity = Vector2(SHOT_SPEED, 0)

func setVelocity(vel:float):
	linear_velocity = linear_velocity.normalized() * vel

func setShotDirection(rot:float):
	rotation = rot
	linear_velocity = Vector2(linear_velocity.length(), 0).rotated(rot)

func _on_visible_on_screen_notifier_2d_screen_exited():
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()

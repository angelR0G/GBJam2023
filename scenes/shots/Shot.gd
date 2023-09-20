class_name Shot
extends RigidBody2D

@export var SHOT_SPEED	:float	= 200.0
@export var SHOT_DAMAGE	:int	= 1
 
@onready var sprite 	= $AnimatedSprite2D
@onready var collision	= $CollisionShape2D

func _init():
	linear_velocity = Vector2(SHOT_SPEED, 0)
	

func _ready():
	sprite.play("idle")

func setHitPlayer(hit:bool):
	set_collision_layer_value(6, hit)
	set_collision_mask_value(1, hit)
	
func setHitEnemies(hit:bool):
	set_collision_layer_value(2, hit)
	set_collision_mask_value(5, hit)

func setVelocity(vel:float = SHOT_SPEED):
	linear_velocity = linear_velocity.normalized() * vel

func setShotDirection(rot:float):
	rotation = rot
	linear_velocity = Vector2(linear_velocity.length(), 0).rotated(rot)

func setDamage(dp:int):
	SHOT_DAMAGE = dp

func destroyShot():
	collision.set_deferred("disabled", true)
	queue_free()

func _on_body_entered(body):
	# Check if collided body can receive damage
	if body.has_method("damage"):
		if body is Player:
			body.damage(SHOT_DAMAGE, global_position)
		else:
			body.damage(SHOT_DAMAGE)
		
	# Destroy the projectil
	destroyShot()

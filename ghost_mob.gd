extends Node2D

onready var tween = get_node("Tween")
var left = true
var velocity = Vector2(0,0)
var speed = 10000
var direction = 1
var Floor = Vector2(0,-1)

func _ready():
	walk()

func walk():
	if left:
		tween.interpolate_property($mob, "rotation_degrees", $mob.rotation_degrees,  -20, 0.5,Tween.TRANS_LINEAR, Tween.EASE_IN)
		left = not left
	else:
		tween.interpolate_property($mob, "rotation_degrees", $mob.rotation_degrees,  20, 0.5,Tween.TRANS_LINEAR, Tween.EASE_IN)
		left = not left
	tween.start()

func _on_Tween_tween_completed(object, key):
	walk()

func _process(delta):
	velocity.x = speed * direction * delta 
	$mob.move_and_slide(velocity, Floor)
	
	if direction == 1:
		$mob/AnimatedSprite.flip_h = true
	else:
		$mob/AnimatedSprite.flip_h = false
		
	if $mob.is_on_wall():
		direction *= -1

#hitbox entered by damage source
func _on_Area2D_body_entered(body):
	if "bloo" in body.name:
		pass
		#queue_free()

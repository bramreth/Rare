extends Node2D

var velocity = Vector2(0,0)
var speed = Vector2(30000,1)
var GRAVITY_VECTOR = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

onready var body = get_node("KinematicBody2D")

enum state{
		IDLE,
		FALL,
		RUN
}
var current_state = state.IDLE

"""
todo: add gain and lose momentum animations, basic attack, extra frames in existing anims
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delta > 0:
		print(velocity)
		velocity.x = 0
		match current_state:
			state.FALL:
				$KinematicBody2D/AnimatedSprite.stop()
				if Input.is_action_pressed("move_left"):
					if velocity.x > -0.5:
						velocity.x -= 0.5
						$KinematicBody2D/AnimatedSprite.flip_h = true
				if Input.is_action_pressed("move_right"):
					if velocity.x < 0.5:
						velocity.x += 0.5
						$KinematicBody2D/AnimatedSprite.flip_h = false
			state.IDLE:
				
				if Input.is_action_pressed("move_left"):
					if velocity.x > -1:
						velocity.x -= 1
						$KinematicBody2D/AnimatedSprite.flip_h = true
				if Input.is_action_pressed("move_right"):
					if velocity.x < 1:
						velocity.x += 1
						$KinematicBody2D/AnimatedSprite.flip_h = false
				if Input.is_action_pressed("jump"):
					velocity.y = -50000
					current_state = state.FALL
				
		#if jump is released cut the jump short
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y = 0
		var tmp = Vector2()
		if velocity.x:
			$KinematicBody2D/AnimatedSprite.play("run")
		else:
			$KinematicBody2D/AnimatedSprite.play("idle")
		match current_state:
			state.FALL:
				tmp = body.move_and_slide(velocity* delta * speed, GRAVITY_VECTOR)
			state.IDLE:
				tmp = body.move_and_slide_with_snap(velocity * delta *speed, GRAVITY_VECTOR, Vector2(0, 32))
		
		#
		if $KinematicBody2D/ground_detection.is_colliding():
			velocity.y = 0
			current_state = state.IDLE
		else:
			current_state = state.FALL
			velocity.y += GRAVITY
		
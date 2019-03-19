extends Node2D

var velocity = Vector2(0,0)
onready var body = get_node("KinematicBody2D")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delta > 0:
		print(velocity)
		velocity.x = 0
		if Input.is_action_pressed("move_left"):
			if velocity.x > -1:
				velocity.x -= 1
				$KinematicBody2D/Sprite.flip_h = true
		if Input.is_action_pressed("move_right"):
			if velocity.x < 1:
				velocity.x += 1
				
				$KinematicBody2D/Sprite.flip_h = false
		if Input.is_action_pressed("jump") and velocity.y == 0:
			velocity.y = -30000
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity")
		var speed = Vector2(20000,1)
		#var tmp = body.move_and_slide_with_snap(velocity * delta *speed, ProjectSettings.get_setting("physics/2d/default_gravity_vector"), Vector2(0, 32))
		var tmp = body.move_and_slide(velocity* delta * speed, ProjectSettings.get_setting("physics/2d/default_gravity_vector"))
		if tmp.y == 0:
			 velocity.y = 0
		
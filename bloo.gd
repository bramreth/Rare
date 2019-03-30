extends Node2D

var velocity = Vector2(0,0)
var speed = Vector2(50000,1)
var GRAVITY_VECTOR = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var acorns = 0

onready var body = get_node("bloo")

enum state{
		IDLE,
		FALL,
		RUN,
		PUNCH
}
var current_state = state.IDLE


onready var collectibles = get_tree().get_nodes_in_group("collectible")
"""
todo: add gain and lose momentum animations, basic attack, extra frames in existing anims, probably a walk versus run
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in collectibles:
		item.connect("collected", self, "pickup_collectible")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delta > 0:
		#print(velocity)
		velocity.x = 0
		match current_state:
			state.FALL:
				#$KinematicBody2D/AnimatedSprite.stop()
				if Input.is_action_pressed("move_left"):
					if velocity.x > -0.5:
						velocity.x -= 0.5
						$bloo/AnimatedSprite.flip_h = true
				if Input.is_action_pressed("move_right"):
					if velocity.x < 0.5:
						velocity.x += 0.5
						$bloo/AnimatedSprite.flip_h = false
			state.IDLE:
				if Input.is_action_just_pressed("punch"):
					current_state = state.PUNCH
					$bloo/AnimatedSprite.play("punch")
				if Input.is_action_pressed("move_left"):
					if velocity.x > -1:
						velocity.x -= 1
						$bloo/AnimatedSprite.flip_h = true
				if Input.is_action_pressed("move_right"):
					if velocity.x < 1:
						velocity.x += 1
						$bloo/AnimatedSprite.flip_h = false
				if Input.is_action_pressed("jump"):
					$bloo/AnimatedSprite.play("jump")
					velocity.y = -60000
					current_state = state.FALL
				
		#if jump is released cut the jump short
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y = 0
		var tmp = Vector2()
		if not (current_state == state.FALL or $bloo/AnimatedSprite.animation == "fall"
		or $bloo/AnimatedSprite.animation == "punch"):
			if velocity.x:
				$bloo/AnimatedSprite.play("run")
			else:
				$bloo/AnimatedSprite.play("idle")
		match current_state:
			state.FALL:
				tmp = body.move_and_slide(velocity* delta * speed, GRAVITY_VECTOR)
			state.IDLE:
				tmp = body.move_and_slide_with_snap(velocity * delta *speed, GRAVITY_VECTOR, Vector2(0, 32))
		
		#print($KinematicBody2D/AnimatedSprite.animation)
		if $bloo/ground_detection.is_colliding():
			if current_state == state.FALL:
				velocity.y = 0
				current_state = state.IDLE
				$bloo/AnimatedSprite.play("fall")
		else:
			current_state = state.FALL
			velocity.y += GRAVITY
		

func _on_AnimatedSprite_animation_finished():
	if $bloo/AnimatedSprite.animation == "fall" or $bloo/AnimatedSprite.animation == "punch":
		current_state = state.IDLE
		$bloo/AnimatedSprite.play("idle")

func pickup_collectible(id):
	print(id)
	print(id.name)
	acorns += 1
	$bloo/Camera2D/CanvasLayer/ui/Label.text = str(acorns)
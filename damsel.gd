extends Node2D

var velocity = Vector2(0,0)
export (int) var MAX_SPEED = 1000
var GRAVITY_VECTOR = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
export (float) var drag = 0.05
var acorns = 0
export (int) var MAX_HEALTH = 100
export (int) var JUMP_HEIGHT = 1000
export (int) var acceleration = 100
export (int) var deccelatation = 400
var current_health = 0
var direction = 0
onready var body = get_node("bloo")

var punch_stream = preload("res://assets/punch.wav")
var hit_stream = preload("res://assets/hit.wav")

enum state{
		IDLE,
		FALL,
		RUN,
		ATTACK,
		DEAD
}
var current_state = state.IDLE


onready var collectibles = get_tree().get_nodes_in_group("collectible")
onready var enemies = get_tree().get_nodes_in_group("enemy")
"""
todo: add gain and lose momentum animations, basic attack, extra frames in existing anims, probably a walk versus run
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in collectibles:
		item.connect("collected", self, "pickup_collectible")
		
	current_health = MAX_HEALTH
	
func get_direction():
	direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if direction == 0:
		#direction unchanged
		pass
	elif direction < 0:
		$bloo/atk_anim.scale.x = -0.3
		$bloo/atk_anim.position.x = -abs($bloo/atk_anim.position.x)
		$bloo/CollisionShape2D.scale.x = -1
	else:
		$bloo/atk_anim.scale.x = 0.3
		$bloo/atk_anim.position.x = abs($bloo/atk_anim.position.x)
		$bloo/CollisionShape2D.scale.x = 1
	return direction
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	direction = 0
	
	match current_state:
		state.FALL:
			direction = get_direction()
			#if jump is released cut the jump short
			if Input.is_action_just_released("jump") and velocity.y < 0:
				velocity.y *= 0.2
				#velocity.x -=sign(velocity.x) * MAX_SPEED * drag
			velocity.y += GRAVITY
			if $bloo/ground_detection.is_colliding():
				current_state = state.IDLE
			
		state.IDLE:
			direction = get_direction()
			if Input.is_action_just_pressed("punch"):
				current_state = state.ATTACK
				$bloo/atk_anim.punch()
			if Input.is_action_just_pressed("kick"):
				current_state = state.ATTACK
				$bloo/atk_anim.kick()
			if Input.is_action_pressed("jump"):
#					#play a jump anim
				velocity.y = -JUMP_HEIGHT
				current_state = state.FALL
				
		state.ATTACK:
			if Input.is_action_just_pressed("punch"):
				current_state = state.ATTACK
				$bloo/atk_anim.punch()
			if Input.is_action_just_pressed("kick"):
				current_state = state.ATTACK
				$bloo/atk_anim.kick()
			
		state.DEAD:
			return
			
	if not (current_state == state.FALL):
		# or attacking
		if velocity.x:
			current_state == state.RUN
			#run anim
		else:
			#idle naim
			current_state == state.IDLE
			
	handle_physics(direction)
	
	match current_state:
		state.FALL:
			velocity = body.move_and_slide(velocity, GRAVITY_VECTOR)
		_:
			velocity = body.move_and_slide_with_snap(velocity, GRAVITY_VECTOR, Vector2(0, 32))
			
	if not $bloo/ground_detection.is_colliding():
		current_state = state.FALL

"""
this is where all the logic for the momentum occurs.

i worry that this implementation ties game speed to the framerate
"""
func handle_physics(direction):
	if abs(velocity.x) < MAX_SPEED:
		
		if sign(direction) == sign(velocity.x):
			velocity.x += direction * acceleration
		else:
			velocity.x += direction * deccelatation
	#drag
	if abs(velocity.x) < drag:
		velocity.x = 0
	else:
		velocity.x -= sign(velocity.x) * drag
	
	if not direction:
		velocity.x *= 0.8
	print(direction)

func pickup_collectible(id):
	print(id)
	print(id.name)
	acorns += 1
	$bloo/Camera2D/CanvasLayer/ui/Label.text = str(acorns)

func take_damage(val):
	$bloo/AudioStreamPlayer2D.set_stream(hit_stream)
	$bloo/AudioStreamPlayer2D.play()
	current_health -= val
	$bloo/Camera2D/CanvasLayer/ui/health_bar/health_tween.interpolate_property($bloo/Camera2D/CanvasLayer/ui/health_bar, "value", $bloo/Camera2D/CanvasLayer/ui/health_bar.value, current_health, 0.1, Tween.TRANS_BACK, Tween.EASE_IN) 
		
	$bloo/Camera2D/CanvasLayer/ui/health_bar/health_tween.start()
	print(current_health)
	if current_health <= 0:
		death()
	else:
		$bloo/Camera2D/CanvasLayer/ui/health_bar.value = current_health


func _on_attack_body_entered(body):
	print(body.name)
	if "mob" in body.name:
		body.take_damage(25)
		
func death():
	print("you lose")
	current_state = state.DEAD
#	$bloo/AnimatedSprite.animation = "die"
# play death animation
	$bloo/Camera2D/CanvasLayer/transition_screen/filter/AnimationPlayer.play("game_over")

func _on_atk_anim_end_of_chain():
	current_state = state.IDLE
	print($bloo/CollisionShape2D.position)
	$bloo.position.x = $bloo/CollisionShape2D.position.x
	$bloo/CollisionShape2D.position = Vector2(0, 17.5)
	$bloo/CollisionShape2D.shape.extents = Vector2(25, 100)
	
	
"""
there are some fundamental problems with teh animation system that need resolving:
	I need to move bloo instead of the collision body as at the end of the animation teh position resets to the start point
	flipping left doesn't work for the collision body as it still moves right even when the animation is going left
	gravity is ignored during animations

"""



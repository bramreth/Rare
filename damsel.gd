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
	else:
		$bloo/atk_anim.scale.x = 0.3
		$bloo/atk_anim.position.x = abs($bloo/atk_anim.position.x)
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
	
"""
a lot of guts need to be ripped out here if I'm going to make this work.

I need to create an input queue for attacks

this needs to be handled before I focus too much on animations.
step 1, poll attack inputs.
this is going to be a finite state machine I am going to need to map out.
so let's think about my attacks:
	x = punch
	y = kick
	
my first chain will be punch kick punch

after punch store it in a list of the current chain.
when the animation times out empty the chain
if another input is recieved and it is a valid transition, queue it.

then when the current animation finishes play that animation 

it would be nice to figure out pre-emptively starting the next attack if it is safe
(within safety bounds of the previous attack)

for each phase I need to predefine attack checks. 
let's use raycasts for each

setup raycast in antmation, check if there is a first colliusion with an enemy? and send
 off a hit signal with the damage for that part of the combo

bitterblossom = [punch, kick, punch]
chain = []
current_index
if input = x:
	chain.append(punch)
elif input = y:
	chain.append(kick)
	
if chain invalid:
	curent_index +=1
	if chain.len() >= current_index
		play_anim(chain, current_index)
	else
		chain.empty
		current_index = 0
	
spritesheet.timeout:
	chain.empty()
	
check_chain(chain_in):
	return chain_in in chain_list [[p],[p,k],[p,k,p]]
	
play_anim(chain, current_index)
	lookup the animation to play for this part, lots of these willneed hardcoding as the position the player...

"""



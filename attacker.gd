extends Node2D

"""
the attacking handler, this contains a finite state machine for combos
the current combo handler, listener and cleaner.

this is clunky but it works. this needs disseminating, tidying
and for mne to figure out a better way of storing which anim needs to play next
as well as displaying when an input can be made.
"""
enum attack{
	PUNCH,
	KICK
}
var chain = []
var banked_chain = []
var chain_progress = []
var lock = false
var slash = [attack.PUNCH]
var peck = [attack.PUNCH, attack.KICK]
var bitterblossom = [attack.PUNCH, attack.KICK, attack.PUNCH]
var combo_list = [slash, peck, bitterblossom]
var anim_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_dict[slash] = "atk1_1"
	anim_dict[peck] = "atk1_2_2"
	anim_dict[bitterblossom] = "atk1_3_2"

func validate_chain(attack_in):
	chain.append(attack_in)
	if chain in combo_list:
		print(chain)
		banked_chain = [] + chain
		chain_progress.append(chain)
		print("chain in combo_list", chain)
		if not $attack_sprites/ATK_PLAYER.is_playing():
			play_anim_in_queue()
			
		return true
	elif [attack_in] in combo_list:
		chain = [attack_in]
		banked_chain = [] + chain
		chain_progress = [chain]
		print("chain in combo_list", chain)
		if not $attack_sprites/ATK_PLAYER.is_playing():
			play_anim_in_queue()
			
		return true
	else:
		print("chain not in combo list", chain)
#		if $attack_sprites/ATK_PLAYER.is_playing():
#			lock = true
		chain.pop_back()
		return false
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if Input.is_action_just_pressed("punch") and not lock:
		validate_chain(attack.PUNCH)
	if Input.is_action_just_pressed("kick") and not lock:
		validate_chain(attack.KICK)
		


func _animation_finished(anim_name):
#	print(anim_name)
	print("playing", banked_chain, chain_progress)
#	print(chain_progress, len(banked_chain))
	if len(chain_progress) >= 0:
		lock = false
		print("start sympathy")
		$sympathy_timer.start()
	else:
		# if we reach a combo finisher we wan't to ignore the sympathy
#		print(anim_dict[chain_progress])
		#play the rest of the chain
		
		play_anim_in_queue()
		
func play_anim_in_queue():
	print("anim prog", chain_progress)
	if chain_progress:
		$attack_sprites/ATK_PLAYER.play(anim_dict[chain_progress.pop_front()])
		$sympathy_timer.stop()

# you have officially run out of combo time
func _on_sympathy_timer_timeout():
	print("timeout", banked_chain)
	# don't empty if an input was received
	#reset visibliity (as can be unhandled by anim player)
	if $attack_sprites.visible:
		$attack_sprites.visible = false
	if not $rest.visible:
		$rest.visible = true
	chain_progress = []
	banked_chain = []
	chain = []
	
	"""
	major issue, currently only plays the next animation if in the timer, this needs to be fixed asap
	
	"""

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
var slash = [attack.PUNCH]
var peck = [attack.PUNCH, attack.KICK]
var bitterblossom = [attack.PUNCH, attack.KICK, attack.PUNCH]
var combo_list = [slash, peck, bitterblossom]
var anim_dict = {}
var finisher_list = ["atk1_3_2"]

signal end_of_chain()

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
		chain_progress.append(banked_chain)
		print("chain in combo_list", chain)
		if not $attack_sprites/ATK_PLAYER.is_playing():
			play_anim_in_queue()
			
		return true
#	elif [attack_in] in combo_list:
#		chain = [attack_in]
#		banked_chain = [] + chain
#		chain_progress = [chain]
#		print("chain in combo_list", chain)
#		if not $attack_sprites/ATK_PLAYER.is_playing():
#			play_anim_in_queue()
#
#		return true
	else:
		print("chain not in combo list", chain)
#		if $attack_sprites/ATK_PLAYER.is_playing():
		chain.pop_back()
		return false
		


func _animation_finished(anim_name):
	if len(chain_progress) == 0:
		if anim_name in finisher_list:
			#then we are handling a finisher - cleanup
			cleanup()
		else:
			# we are in a chain, give some sympathy time
			$sympathy_timer.start()
	else:
		#there is something in the anim queue that needs playing
		play_anim_in_queue()
		
func play_anim_in_queue():
	if chain_progress:
		$attack_sprites/ATK_PLAYER.play(anim_dict[chain_progress.pop_front()])
		
		$sympathy_timer.stop()

# you have officially run out of combo time
func _on_sympathy_timer_timeout():
	cleanup()
	
func cleanup():
	if $attack_sprites.visible:
		$attack_sprites.visible = false
	if not $rest.visible:
		$rest.visible = true
	chain_progress = []
	banked_chain = []
	chain = []
	emit_signal("end_of_chain")
	

func punch():
	validate_chain(attack.PUNCH)
	
func kick():
	validate_chain(attack.KICK)

#func _on_Area2D_area_entered(area):
#	if "mob" in area.name:
#		print("hot!", area.name)

func _on_Area2D_body_entered(body):
	if "mob" in body.name:
		# the enemy has been hit
		body.take_damage(25)
		print("hit!", body.name)
	

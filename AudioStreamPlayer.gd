extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_volume(volume):
	self.volume_db = volume


func _on_options_change_effects_volume(volume):
	pass # Replace with function body.

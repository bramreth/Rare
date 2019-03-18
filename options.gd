extends Control

onready var tween = get_node("Tween")
signal play_highlight()
signal play_select()
signal back()
signal change_volume(volume)
signal change_effects_volume(volume)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func make_visible():
	self.visible = true
	
	for child in $options_container.get_children():
		child.visible = true
	"""
		tween.interpolate_property(child, "rect_scale", Vector2(child.rect_scale.x,0),  child.rect_scale, 0.3,Tween.TRANS_BACK, Tween.EASE_IN)
		tween.start()
		emit_signal("play_highlight")
		yield(tween, "tween_completed")
	"""



func _back_button():
	emit_signal("play_select")
	var i = $options_container.get_child_count()-1
	while i >= 0:
		tween.interpolate_property($options_container.get_child(i), "rect_scale", $options_container.get_child(i).rect_scale,  Vector2($options_container.get_child(i).rect_scale.x,0), 0.3,Tween.TRANS_BACK, Tween.EASE_IN)
		tween.start()
		i -= 1
		yield(tween, "tween_completed")
		emit_signal("play_highlight")
	
	for child in $options_container.get_children():
		child.visible = false
	emit_signal("back")


func _on_music_slider_value_changed(value):
	emit_signal("change_volume", value)


func _on_effects_slider_value_changed(value):
	emit_signal("change_effects_volume", value)

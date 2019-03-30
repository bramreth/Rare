extends Area2D

signal collected(id)
var picked_up = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")


func _on_Node2D_body_entered(body):
	if "bloo" in body.name and not picked_up:
		emit_signal("collected", self)
		$AnimationPlayer.play("pickup")
		picked_up = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if "pickup" in anim_name:
		self.queue_free()

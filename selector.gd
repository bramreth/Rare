extends Sprite

onready var tween = get_node("Tween")
var in_use = false

func _ready():
	$AnimationPlayer.play("idle")
	
func silent_move(target):
	var target_loc = target.rect_position
	target_loc.x -= 20
	self.position = target_loc
	
	reset()
	
func update_select(target):
	if in_use:
		return
	target.grab_focus()
	
		
	var target_loc = target.rect_position
	target_loc.x -= 20
	tween.interpolate_property(self, "position", self.position,  target_loc, 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(self, "offset", self.offset,  Vector2(0,140), 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$AnimationPlayer.stop()
	tween.start()

func _on_Tween_tween_completed(object, key):
	if object == self:
		$AnimationPlayer.play("idle")
	if key == "scale":
		self.visible = false
		
func click():
	
	tween.interpolate_property(self, "scale", self.scale,  Vector2(0,self.scale.y), 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(self, "position", self.position,  Vector2(0,self.position.y), 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	in_use = true
	
func reset():
	self.visible = true
	tween.interpolate_property(self, "scale", self.scale,  Vector2(0.1,0.1), 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "position", self.position,  Vector2(-20,self.position.y), 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	in_use = false
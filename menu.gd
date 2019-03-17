extends Control

onready var tween = get_node("MarginContainer/VBoxContainer/selector/Tween")
onready var button_tween = get_node("MarginContainer/VBoxContainer/button_tween")
onready var selector = get_node("MarginContainer/VBoxContainer/selector")
onready var select = 0
onready var buttons = get_tree().get_nodes_in_group("menu_buttons")
var select_stream = preload("res://assets/select.wav")
var highlight_stream = preload("res://assets/highlight.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		button.connect("mouse_entered", self, "selected", [button])
		button.connect("button_down", self, "button_click", [button])
		


func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		select = (select - 1) % 3 
		update_select()
	if Input.is_action_just_pressed("ui_down"):
		select = (select + 1) % 3 
		update_select()

func update_select():
	
	buttons[select].grab_focus()
	if not selector.visible:
		selector.visible = true
	var target = buttons[select].rect_position
	target.x -= 20
	tween.interpolate_property(selector, "position", selector.position,  target, 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(selector, "offset", selector.offset,  Vector2(0,140), 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$MarginContainer/VBoxContainer/selector/AnimationPlayer.stop()
	tween.start()
	
	$AudioStreamPlayer.set_stream(highlight_stream)
	$AudioStreamPlayer.play()

func selected(button: Button):
	select = buttons.find(button)
	update_select()


func _on_Tween_tween_completed(object, key):
	if object == $MarginContainer/VBoxContainer/selector:
		$MarginContainer/VBoxContainer/selector/AnimationPlayer.play("idle")


func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer2D.play()

func button_click(button: Button):
	collapse_buttons()
	for item in buttons:
		item.disabled = true
	$AudioStreamPlayer.set_stream(select_stream)
	$AudioStreamPlayer.play()
	#tween.interpolate_property(selector, "scale", selector.scale,  Vector2(0,0), 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(selector, "position", selector.position,  Vector2(0,selector.position.y), 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
func collapse_buttons():
	var i = buttons.size()-1
	while i >= 0:
		button_tween.interpolate_property(buttons[i], "rect_scale", buttons[i].rect_scale,  Vector2(buttons[i].rect_scale.x,0), 0.3,Tween.TRANS_BACK, Tween.EASE_IN)
		button_tween.start()
		i -= 1
		yield(button_tween, "tween_completed")
		$AudioStreamPlayer.set_stream(highlight_stream)
		$AudioStreamPlayer.play()
	reset_buttons()
	
func reset_buttons():
	for button in buttons:
		button.rect_scale = Vector2(1,1)
		button.disabled = false
	tween.interpolate_property(selector, "scale", selector.scale,  Vector2(0.1,0.1), 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(selector, "position", selector.position,  Vector2(-20,selector.position.y), 0.3,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
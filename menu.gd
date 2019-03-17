extends Control

onready var tween = get_node("MarginContainer/VBoxContainer/selector/Tween")
onready var selector = get_node("MarginContainer/VBoxContainer/selector")
onready var select = 0
onready var buttons = get_tree().get_nodes_in_group("menu_buttons")
# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		button.connect("mouse_entered", self, "selected", [button])
		


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

func selected(button: Button):
	select = buttons.find(button)
	update_select()


func _on_Tween_tween_completed(object, key):
	$MarginContainer/VBoxContainer/selector/AnimationPlayer.play("idle")

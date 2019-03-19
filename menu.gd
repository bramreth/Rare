extends Control


onready var button_tween = get_node("MarginContainer/VBoxContainer/button_tween")
onready var selector = get_node("MarginContainer/VBoxContainer/selector")
onready var select = 0

var buttons = []
onready var menu = get_tree().get_nodes_in_group("menu_buttons")
onready var options = get_tree().get_nodes_in_group("options_buttons")

var select_stream = preload("res://assets/select.wav")
var highlight_stream = preload("res://assets/highlight.wav")
var current_scene = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	buttons = menu
	
	for button in menu:
		button.connect("mouse_entered", self, "selected", [button])
		if button is Button:
			
			button.connect("button_down", self, "button_click", [button])
	for button in options:
		button.connect("mouse_entered", self, "selected", [button])
		#if button is Button:
			
			#button.connect("button_down", self, "button_click", [button])
    

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		select = (select - 1) % buttons.size()
		update_select()
	if Input.is_action_just_pressed("ui_down"):
		select = (select + 1) % buttons.size()
		update_select()

func update_select():
	
	selector.update_select(buttons[select])
	play_highlight()
	

func selected(button):
	select = buttons.find(button)
	update_select()

func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer2D.play()

func button_click(button: Button):
	collapse_buttons(button)
	for item in buttons:
		item.disabled = true
	play_select()
	
func collapse_buttons(button: Button):
	var i = buttons.size()-1
	while i >= 0:
		button_tween.interpolate_property(buttons[i], "rect_scale", buttons[i].rect_scale,  Vector2(buttons[i].rect_scale.x,0), 0.3,Tween.TRANS_BACK, Tween.EASE_IN)
		button_tween.start()
		i -= 1
		yield(button_tween, "tween_completed")
		play_highlight()
	for button in buttons:
		button.visible = false
	
	#play
	if button == buttons[0]:
		call_deferred("_deferred_goto_scene", "res://training_grounds.tscn")
	
	#options
	if button == buttons[1]:
		$MarginContainer/VBoxContainer/options.make_visible()
		buttons = options
		select = 0
		selector.silent_move(buttons[select])
	
	#quit
	if button == buttons[2]:
		get_tree().quit()
		
	#reset_buttons()
	
func play_highlight():
	$AudioStreamPlayer.set_stream(highlight_stream)
	$AudioStreamPlayer.play()
	
func play_select():
	$AudioStreamPlayer.set_stream(select_stream)
	$AudioStreamPlayer.play()
	selector.click()
	
func reset_buttons():
	for button in buttons:
		button.rect_scale = Vector2(1,1)
		button.visible = true
		button.disabled = false
	selector.reset()

func _on_options_back():
	buttons = menu
	reset_buttons()
	select = 1
	selector.silent_move(buttons[select])
	
	selector.reset()

func _deferred_goto_scene(path):
	$background2.queue_free()
	$Label.queue_free()
	$MarginContainer.queue_free()
	#current_scene.queue_free()
	
	    # Load the new scene.
	var s = ResourceLoader.load(path)

    # Instance the new scene.
	current_scene = s.instance()

    # Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

    # Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
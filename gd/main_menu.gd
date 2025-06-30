extends Node2D

const TILE_SIZE := Vector2(1024, 1024)
const GRID_WIDTH := 2
const GRID_HEIGHT := 2
const SPEED := 20.0

@onready var start_button = $ButtonContainer/StartButton
@onready var exit_button = $ButtonContainer/ExitButton
@onready var bg_music = $AmbienceAudio
@onready var start_button_animation = $ButtonContainer/StartButton/StartButtonAnimation if has_node("ButtonContainer/StartButton/StartButtonAnimation") else null
@onready var exit_button_animation = $ButtonContainer/ExitButton/ExitButtonAnimation if has_node("ButtonContainer/ExitButton/ExitButtonAnimation") else null
@onready var login_popup = $LoginPopup
@onready var username_field = $LoginPopup/VBoxContainer/UsernameField if login_popup and login_popup.has_node("VBoxContainer/UsernameField") else null
@onready var password_field = $LoginPopup/VBoxContainer/PasswordField if login_popup and login_popup.has_node("VBoxContainer/PasswordField") else null
@onready var error_label = $LoginPopup/VBoxContainer/ErrorLabel if login_popup and login_popup.has_node("VBoxContainer/ErrorLabel") else null

var error_messages = [
	"[System] Identity unclear. Please retry…",
	"[ERROR] Access denied. Try again, user?",
	"[WARN] User not found. Re-enter credentials."
]

func _on_start_pressed():
	if login_popup:
		login_popup.popup()
		if error_label:
			error_label.text = ""  

func _on_exit_pressed():
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

var offset := Vector2.ZERO
var move_dir := Vector2.ZERO
var sprite_grid := []

var direction_timer := 0.0
const DIRECTION_CHANGE_INTERVAL := 3.0

func _ready():
	print("StartButtonAnimation playing? ", start_button_animation.is_playing())
	print("StartButtonAnimation current anim: ", start_button_animation.animation)
	print("StartButtonAnimation has frames: ", start_button_animation.sprite_frames.get_animation_names())
#尝试隐藏按钮，但失败了
	if bg_music:
		bg_music.play()
	if start_button:
		start_button.connect("pressed", _on_start_pressed)
		start_button.visible = true  
	if exit_button:
		exit_button.connect("pressed", _on_exit_pressed)
		exit_button.modulate.a = 0  
		exit_button.visible = true  
	var frames = load("res://assets/animations/background_frames.tres")
	if not frames:
		push_error("无法加载动画帧资源")
		return

	if $ButtonContainer:
		$ButtonContainer.modulate = Color(1, 1, 1, 1)
	if start_button:
		start_button.modulate = Color(1, 1, 1, 1)
	if exit_button:
		exit_button.modulate = Color(1, 1, 1, 1)

	for y in range(GRID_HEIGHT + 1):
		for x in range(GRID_WIDTH + 1):
			var sprite := AnimatedSprite2D.new()
			sprite.sprite_frames = frames
			sprite.animation = "default"
			sprite.play()
			sprite.centered = false
			if randf() < 0.5:
				sprite.frame = 0
				sprite.modulate = Color(1, 1, 0.8, 0.4)
			else:
				sprite.frame = 1
				sprite.modulate = Color(0.3, 0.3, 0.3, 0.2)
			add_child(sprite)
			sprite_grid.append(sprite)

	# 初始化动画并确保可见
	if start_button_animation:
		start_button_animation.visible = true
		start_button_animation.modulate.a = 1  # 确保动画可见
		start_button_animation.play("default", -1, 0.5)  # 低速循环
		start_button.connect("mouse_entered", _on_start_button_mouse_entered)
		start_button.connect("mouse_exited", _on_start_button_mouse_exited)
	if exit_button_animation:
		exit_button_animation.visible = true
		exit_button_animation.modulate.a = 1  # 确保动画可见
		exit_button_animation.play("default", -1, 0.5)  # 低速循环
		exit_button.connect("mouse_entered", _on_exit_button_mouse_entered)
		exit_button.connect("mouse_exited", _on_exit_button_mouse_exited)

	if login_popup:
		login_popup.size = Vector2(300, 250)
		login_popup.position = Vector2((get_viewport_rect().size.x - 300) / 2, (get_viewport_rect().size.y - 250) / 2)
		if username_field:
			username_field.placeholder_text = "Username"
		if password_field:
			password_field.placeholder_text = "Password"
			password_field.secret = true
		login_popup.dialog_close_on_escape = false
		login_popup.connect("confirmed", _on_login_confirmed)

	_set_random_direction()
	direction_timer = DIRECTION_CHANGE_INTERVAL

func _process(delta):
	offset += move_dir * SPEED * delta
	offset.x = wrapf(offset.x, 0, TILE_SIZE.x)
	offset.y = wrapf(offset.y, 0, TILE_SIZE.y)

	var i := 0
	for y in range(GRID_HEIGHT + 1):
		for x in range(GRID_WIDTH + 1):
			var px = x * TILE_SIZE.x - offset.x
			var py = y * TILE_SIZE.y - offset.y
			if i < sprite_grid.size():
				sprite_grid[i].position = Vector2(px, py)
			i += 1

	var time = Time.get_ticks_msec() / 1000.0
	if start_button:
		start_button.position.y = $ButtonContainer.position.y + 50 + sin(time) * 10
	if exit_button:
		exit_button.position.y = $ButtonContainer.position.y + 100 + sin(time + 1.0) * 10

	direction_timer -= delta
	if direction_timer <= 0:
		_set_random_direction()
		direction_timer = DIRECTION_CHANGE_INTERVAL

func _set_random_direction():
	var angle = randf() * PI * 2
	move_dir = Vector2(cos(angle), sin(angle))

func _on_start_button_mouse_entered():
	if start_button_animation:
		start_button_animation.speed_scale = 2.0  # 鼠标悬停时加速

func _on_start_button_mouse_exited():
	if start_button_animation:
		start_button_animation.speed_scale = 0.5  # 鼠标移开恢复低速

func _on_exit_button_mouse_entered():
	if exit_button_animation:
		exit_button_animation.speed_scale = 2.0  # 鼠标悬停时加速

func _on_exit_button_mouse_exited():
	if exit_button_animation:
		exit_button_animation.speed_scale = 0.5  # 鼠标移开恢复低速

func _on_login_confirmed():
	if username_field and password_field:
		var username = username_field.text
		var password = password_field.text
		if username == "Lin" and password == "2021":
			if login_popup:
				login_popup.hide()
			get_tree().change_scene_to_file("res://scenes/memory_scene.tscn")
		else:
			if error_label:
				error_label.text = error_messages[randi() % error_messages.size()]

extends CharacterBody2D

const GRAVITY = 600.0
const SPEED = 300.0
const JUMP_FORCE = -600.0
const SLIDE_FORCE = 100.0

func _physics_process(delta):
	var input_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_direction * SPEED

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		var floor_normal = get_floor_normal()
		if floor_normal.angle_to(Vector2.UP) > deg_to_rad(5):
			var slide_dir = (Vector2.DOWN - floor_normal).normalized()
			velocity += slide_dir * SLIDE_FORCE * delta
		else:
			velocity.y = 0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()

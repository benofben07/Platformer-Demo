extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var jumping: bool = false
var double_jumping: bool = false
var landing: bool = false
var was_in_air: bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if jumping or was_in_air:
			landing = true
			was_in_air = false
		jumping = false
		double_jumping = false

	var jumping_pressed = Input.is_action_just_pressed("jump")
	var double_jumping_pressed: bool = false
	# Handle jump.
	if jumping_pressed and not landing:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumping = true
		elif not is_on_floor() and not double_jumping:
			velocity.y = JUMP_VELOCITY
			double_jumping_pressed = true
			jumping = true
			double_jumping = true
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction and not landing:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_sprite_animation(direction, jumping_pressed, double_jumping_pressed)
	flip_character_sprite_if_needed(direction)
	move_and_slide()
	
	if not is_on_floor():
		was_in_air = true
	
func update_sprite_animation(direction: float, jumping_pressed: bool, double_jumping_pressed:bool):
	if not is_on_floor():
		if double_jumping_pressed:
			animated_sprite.play("jump_start")
		elif not jumping:
			animated_sprite.play("falling")
		
		return
		
	if landing:
		animated_sprite.play("jump_landing")
		return
		
	if jumping_pressed:
		animated_sprite.play("jump_start")
		return

	if not direction:
		animated_sprite.play("idle")
		return

	if direction:
		animated_sprite.play("run")
		return

func flip_character_sprite_if_needed(direction: float):
	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "jump_start":
		animated_sprite.play("jump_in_air")
	if animated_sprite.animation == "jump_in_air":
		animated_sprite.play("falling")
	if animated_sprite.animation == "jump_landing":
		landing = false				

func bool_to_str(b: bool):
	return "True" if b else "False"

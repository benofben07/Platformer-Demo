extends CharacterBody2D

@export var speed = 300.0
@export var dashing_time = 0.4
@export var dashing_speed = 450.0
@export var jump_velocity = -350.0
@export var double_jump_velocity = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_timer: Timer = $DashTimer

var jumping: bool = false
var double_jumping: bool = false
var landing: bool = false
var dashing: bool = false
var was_in_air: bool = false
var was_dashing: bool = false
var last_facing_direction: float = 1.0
var dashing_direction: float = 1.0
var dash_ending_animation_in_progress: bool = false

func _physics_process(delta):
	if not is_on_floor():
		# gravity
		velocity.y += gravity * delta
		# dashing isn't in progress while in the air
		dashing = false
	else:
		# landing
		if was_in_air:
			landing = true
			was_in_air = false
			
		jumping = false
		double_jumping = false

	# dashing stops at this frame
	if dashing and dash_timer.is_stopped():
		dashing = false

	var jumping_pressed = Input.is_action_just_pressed("jump")
	var dashing_pressed = Input.is_action_just_pressed("dash")
	var double_jumping_pressed: bool = false
	
	# jump
	if jumping_pressed and not landing and not dashing:
		# simple jump
		if is_on_floor():
			velocity.y = jump_velocity
			jumping = true
			dashing = false
			was_dashing = false
		# double jump
		elif not is_on_floor() and not double_jumping:
			velocity.y = jump_velocity
			double_jumping_pressed = true
			jumping = true
			double_jumping = true
		
	# movement
	var direction = Input.get_axis("move_left", "move_right")

	# dont smooth with controller movement
	if direction < 0:
		direction = -1
	elif direction > 0:
		direction = 1
	
	# dashing in progress
	# dont let change direction while dashing
	if dashing:
		velocity.x = last_facing_direction * dashing_speed
	
	# dashing
	if dashing_pressed and not dashing and not jumping:
		dash_timer.start(dashing_time)
		dashing = true
		velocity.x = direction * dashing_speed
		landing = false
	
	# movement
	if direction and not landing and not dashing:
		velocity.x = direction * speed
		dash_ending_animation_in_progress = false
	elif not dashing:
		velocity.x = move_toward(velocity.x, 0, speed)

	update_sprite_animation(direction, jumping_pressed, double_jumping_pressed, dashing_pressed)
	flip_character_sprite_if_needed(direction)
	move_and_slide()
	
	# setting up variables for next frame
	if not is_on_floor():
		was_in_air = true
		
	if direction and not dashing:
		last_facing_direction = direction
	
	was_dashing = dashing
	
func update_sprite_animation(direction: float, jumping_pressed: bool, double_jumping_pressed: bool, dashing_pressed: bool):
	if not is_on_floor():
		if double_jumping_pressed:
			animated_sprite.play("jump_start")
		elif not jumping:
			animated_sprite.play("falling")
		
		return
	
	if dashing_pressed and not was_dashing:
		animated_sprite.play("dash_start")
		return
	
	# lock dashing animation
	if dashing:
		return
	# dashing finished
	elif not dashing and was_dashing:
		animated_sprite.play("dash_end")
		dash_ending_animation_in_progress = true
		return
		
	if landing:
		animated_sprite.play("jump_landing")
		return
		
	if jumping_pressed:
		animated_sprite.play("jump_start")
		return

	if not direction and not dash_ending_animation_in_progress:
		animated_sprite.play("idle")
		return

	if direction:
		animated_sprite.play("run")
		return

func flip_character_sprite_if_needed(direction: float):
	if dashing:
		return
	elif direction < 0:
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
	if animated_sprite.animation == "dash_start":
		animated_sprite.play("dash_loop")
	if animated_sprite.animation == "dash_end":
		dash_ending_animation_in_progress = false

func bool_to_str(b: bool):
	return "True" if b else "False"

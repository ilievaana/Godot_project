extends CharacterBody3D

@export var speed = 5.0
@export var jump_force = 5.0
@export var gravity = 9.8
@export var friction = 0.1  # За постепено запирање

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	# Движење во сите 4 правци
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	# Ако има насока на движење, нормализирај
	if direction.length() > 0:
		direction = direction.normalized() * speed
	
	# Постепено запирање
	velocity.x = lerp(velocity.x, direction.x, friction)
	velocity.z = lerp(velocity.z, direction.z, friction)

	# Примена на гравитација
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Скок ако е на подот
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

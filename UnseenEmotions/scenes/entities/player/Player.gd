class_name Player
extends CharacterBody2D

@export var speed: float = 150.0
@export var jump: float = -200.0

@onready var sprite_2d: Sprite2D = $Sprite2D

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _jumped: bool = false

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	
	movement_input()
	
	move_and_slide()

func movement_input() -> void:
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = jump
		_jumped = true
	if Input.is_action_just_released("jump") and _jumped:
		velocity.y = 0.0
		_jumped = false
	
	velocity.x = speed * Input.get_axis("left", "right")
	if not is_equal_approx(velocity.x, 0.0):
		sprite_2d.flip_h = velocity.x < 0

class_name PlayerComponent
extends Node

enum State {
	PLAY,
	STOP
}

# Variables that are changeable
@export var player: Player
@export var sprite: Sprite2D # change for animated sprite

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var speed: float = 150.0
var jump: float = -200.0
var _jumped: bool = false
var _current_state: State = State.PLAY

func _unhandled_input(event: InputEvent) -> void:
	pass


func process_body(delta: float) -> void:
	match _current_state:
		State.PLAY:
			# Apply gravity
			if !player.is_on_floor():
				player.velocity.y += GRAVITY * delta
			
			movement_input()
			fall_out_of_bounds()
			player.move_and_slide()
		State.STOP:
			pass
		_:
			pass
	
	

func movement_input() -> void:
	# Jump Logic
	if player.is_on_floor() and Input.is_action_pressed("jump"):
		player.velocity.y = jump
		_jumped = true
	if Input.is_action_just_released("jump") and _jumped:
		player.velocity.y = 0.0
		_jumped = false
	
	# Movement (left, right) Logic
	player.velocity.x = speed * Input.get_axis("left", "right")
	if not is_equal_approx(player.velocity.x, 0.0):
		sprite.flip_h = player.velocity.x < 0


func fall_out_of_bounds() -> void:
	if player.position.y >= MAX_FALL:
		owner.queue_free()


func attack() -> void:
	pass


func take_damage() -> void:
	pass


func _on_hit_box_area_entered(area: Area2D) -> void:
	take_damage()

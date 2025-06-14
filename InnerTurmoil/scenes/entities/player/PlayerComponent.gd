class_name PlayerComponent
extends Node

enum State {
	PLAY,
	STOP
}

# Variables that are changeable
@export_category("Setup")
@export var player: Player
@export var sprite: Sprite2D # change for animated sprite
@export var hit_box: Area2D
@export var attack_area: Area2D

@export_category("Details")
@export var health: int = 3
@export var speed: float = 150.0
@export var jump: float = -200.0
@export var attack: int = 1
@export var pushback: float = 600.0

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _jumped: bool = false
var _current_state: State = State.PLAY
var _attackable: bool = false

func _unhandled_input(event: InputEvent) -> void:
	pass

func _ready() -> void:
	hit_box.area_entered.connect(on_hit_box_entered)
	attack_area.area_entered.connect(on_attack)
	attack_area.area_exited.connect(on_exit)


func process_body(delta: float) -> void:
	match _current_state:
		State.PLAY:
			# Apply gravity
			if !player.is_on_floor():
				player.velocity.y += GRAVITY * delta
			
			
			
			movement_input()
			fall_out_of_bounds()
			attack_input()
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


func attack_input() -> void:
	if _attackable and Input.is_action_just_pressed("attack"):
		SignalManager.player_attacked.emit(attack, 1 if !sprite.flip_h else -1)
		print("Attack")
		# player.velocity.x = pushback if sprite.flip_h else -pushback


func take_damage() -> void:
	pass


func on_hit_box_entered(area: Area2D) -> void:
	print("Damage")


func on_attack(area: Area2D) -> void:
	_attackable = true


func on_exit(area: Area2D) -> void:
	_attackable = false

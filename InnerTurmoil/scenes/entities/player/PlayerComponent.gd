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
@export var invincibility_timer: Timer

@export_category("Details")
@export var lives: int = 3
@export var speed: float = 150.0
@export var jump: float = -200.0
@export var damage: int = 1
@export var pushback: float = 600.0

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _current_state: State = State.PLAY

var _jumped: bool = false
var _attackable: bool = false
var _invincible: bool = false

var _attack_area_position: float
var _enemy_damage: int

func _unhandled_input(event: InputEvent) -> void:
	pass


func _ready() -> void:
	hit_box.area_entered.connect(on_hit_box_entered)
	attack_area.area_entered.connect(on_attack)
	attack_area.area_exited.connect(on_exit)
	invincibility_timer.timeout.connect(on_invincibility_timer_timeout)
	call_deferred("deferred_signals")
	
	SignalManager.player_lives.emit(lives)
	
	_attack_area_position = attack_area.position.x


func deferred_signals() -> void:
	SignalManager.enemy_attacked.connect(on_enemy_attacked)


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
	player.velocity.x = 0
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		player.velocity.x = -speed
		sprite.flip_h = true
		attack_area.position.x = -_attack_area_position
	if Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		player.velocity.x = speed
		sprite.flip_h = false
		attack_area.position.x = _attack_area_position
	
	if not is_equal_approx(player.velocity.x, 0.0):
		sprite.flip_h = player.velocity.x < 0
		


func fall_out_of_bounds() -> void:
	if player.position.y >= MAX_FALL:
		owner.queue_free()


func attack_input() -> void:
	if _attackable and Input.is_action_just_pressed("attack"):
		SignalManager.player_attacked.emit(damage, 1 if !sprite.flip_h else -1)
		# player.velocity.x = pushback if sprite.flip_h else -pushback


func take_damage(damage: int) -> void:
	lives -= damage
	SignalManager.player_lives.emit(lives)
	
	if lives <= 0:
		owner.call_deferred("queue_free")


func on_hit_box_entered(area: Area2D) -> void:
	take_damage(_enemy_damage)
	_invincible = true
	invincibility_timer.start(2.0)


func on_attack(area: Area2D) -> void:
	_attackable = true


func on_exit(area: Area2D) -> void:
	_attackable = false


func on_invincibility_timer_timeout() -> void:
	_invincible = false


func on_enemy_attacked(dmg: int) -> void:
	_enemy_damage = dmg

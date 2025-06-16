class_name EnemyComponent
extends Node

enum Type {
	DEFAULT,
	NORMAL,
	AGGRESSIVE,
	FLYING,
	BOSS
}

@export_category("General")
@export var enemy: Enemy
@export var sprite: Sprite2D # change sprite to animated
@export var hit_box: Area2D
@export var attack_area: Area2D
@export var timer: Timer
@export var enemy_type: Type


@export_category("Details")
@export var lives: int = 3
@export var damage: int = 1
@export var speed: float = 150.0
@export var jump: float = -200.0
@export var pushback: float = 900.0

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _timer_going: bool = false
var _changing_speed: bool = false
var _delta: float

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	attack_area.area_entered.connect(on_attack_area_entered)
	SignalManager.player_attacked.connect(on_player_attacked)


func process_body(delta: float) -> void:
	_delta = delta
	match enemy_type:
		Type.DEFAULT:
			pass
		Type.NORMAL:
			physics_normal(delta)
			enemy.move_and_slide()
			checks_normal()
		Type.AGGRESSIVE:
			physics_normal(delta)
		Type.FLYING:
			pass
		Type.BOSS:
			pass


func physics_normal(delta: float) -> void:
	if !enemy.is_on_floor():
		enemy.velocity.y += GRAVITY * delta
	
	match enemy_type:
		Type.NORMAL:
			logic_normal()
		Type.AGGRESSIVE:
			pass


func logic_normal() -> void:
	if !_changing_speed:
		enemy.velocity.x = speed if !sprite.flip_h else -speed
	
	if !_timer_going:
		_timer_going = true
		timer.start(randf_range(4.0, 7.0))


func checks_normal() -> void:
	if enemy.is_on_wall() or !enemy.ray_cast_2d.is_colliding():
		sprite.flip_h = !sprite.flip_h
		enemy.ray_cast_2d.position.x = -enemy.ray_cast_2d.position.x


# changes speed:
# for decel -> x < 1 and the smaller the number the quicker the decel
# for accel -> x > 1 and the greater the number the quicker the accel
func speed_change(expo_factor: float) -> void:
	while enemy.velocity.x != 0:
		checks_normal()
		var dir: int = 1 if !sprite.flip_h else -1
		enemy.velocity.x *= expo_factor * _delta * dir
		
		if is_equal_approx(enemy.velocity.x, 0):
			enemy.velocity.x = 0
			break
		
		enemy.move_and_slide()


func on_timer_timeout() -> void:
	match enemy_type:
		Type.NORMAL:
			_changing_speed = true
			
			speed_change(0.9)
			await get_tree().create_timer(1.0).timeout
			speed_change(1.2)
			
			_changing_speed = false
			_timer_going = false


func on_attack_area_entered(_area: Area2D) -> void:
	SignalManager.enemy_attacked.emit(damage)


func on_player_attacked(dmg: int, dir_x: float) -> void:
	_changing_speed = true
	timer.stop()
	enemy.velocity.x += pushback * dir_x
	enemy.move_and_slide()
	
	lives -= dmg
	if lives <= 0:
		owner.call_deferred("queue_free")
	
	enemy.velocity.x = 0
	await get_tree().create_timer(1).timeout
	speed_change(1.2)
	_changing_speed = false
	_timer_going = false

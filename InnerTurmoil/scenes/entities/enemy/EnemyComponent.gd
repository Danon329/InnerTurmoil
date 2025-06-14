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
@export var enemy_type: Type
@export var timer: Timer

@export_category("Details")
@export var lives: int = 3
@export var damage: int = 1
@export var speed: float = 150.0
@export var jump: float = -200.0
@export var pushback: float = 900.0

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _just_turned: bool = false
var _timer_going: bool = false
var _changing_speed: bool = false

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	SignalManager.player_attacked.connect(on_player_attacked)


func process_body(delta: float) -> void:
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


func slow_down_tween() -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(enemy, "velocity", Vector2.ZERO, 0.7)
	return tween


func accelerate_tween() -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(enemy, "velocity", Vector2(speed if !sprite.flip_h else -speed, 0), 1.0)
	return tween


func on_timer_timeout() -> void:
	match enemy_type:
		Type.NORMAL:
			_changing_speed = true
			await slow_down_tween().finished
			await get_tree().create_timer(1.0).timeout
			await accelerate_tween().finished
			_changing_speed = false
			_timer_going = false


func on_player_attacked(damage: int, dir_x: float) -> void:
	timer.stop()
	lives -= damage
	enemy.velocity.x += pushback * dir_x
	enemy.move_and_slide()
	if lives <= 0:
		owner.call_deferred("queue_free")

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
@export var enemy: CharacterBody2D
@export var sprite: Sprite2D # change sprite to animated
@export var hit_box: Area2D
@export var attack_area: Area2D
@export var timer: Timer
@export var visbible_on_screen: VisibleOnScreenNotifier2D
@export var enemy_type: Type


@export_category("Details")
@export var lives: int = 3
@export var damage: int = 1
@export var walk: float = 50.0
@export var run: float = 150.0
@export var jump: float = -200.0
@export var pushback: float = 3000.0

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _timer_going: bool = false
var _changing_speed: bool = false
var _speed_change_finished: bool = true
var _visible: bool = false
var _running: bool = false

var _delta: float

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	attack_area.area_entered.connect(on_attack_area_entered)
	visbible_on_screen.screen_entered.connect(on_visible)
	SignalManager.player_attacked.connect(on_player_attacked)


func process_body(delta: float) -> void:
	if !_visible: return
	
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
			player_in_range()
			enemy.move_and_slide()
			checks_normal()
		Type.FLYING:
			pass
		Type.BOSS:
			pass


func physics_normal(delta: float) -> void:
	if !enemy.is_on_floor():
		enemy.velocity.y += GRAVITY * delta
	
	logic_normal()


func logic_normal() -> void:
	if !_changing_speed:
		enemy.velocity.x = walk if !sprite.flip_h else -walk
	
	if !_timer_going:
		_timer_going = true
		timer.start(randf_range(4.0, 7.0))


func checks_normal() -> void:
	if enemy.is_on_wall() or !enemy.ray_cast.is_colliding():
		sprite.flip_h = !sprite.flip_h
		enemy.ray_cast.position.x = -enemy.ray_cast.position.x
		match enemy_type:
			Type.AGGRESSIVE:
				enemy.player_ray.rotation_degrees = -enemy.player_ray.rotation_degrees


func player_in_range() -> void:
	if enemy.player_ray.is_colliding() and !_running:
		_changing_speed = true
		_running = true
		speed_change(1.1, run)
	
	if !enemy.player_ray.is_colliding() and _running:
		_running = false
		speed_change(0.9, walk)
		_changing_speed = false


# changes speed:
# for decel -> x < 1 and the smaller the number the quicker the decel
# for accel -> x > 1 and the greater the number the quicker the accel
func speed_change(expo_factor: float, speed: float) -> void:
	_speed_change_finished = false
	
	while !_speed_change_finished:
		checks_normal()
		var dir: int = 1 if !sprite.flip_h else -1
		speed *= dir
		enemy.velocity.x *= expo_factor * _delta * dir
		
		if is_equal_approx(enemy.velocity.x, 0.0):
			enemy.velocity.x = 0
			_speed_change_finished = true
			break
		elif enemy.velocity.x >= speed or enemy.velocity.x <= speed:
			enemy.velocity.x = speed
			_speed_change_finished = true
			break
		
		
		enemy.move_and_slide()


func on_timer_timeout() -> void:
	if enemy_type == Type.NORMAL or enemy_type == Type.AGGRESSIVE:
		_changing_speed = true
		
		speed_change(0.9, 0.0)
		await get_tree().create_timer(1.0).timeout
		speed_change(1.2, walk)
		
		_changing_speed = false
		_timer_going = false


func on_attack_area_entered(_area: Area2D) -> void:
	SignalManager.enemy_attacked.emit(damage)


func on_player_attacked(dmg: int, dir_x: float) -> void:
	if enemy_type == Type.AGGRESSIVE:
		_running = false
		enemy.player_ray.enabled = false
	
	
	_changing_speed = true
	timer.stop()
	enemy.velocity.x += pushback * dir_x
	enemy.move_and_slide()
	
	lives -= dmg
	if lives <= 0:
		owner.call_deferred("queue_free")
	
	enemy.velocity.x = 0
	await get_tree().create_timer(1).timeout
	
	if enemy_type == Type.AGGRESSIVE:
		enemy.player_ray.enabled = true
		player_in_range()
	
	if !_running:
		speed_change(1.2, walk)
		_changing_speed = false
		_timer_going = false


func on_visible() -> void:
	_visible = true

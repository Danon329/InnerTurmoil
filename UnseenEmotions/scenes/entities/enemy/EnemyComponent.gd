class_name EnemyComponent
extends Node

enum Type {
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

@export_category("Details")
@export var lives: int = 3
@export var damage: int = 1
@export var speed: float = 150.0
@export var jump: float = -200.0

const GRAVITY: float = 400.0
const MAX_FALL: float = 800.0

var _just_turned: bool = false

func process_body(delta: float) -> void:
	match enemy_type:
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
			enemy.velocity.x = speed if !sprite.flip_h else -speed
		Type.AGGRESSIVE:
			pass
	


func checks_normal() -> void:
	if enemy.is_on_wall() or !enemy.ray_cast_2d.is_colliding():
		sprite.flip_h = !sprite.flip_h
		enemy.ray_cast_2d.position.x = -enemy.ray_cast_2d.position.x
	

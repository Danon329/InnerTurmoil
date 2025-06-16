class_name Enemy
extends CharacterBody2D

@export var enemy_component: EnemyComponent

func _physics_process(delta: float) -> void:
	enemy_component.process_body(delta)

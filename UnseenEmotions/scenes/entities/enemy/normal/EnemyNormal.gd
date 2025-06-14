class_name Enemy
extends CharacterBody2D

@onready var enemy_component: EnemyComponent = $EnemyComponent
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	enemy_component.process_body(delta)

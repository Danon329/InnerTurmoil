class_name Player
extends CharacterBody2D

@export var player_component: PlayerComponent

func _physics_process(delta: float) -> void:
	player_component.process_body(delta)

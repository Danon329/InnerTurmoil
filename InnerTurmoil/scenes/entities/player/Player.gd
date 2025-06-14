class_name Player
extends CharacterBody2D

@onready var player_component: PlayerComponent = $PlayerComponent

func _physics_process(delta: float) -> void:
	player_component.process_body(delta)

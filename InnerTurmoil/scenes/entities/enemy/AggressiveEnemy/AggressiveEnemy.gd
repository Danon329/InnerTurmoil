extends Enemy

@export var ray_cast: RayCast2D
@export var player_ray: RayCast2D

func _physics_process(delta: float) -> void:
	super(delta)

extends Node

@warning_ignore_start("unused_signal")
signal player_attacked(damage: int, dir_x: float)
signal enemy_attacked(damage: int)

signal player_lives(lives: int)

signal petal_aquired
signal health_item_aquired
@warning_ignore_restore("unused_signal")

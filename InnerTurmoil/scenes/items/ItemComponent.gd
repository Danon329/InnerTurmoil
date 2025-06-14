class_name ItemComponent
extends Node

signal petal_aquired
signal health_item_aquired

enum Type {
	PETAL,
	HEALTH_ITEM
}

@export var item: Area2D
@export var type: Type

func _ready() -> void:
	item.area_entered.connect(on_area_entered)


# Once the Player enters the area, depending on the Item type, something
# will happen.
func on_area_entered(area: Area2D) -> void:
	match type:
		Type.PETAL:
			petal_aquired.emit()
			owner.set_deferred("monitorable", false)
			owner.set_deferred("monitoring", false)
			await tween_petal(Vector2.ZERO).finished
			owner.queue_free()
		Type.HEALTH_ITEM:
			health_item_aquired.emit()
			print("Hello")
		_:
			pass


func tween_petal(position: Vector2) -> Tween:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "global_position", position, 1)
	tween.tween_property(item, "modulate", Color("#ffffff", 0), 1)
	tween.set_parallel(false)
	tween.tween_interval(2)
	return tween

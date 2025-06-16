extends Node

const AGGRESSIVE_ENEMY = preload("res://scenes/entities/enemy/AggressiveEnemy/AggressiveEnemy.tscn")
const NORMAL_ENEMY = preload("res://scenes/entities/enemy/NormalEnemy/NormalEnemy.tscn")
const PLAYER = preload("res://scenes/entities/player/Player.tscn")

@onready var player_button: Button = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Player
@onready var normal_button: Button = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Normal
@onready var aggressive_button: Button = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Aggressive

@onready var player_marker: Marker2D = $Markers/PlayerMarker
@onready var normal_marker: Marker2D = $Markers/NormalMarker
@onready var aggressive_marker: Marker2D = $Markers/AggressiveMarker

@onready var player_lives: Label = $CanvasLayer/MarginContainer/VBoxContainer/PlayerLives

var _player: Node
var _normal_enemy: Node
var _aggressive_enemy: Node

var _player_lives: int

func _ready() -> void:
	SignalManager.player_lives.connect(get_player_lives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _player == null:
		player_button.disabled = false
	
	if _normal_enemy == null:
		normal_button.disabled = false
	
	if _aggressive_enemy == null:
		aggressive_button.disabled = false


func get_player_lives(lives: int) -> void:
	player_lives.text = "Lives: %d" % [lives]


func _on_player_pressed() -> void:
	player_button.disabled = true
	_player = PLAYER.instantiate()
	_player.global_position = player_marker.global_position
	add_child(_player)


func _on_normal_pressed() -> void:
	normal_button.disabled = true
	_normal_enemy= NORMAL_ENEMY.instantiate()
	_normal_enemy.global_position = normal_marker.global_position
	add_child(_normal_enemy)


func _on_aggressive_pressed() -> void:
	aggressive_button.disabled = true
	_aggressive_enemy = AGGRESSIVE_ENEMY.instantiate()
	_aggressive_enemy.global_position = aggressive_marker.global_position
	add_child(_aggressive_enemy)

extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal all_waves_cleared

@export var enemy_scene: PackedScene
@export var initial_wave_size: int = 3
@export var wave_size_growth: int = 2
@export var spawn_interval: float = 1.0
@export var wave_pause: float = 2.0
@export var spawn_radius: float = 220.0
@export var max_waves: int = 5

var current_wave: int = 0
var _enemies_to_spawn: int = 0
var _active_enemies: int = 0

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _wave_timer: Timer = $WaveTimer

func _ready() -> void:
    _spawn_timer.wait_time = spawn_interval
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    _wave_timer.one_shot = true
    _wave_timer.timeout.connect(_start_next_wave)
    _start_next_wave()

func stop_spawning() -> void:
    _spawn_timer.stop()
    _wave_timer.stop()

func _start_next_wave() -> void:
    current_wave += 1
    _enemies_to_spawn = initial_wave_size + (current_wave - 1) * wave_size_growth
    emit_signal("wave_started", current_wave)
    _spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
    if _enemies_to_spawn > 0:
        _spawn_enemy()
    elif _active_enemies == 0:
        _finish_wave()

func _spawn_enemy() -> void:
    if enemy_scene == null:
        push_warning("Enemy scene is missing on spawner")
        return

    var enemy: Node2D = enemy_scene.instantiate()
    add_child(enemy)
    enemy.global_position = _random_spawn_position()

    if enemy.has_signal("defeated"):
        enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))

    _enemies_to_spawn -= 1
    _active_enemies += 1

func _on_enemy_defeated() -> void:
    _active_enemies = max(_active_enemies - 1, 0)
    if _enemies_to_spawn == 0 and _active_enemies == 0:
        _finish_wave()

func _finish_wave() -> void:
    _spawn_timer.stop()
    emit_signal("wave_completed", current_wave)
    if current_wave >= max_waves:
        emit_signal("all_waves_cleared")
        return

    _wave_timer.start(wave_pause)

func _random_spawn_position() -> Vector2:
    var angle := randf_range(0.0, TAU)
    var offset := Vector2.RIGHT.rotated(angle) * spawn_radius
    return global_position + offset

extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal all_waves_cleared
signal enemy_count_changed(remaining, total)

@export var enemy_scene: PackedScene
@export var initial_wave_size: int = 3
@export var wave_size_growth: int = 2
@export var spawn_interval: float = 1.0
@export var wave_pause: float = 2.0
@export var spawn_radius: float = 220.0
@export var total_waves: int = 3

var current_wave: int = 0
var _enemies_to_spawn: int = 0
var _active_enemies: int = 0
var _current_wave_total: int = 0

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
    if total_waves > 0 and current_wave >= total_waves:
        _complete_demo()
        return

    current_wave += 1
    _enemies_to_spawn = initial_wave_size + (current_wave - 1) * wave_size_growth
    _current_wave_total = _enemies_to_spawn

    emit_signal("wave_started", current_wave)
    _emit_enemy_count()
    _spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
    if _enemies_to_spawn > 0:
        _spawn_enemy()
    elif _active_enemies == 0:
        _finish_wave()

func _spawn_enemy() -> void:
    if enemy_scene == null:
        push_warning("Enemy scene is missing on arena manager")
        return

    var enemy: Node2D = enemy_scene.instantiate()
    add_child(enemy)
    enemy.global_position = _random_spawn_position()

    if enemy.has_method("set_arena_manager"):
        enemy.set_arena_manager(self)

    if enemy.has_signal("died"):
        enemy.connect("died", Callable(self, "_on_enemy_defeated"))

    _enemies_to_spawn -= 1
    _active_enemies += 1
    _emit_enemy_count()

func _on_enemy_defeated() -> void:
    _active_enemies = max(_active_enemies - 1, 0)
    _emit_enemy_count()
    if _enemies_to_spawn == 0 and _active_enemies == 0:
        _finish_wave()

func _finish_wave() -> void:
    _spawn_timer.stop()
    emit_signal("wave_completed", current_wave)
    _emit_enemy_count()

    if total_waves > 0 and current_wave >= total_waves:
        _complete_demo()
    else:
        _wave_timer.start(wave_pause)

func _complete_demo() -> void:
    _spawn_timer.stop()
    _wave_timer.stop()
    emit_signal("all_waves_cleared")

func refresh_enemy_count() -> void:
    _emit_enemy_count()

func _emit_enemy_count() -> void:
    var remaining := _active_enemies + _enemies_to_spawn
    emit_signal("enemy_count_changed", remaining, _current_wave_total)

func _random_spawn_position() -> Vector2:
    var angle := randf_range(0.0, TAU)
    var offset := Vector2.RIGHT.rotated(angle) * spawn_radius
    return global_position + offset

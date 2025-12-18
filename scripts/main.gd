extends Node2D

@onready var player: Node = $Player
@onready var arena_manager: Node = $ArenaManager
@onready var ui: Control = $UI

var _is_game_over: bool = false
var _is_victory: bool = false

func _ready() -> void:
    randomize()
    if player.has_signal("health_changed"):
        player.connect("health_changed", Callable(ui, "update_health"))
    if player.has_signal("died"):
        player.connect("died", Callable(self, "_on_player_died"))

    spawner.connect("wave_started", Callable(self, "_on_wave_started"))
    spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))
    spawner.connect("all_waves_cleared", Callable(self, "_on_all_waves_cleared"))

    ui.update_health(player.health, player.max_health)
    ui.on_wave_started(arena_manager.current_wave)
    if arena_manager.has_method("refresh_enemy_count"):
        arena_manager.refresh_enemy_count()

func _on_wave_started(wave_number: int) -> void:
    ui.on_wave_started(wave_number)

func _on_wave_completed(wave_number: int) -> void:
    ui.on_wave_completed(wave_number)

func _on_player_died() -> void:
    _is_game_over = true
    if spawner.has_method("stop_spawning"):
        spawner.stop_spawning()
    ui.on_game_over()

func _on_all_waves_cleared() -> void:
    _is_victory = true
    if spawner.has_method("stop_spawning"):
        spawner.stop_spawning()
    ui.on_victory(spawner.current_wave)

func _process(_delta: float) -> void:
    if (_is_game_over or _is_victory) and Input.is_action_just_pressed("restart"):
        get_tree().reload_current_scene()

extends Node2D

@onready var player: Node = $Player
@onready var arena_manager: Node = $ArenaManager
@onready var ui: Control = $UI

func _ready() -> void:
    randomize()
    if player.has_signal("health_changed"):
        player.connect("health_changed", Callable(ui, "update_health"))
    if player.has_signal("died"):
        player.connect("died", Callable(self, "_on_player_died"))

    arena_manager.connect("wave_started", Callable(self, "_on_wave_started"))
    arena_manager.connect("wave_completed", Callable(self, "_on_wave_completed"))
    if arena_manager.has_signal("enemy_count_changed"):
        arena_manager.connect("enemy_count_changed", Callable(ui, "on_enemy_count_changed"))
    if arena_manager.has_signal("all_waves_cleared"):
        arena_manager.connect("all_waves_cleared", Callable(ui, "on_victory"))

    ui.update_health(player.health, player.max_health)
    ui.on_wave_started(arena_manager.current_wave)
    if arena_manager.has_method("refresh_enemy_count"):
        arena_manager.refresh_enemy_count()

func _on_wave_started(wave_number: int) -> void:
    ui.on_wave_started(wave_number)

func _on_wave_completed(wave_number: int) -> void:
    ui.on_wave_completed(wave_number)

func _on_player_died() -> void:
    if arena_manager.has_method("stop_spawning"):
        arena_manager.stop_spawning()
    ui.on_game_over()

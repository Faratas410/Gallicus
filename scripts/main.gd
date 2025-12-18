extends Node2D

@onready var player: Node = $Player
@onready var spawner: Node = $Spawner
@onready var ui: Control = $UI

func _ready() -> void:
    randomize()
    if player.has_signal("health_changed"):
        player.connect("health_changed", Callable(ui, "update_health"))
    if player.has_signal("died"):
        player.connect("died", Callable(self, "_on_player_died"))

    spawner.connect("wave_started", Callable(self, "_on_wave_started"))
    spawner.connect("wave_completed", Callable(self, "_on_wave_completed"))

    ui.update_health(player.health, player.max_health)
    ui.on_wave_started(spawner.current_wave)

func _on_wave_started(wave_number: int) -> void:
    ui.on_wave_started(wave_number)

func _on_wave_completed(wave_number: int) -> void:
    ui.on_wave_completed(wave_number)

func _on_player_died() -> void:
    if spawner.has_method("stop_spawning"):
        spawner.stop_spawning()
    ui.on_game_over()

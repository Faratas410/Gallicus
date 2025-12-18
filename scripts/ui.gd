extends Control

@onready var _health_label: Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var _wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var _game_over_label: Label = $GameOverLabel

func update_health(current: int, maximum: int) -> void:
    _health_label.text = "HP: %d / %d" % [current, maximum]

func on_wave_started(wave_number: int) -> void:
    _wave_label.text = "Wave %d" % max(wave_number, 1)
    _game_over_label.visible = false

func on_wave_completed(wave_number: int) -> void:
    _wave_label.text = "Wave %d cleared" % wave_number

func on_game_over() -> void:
    _game_over_label.visible = true

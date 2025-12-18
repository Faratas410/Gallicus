extends Control

@onready var _health_label: Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var _wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var _enemy_label: Label = $MarginContainer/VBoxContainer/EnemiesLabel
@onready var _overlay: Control = $Overlay
@onready var _message_label: Label = $Overlay/CenterContainer/VBoxContainer/MessageLabel
@onready var _hint_label: Label = $Overlay/CenterContainer/VBoxContainer/HintLabel

func update_health(current: int, maximum: int) -> void:
    _health_label.text = "HP: %d / %d" % [current, maximum]

func on_wave_started(wave_number: int) -> void:
    _wave_label.text = "Wave %d" % max(wave_number, 1)
    _overlay.visible = false

func on_wave_completed(wave_number: int) -> void:
    _wave_label.text = "Wave %d cleared" % wave_number

func on_game_over() -> void:
    _show_overlay("Game Over")

func on_victory() -> void:
    _show_overlay("Victory (Demo)")

func on_enemy_count_changed(remaining: int, total: int) -> void:
    if total > 0:
        _enemy_label.text = "Nemici rimasti: %d / %d" % [remaining, total]
    else:
        _enemy_label.text = "Nemici rimasti: %d" % remaining

func _show_overlay(message: String) -> void:
    _message_label.text = message
    _hint_label.text = "Premi R per ricominciare"
    _overlay.visible = true

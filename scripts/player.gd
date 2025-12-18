extends CharacterBody2D

signal health_changed(current, maximum)
signal died

@export var move_speed: float = 220.0
@export var max_health: int = 100
@export var melee_damage: int = 20
@export var melee_cooldown: float = 0.5

var health: int
var _cooldown: float = 0.0

@onready var _melee_area: Area2D = $MeleeArea

func _ready() -> void:
    health = max_health
    add_to_group("player")
    _melee_area.monitoring = true
    _melee_area.monitorable = true
    emit_signal("health_changed", health, max_health)

func _physics_process(delta: float) -> void:
    _handle_movement(delta)
    _handle_melee(delta)

func _handle_movement(delta: float) -> void:
    var input_vector := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    )

    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()

    velocity = input_vector * move_speed
    move_and_slide()

func _handle_melee(delta: float) -> void:
    _cooldown = max(_cooldown - delta, 0.0)
    if Input.is_action_just_pressed("attack") and _cooldown <= 0.0:
        _cooldown = melee_cooldown
        _perform_melee_attack()

func _perform_melee_attack() -> void:
    for body in _melee_area.get_overlapping_bodies():
        if body == self:
            continue
        if body.has_method("take_damage"):
            body.take_damage(melee_damage)

func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    emit_signal("health_changed", health, max_health)

    if health <= 0:
        _on_death()

func _on_death() -> void:
    emit_signal("died")
    set_process(false)
    set_physics_process(false)
    queue_free()

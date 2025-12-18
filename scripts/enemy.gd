extends CharacterBody2D

signal died

@export var move_speed: float = 140.0
@export var max_health: int = 30
@export var contact_damage: int = 10
@export var damage_cooldown: float = 0.8

var health: int
var _target: Node2D
var _arena_manager: Node
var _damage_timer: float = 0.0

@onready var _damage_area: Area2D = $DamageArea

func _ready() -> void:
    health = max_health
    add_to_group("enemies")
    _target = get_tree().get_first_node_in_group("player")
    add_to_group("enemies")

func _physics_process(delta: float) -> void:
    if not is_instance_valid(_target):
        _target = get_tree().get_first_node_in_group("player")
        return

    _damage_timer = max(_damage_timer - delta, 0.0)

    var direction := _target.global_position - global_position
    if direction.length() > 1.0:
        velocity = direction.normalized() * move_speed
    else:
        velocity = Vector2.ZERO

    move_and_collide(velocity * delta)
    _handle_contact_damage()

func _handle_contact_damage() -> void:
    if _damage_timer > 0.0:
        return

    for body in _damage_area.get_overlapping_bodies():
        if body == self:
            continue

        if body.is_in_group("player") and body.has_method("take_damage"):
            body.take_damage(contact_damage)
            _damage_timer = damage_cooldown
            break

func take_damage(amount: int, from_position: Vector2 = global_position) -> void:
    health -= amount
    if health <= 0:
        _on_death()

func _on_death() -> void:
    if is_instance_valid(_arena_manager) and _arena_manager.has_method("on_enemy_died"):
        _arena_manager.on_enemy_died(self)

    emit_signal("died")
    queue_free()

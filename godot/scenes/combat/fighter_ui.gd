class_name FighterUI extends Control

@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
var combat_sprite: CombatSprite
@export var opponent: FighterUI
@onready var shaker = $Shaker
@onready var health_change_effect = $HealthChangeEffect

## Indica si esta instancia es el jugador
@export var is_player: bool = false

@export var max_health: int = 300

var current_health: int:
	get = _get_current_health,
	set = _set_current_health

@export var attack_power: int = 10
@export var heal_power: int = 10

var already_attacked_this_turn: bool = false

func _get_current_health():
	if is_player:
		return PlayerStatus.current_health
	else:
		return current_health

func _set_current_health(new_health):
	if is_player:
		PlayerStatus.current_health = new_health
	else:
		current_health = new_health

func _ready():
	if(not combat_sprite):
		combat_sprite = $SpritePivot/Sprite
	# Si es necesario, por única vez en todo el juego se inicia la salud del jugador:
	if is_player:
		if PlayerStatus.current_health == 0:
			PlayerStatus.current_health = max_health

	# En caso no sea el jugador, la vida será la cantidad máxima al iniciar cada combate:
	else:
		current_health = max_health

	health_bar.max_value = max_health
	health_bar.value = current_health
	combat_sprite.hit_landed.connect(self.on_sprite_animation_hit_landed)


func attack():
	already_attacked_this_turn = true
	opponent.be_hurted(attack_power)


func on_sprite_animation_hit_landed():
	attack()


func play_attack():
	already_attacked_this_turn = false
	z_index += 1
	await combat_sprite.play_attack()
	if(not already_attacked_this_turn):
		attack()
	z_index -= 1


func be_hurted(amount: int):
	health_change_effect.play_hurt(amount)
	shaker.shake()
	combat_sprite.play_hurt()
	current_health = move_toward(current_health, 0, amount)


func heal():
	health_change_effect.play_heal(heal_power)
	current_health = move_toward(current_health, max_health, heal_power)
	
	await combat_sprite.play_heal()


func _process(delta):
	health_bar.value = move_toward(health_bar.value, current_health, delta * 70.0)
	health_label.text = "%s/%s" % [floor(health_bar.value), max_health]


func replace_sprite(new_combat_sprite: CombatSprite):
	if(not combat_sprite):
		combat_sprite = $SpritePivot/Sprite
	$SpritePivot.remove_child(combat_sprite)
	combat_sprite.queue_free()
	$SpritePivot.add_child(new_combat_sprite)
	combat_sprite = new_combat_sprite

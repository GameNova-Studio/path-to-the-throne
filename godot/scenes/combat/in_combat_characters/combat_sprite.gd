class_name CombatSprite extends CanvasItem

signal hit_landed

@onready var animation_player = $AnimationPlayer
@onready var ataque_sonido: AudioStreamPlayer2D = $AtaqueSonido

@export var attack_animation_names: Array[String] = []
@export var heal_animation_names: Array[String] = []
@export var hurt_animation_names: Array[String] = []


func land_hit() -> void:
	hit_landed.emit()
	$AtaqueSonido.play()


func play_attack() -> void:
	await play_one_of(attack_animation_names)


func play_heal() -> void:
	await play_one_of(heal_animation_names)


func play_hurt() -> void:
	await play_one_of(hurt_animation_names)


func play_one_of(animation_names) -> void:
	if animation_names.is_empty():
		await get_tree().process_frame
		return

	var animation: String = animation_names.pick_random()

	if(animation in animation_player.get_animation_list()):
		animation_player.play(animation)

		await animation_player.animation_finished
	else:
		await get_tree().process_frame

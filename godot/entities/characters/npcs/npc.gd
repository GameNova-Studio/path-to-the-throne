@tool
class_name NPC extends CharacterBody2D
## Un NPC (Non-playable character) es un personaje del juego que no es 
## controlado por el jugador.

@export var npc_name: String = "NPC"
@export var _interaction_name: String = "Hablar"

## Establece el conjunto de sprites animados a usar
## para este NPC (non playable character).
@export var sprite_frames: SpriteFrames :
	set(new_sprite_frames):
		sprite_frames = new_sprite_frames
		if(is_inside_tree()):
			load_animation()

func load_animation():
	%AnimatedSprite2D.sprite_frames = sprite_frames
	if(sprite_frames.has_animation("idle")):
		%AnimatedSprite2D.play("idle")

func _ready():
	load_animation()

func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		# Prevenimos que se guarde un frame_progress distinto para
		# la animación cada vez que se guarda una escena NPC:
		%AnimatedSprite2D.stop()

	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		# Como la animación se pudo haber detenido antes de guardar la
		# escena, volvemos a cargarla y reproducirla si es necesario:
		load_animation()

func interact_with(_player):
	await Dialogue.say_line(npc_name, "Hola!")

func interaction_name() -> String:
	return _interaction_name

func combat(
	in_combat_character: FighterCharacter = null
) -> CombatScreen.Outcome:
	var combat_scene: CombatScreen = load("res://scenes/combat/combat_screen.tscn").instantiate()
	
	combat_scene.configure(in_combat_character)
	
	SceneChanger.change_scene_to(combat_scene)

	var outcome = await combat_scene.finished

	SceneChanger.back_to_last_scene()

	return outcome


func say(line):
	await Dialogue.say_line(npc_name, line)

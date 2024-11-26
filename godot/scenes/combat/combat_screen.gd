class_name CombatScreen extends Control
## Clase asociada a la pantalla de combate.

## AnimatinoPlayer encargado de mostrar y esconder las interfaces de opciones
## de combate.
@onready var menu_turn_animation_player = %MenuTurnAnimationPlayer
## Interfaz de opciones de combate del jugador, muestra lo que puede hacer en su turno.
@onready var choose_attack = %ChooseAttackMenu
## Interfaz de opciones de combate del enemigo, muestra un minijuego a superar.
@onready var enemy_attack_minigame = %EnemyAttackMinigameMenu
## Nodo que representa al jugador, con su salud, animaciones, sprite, etc.
@onready var player = %Player
## Nodo que representa al oponente, con su salud, animaciones, sprite, etc.
@onready var enemy = %Enemy
## Botón de ayuda, muestra la ayuda descripta en [method CombatScreen.help]
@onready var help_button = %HelpButton
## Mensaje de ayuda a mostrar cuando se ejecuta [method CombatScreen.help] y
## el [enum CombatScreen.Turn] es [enum CombatScreen.Turn.Player]
@export_multiline var help_message_player_turn: String
## Mensaje de ayuda a mostrar cuando se ejecuta [method CombatScreen.help] y
## el [enum CombatScreen.Turn] es [enum CombatScreen.Turn.Enemy]
@export_multiline var help_message_enemy_turn: String
## Turno actual
var turn: Turn = Turn.Player
## ¿Se mostró ya la explicación de como se juega en el turno del jugador?
var player_help_shown: bool = false
## ¿Se mostró ya la explicación de como se juega en el turno del oponente?
var enemy_help_shown: bool = false

## Se emite cuando finaliza un combate, el parámetro es el resultado del combate,
## que indica si el jugador ganó o perdió.
signal finished(outcome: Outcome)

## Posibles resultados de un combate.
enum Outcome {
	PlayerWon,
	PlayerLost
}

## Posibles valores para el turno.
enum Turn {
	Player,
	Enemy
}

## Configurar la escena de combate con un [FighterCharacter] que se provee
## por parámetro. Si no se hace esto, el combate se llevará a cabo con el
## oponente por defecto.
func configure(
	in_combat_character: FighterCharacter
	) -> void:
		enemy = %Enemy
		enemy_attack_minigame = %EnemyAttackMinigameMenu
		if(not in_combat_character):
			return
		enemy.max_health = in_combat_character.hp
		enemy.attack_power = in_combat_character.attack_power
		var enemy_combat_sprite = in_combat_character.combat_sprite()
		if(enemy_combat_sprite != null):
			enemy.replace_sprite(enemy_combat_sprite)
		var minigames = in_combat_character.minigames
		if(not minigames.is_empty()):
			enemy_attack_minigame.minigames = minigames


func _ready():
	help_button.pressed.connect(self.help)
	play_turns()

## El loop principal del combate. Mientras tanto [member CombatScreen.player] como
## [member CombatScreen.enemy] tengan vida, se juega un turno.[br]
## Si la vida de alguno de los dos llega a 0, se finaliza el combate con uno
## de los resultados especificados en [enum CombatScreen.Outcome]
func play_turns() -> void:
	while player.current_health > 0 and enemy.current_health > 0:
		await play_a_turn()

	if enemy.current_health <= 0:
		$BackgroundMusic.stop()
		$VictoryFanfare.play()
		await $VictoryFanfare.finished
		finished.emit(Outcome.PlayerWon)
	elif player.current_health <= 0:
		await wait_seconds(1.0)
		finished.emit(Outcome.PlayerLost)
	##Se actualiza la vida del jugador al terminar el combate
	PlayerStatus.update_health(player.current_health)

## Mostrar el diálogo de ayuda que explica que hacer. Cambia el texto según
## si se está en el turno del jugador o del oponente.
func help() -> void:
	match turn:
		Turn.Player:
			player_help_shown = true
			Dialogue.say_multiple_lines("Oscar", help_message_player_turn.split("\n"))
		Turn.Enemy:
			enemy_help_shown = true
			Dialogue.say_multiple_lines("Oscar", help_message_enemy_turn.split("\n"))

## Jugar un turno. Según si es el turno del jugador o del enemigo, se muestra
## la interfaz de usuario correspondiente, y se espera a que el turno se realice
## para cambiar a quien le toca jugar.
func play_a_turn() -> void:
	match turn:
		Turn.Player:
			choose_attack.setup_turn()
			
			if(not player_help_shown):
				help()

			menu_turn_animation_player.queue("show_player_ui")

			await menu_turn_animation_player.animation_finished
			
			choose_attack.enable_buttons()

			await choose_attack.player_chose_option
			
			choose_attack.disable_buttons()

			menu_turn_animation_player.queue("hide_player_ui")

			await choose_attack.player_turn_finished
			
			turn = Turn.Enemy
		Turn.Enemy:
			enemy_attack_minigame.setup_turn()
			
			if(not enemy_help_shown):
				help()

			menu_turn_animation_player.queue("show_enemy_ui")

			await menu_turn_animation_player.animation_finished

			await enemy_attack_minigame.player_chose_option

			menu_turn_animation_player.queue("hide_enemy_ui")

			await enemy_attack_minigame.enemy_turn_finished
			
			turn = Turn.Player

## Función auxiliar que permite esperar que pasen unos segundos antes de
## realizar otra tarea.
func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _process(delta):
	if Input.is_action_just_released("salir_batalla"):
		finished.emit(Outcome.PlayerLost)

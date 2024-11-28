class_name EnemyAttackMiniGame extends Control

@export var minigames: Array[MiniGame]
@onready var enemy = %Enemy
@onready var enemy_status = %Enemy/Status #Cuadro para colocar multiplicador del enemigo
@export var combat: CanvasItem
@onready var animation_player = $AnimationPlayer
@onready var minigame_container = $MinigameContainer
@onready var timer_bar = $"../TimerBar"

var minigame_scene


signal player_chose_option
signal enemy_turn_finished


enum MinigameOutCome {
	Success,
	Failure
}

## Nuevas acciones para el enemigo
enum EnemyAction {
	Attack,
	Multiply,
	Divider
}

var prob = { EnemyAction.Attack: 0.5, EnemyAction.Multiply: 0.3, EnemyAction.Divider: 0.2 }

func timer_time_out():
	minigame_scene.fail()
	
func setup_turn():
	## Solo si hay un efecto se mostrará el cuadro con el efecto sobre el enemigo
	enemy_status.text = "x%s" % enemy.multi_power
	if enemy.multi_power == 1:  enemy_status.text = ""
	enemy_status.visible = enemy_status.text != ""

	minigame_scene = create_next_minigame()

	var outcome: int = await minigame_scene.completed

	player_chose_option.emit()
	
	timer_bar.timer.paused = true

	if(outcome >= 100):
		animation_player.play("correct_message")

		await animation_player.animation_finished

		animation_player.play("hide_message")
	else:
		## El enemigo elige una opción
		await enemy_action_selection()

	enemy_turn_finished.emit()
	

## Aquí se elige que acción toma el enemigo de manera aleatoria
func enemy_action_selection():
	var random_value = randf() # genera un numero entre 0 y 1
	var acum_prob = 0

	## Se compara el valor random obtenido con los valores de cada posibilidad
	for action in prob.keys(): 
		acum_prob += prob[action] # acumulamos el valor de las posibilidades
		## Si el valor encontrado es menor o igual a la probabilidad se selecciona
		if random_value <= acum_prob: 
			match action:
				EnemyAction.Attack:
					await enemy.play_attack()

				EnemyAction.Multiply:
					if enemy.multi_power == 1: # para activarse debe tener el multiplicador neutro
						enemy.multi_power = randi_range(2,3) # multiplicador es x2 o x3
						await enemy.multiplier() # se ejecuta animación del multiplier
					else:
						await enemy.play_attack()

				EnemyAction.Divider:
					if enemy.divider_use == false: # solo entra si no se ha usado el divider
						enemy.divider_use = true # aseguramos que no se repita si ya se uso
						await enemy.divider()
					else:
						await enemy.play_attack()
			break

func create_next_minigame():
	if(minigame_scene):
		minigame_scene.queue_free()

	var minigame: MiniGame = minigames.pick_random()

	minigame_scene = minigame.scene()

	minigame_container.add_child(minigame_scene, true)
	
	return minigame_scene

class_name EnemyAttackMiniGame extends Control

@export var minigames: Array[MiniGame]
@onready var enemy = %Enemy
@export var combat: CanvasItem
@onready var animation_player = $AnimationPlayer
@onready var minigame_container = $MinigameContainer

var minigame_scene


signal player_chose_option
signal enemy_turn_finished


enum MinigameOutCome {
	Success,
	Failure
}


func cuando_termina_el_tiempo():
	minigame_scene.fail()


func setup_turn():
	minigame_scene = create_next_minigame()

	var outcome: int = await minigame_scene.completed

	player_chose_option.emit()

	if(outcome >= 100):
		animation_player.play("correct_message")

		await animation_player.animation_finished

		animation_player.play("hide_message")
	else:
		await enemy.play_attack()

	enemy_turn_finished.emit()
	


func create_next_minigame():
	if(minigame_scene):
		minigame_scene.queue_free()

	var minigame: MiniGame = minigames.pick_random()

	minigame_scene = minigame.scene()

	minigame_container.add_child(minigame_scene, true)
	
	return minigame_scene

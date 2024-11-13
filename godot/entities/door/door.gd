extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var tiempo = $Timer
@export_file("*.tscn") var next_scene: String


func interact_with(player):
	if(next_scene):
		# Se reinicia el inventario antes de cambiar de nivel
		Inventory.reset_inventory()
		# Espera a que el cuerpo del personaje termine de entrar a la cueva.
		await player.open_door() 
		# Reproduce la animación de closed (se destruye la cueva)
		animated_sprite_2d.play("closed")
		# Inicia el temporizador para esperar un tiempo antes de cambiar de escena.
		tiempo.start()
		# Espera a que el temporizador se termine.
		await (tiempo.timeout)
		# Cambia a la siguiente escena.
		SceneChanger.change_scene_to_file(next_scene)
	else:
		await Dialogue.say_line("Arturo", "parece estar cerrada")

func interaction_name() -> String:
	return "Entrar"

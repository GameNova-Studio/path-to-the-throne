extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

# Variable que controla si el árbol ya ha sido cortado
var is_cut = false

# Se ejecuta al iniciar el nodo
func _ready():
	# Al iniciar,se reproduce la animación de "start"
	animated_sprite_2d.play("start")
	# Añade el pino al grupo "trees" para que el jugador lo detecte
	add_to_group("trees")

# Detecta cuando el jugador entra en el área de interacción
func _on_pine_tree_body_entered(body):
	if body.name == "player": 
		animated_sprite_2d.play("start")

# Interacción con el jugador
func interact_with(player):
	# Verifica si el árbol ya ha sido cortado
	if is_cut:
		return  # Si ya está cortado, no hace nada

	# Espera a que el jugador termine su animación de corte
	await player.cut_tree()
	# Cambia la animación del árbol a "end" después de que el jugador haya terminado de cortar
	animated_sprite_2d.play("end")
	
	# Marca el árbol como cortado para evitar futuras interacciones
	is_cut = true

func interaction_name() -> String:
	return "Cortar"

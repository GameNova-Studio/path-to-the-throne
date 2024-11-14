extends CharacterBody2D

const VELOCIDAD_CORRER = 50  # Constante para la velocidad del NPC
const DISTANCIA_LIMITE = 100  # Distancia en píxeles que se moverá a la izquierda y a la derecha

var posicion_inicial
var limite_izquierda
var limite_derecha

func _ready():
	# Configurar las posiciones límite basadas en la posición inicial
	posicion_inicial = position.x
	limite_izquierda = posicion_inicial - DISTANCIA_LIMITE
	limite_derecha = posicion_inicial + DISTANCIA_LIMITE
	
	velocity.x = VELOCIDAD_CORRER
	$AnimatedSprite2D.play("Corriendo")

func _physics_process(delta):
	# Cambiar la dirección si alcanza el límite izquierdo o derecho
	if position.x <= limite_izquierda:
		velocity.x = VELOCIDAD_CORRER
	elif position.x >= limite_derecha:
		velocity.x = -VELOCIDAD_CORRER

	# Actualizar la dirección del sprite según la velocidad
	$AnimatedSprite2D.flip_h = velocity.x < 0

	# Mover el NPC
	move_and_slide()

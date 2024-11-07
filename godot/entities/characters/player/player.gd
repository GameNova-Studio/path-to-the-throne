extends CharacterBody2D

## Velocidad de movimiento del personaje.
@export_range(10, 1000, 10) var SPEED = 300.0

## Velocidad de movimiento al correr del personaje.
@export_range(10, 1000, 10) var RUN_SPEED = 500.0

## Referencia al nodo que contiene las animaciones del personaje.
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

##Se inician las particulas que se generan al correr
@onready var run_particles = $CPUParticles2D

func _physics_process(_delta: float) -> void:
	# Reinicia la velocidad en cada frame.
	velocity = Vector2.ZERO
	if is_opening_door():
		return
		
	## Solo podemos movernos si no hay un dialogo abierto
	if not Dialogue.is_dialogue_open():
		##Variable temporal
		var V_SPEED=SPEED
		
		#Verifica si se presiona se está presionando la tecla para correr.
		if Input.is_action_pressed("sprint"):
			V_SPEED=RUN_SPEED
			#Se activan las particulas al correr
			run_particles.emitting=true
		else:
			#Se desactivan las particulas al dejar de correr
			run_particles.emitting=false
			
		# Verifica si se está presionando la tecla para moverse a la izquierda. (X)
		if Input.is_action_pressed("move_left"):
			velocity.x= -V_SPEED
			animated_sprite_2d.flip_h=true
			
		# Verifica si se está presionando la tecla para moverse hacia arriba. (Y)
		if Input.is_action_pressed("move_up"):
			velocity.y= -V_SPEED
			
		# Verifica si se está presionando la tecla para moverse a la derecha. (X)
		if Input.is_action_pressed("move_right"):
			velocity.x= V_SPEED
			animated_sprite_2d.flip_h=false
			
		# Verifica si se está presionando la tecla para moverse hacia abajo. (Y)
		if Input.is_action_pressed("move_down"):
			velocity.y= V_SPEED
	
	# Cambia la animación según si el jugador esta intentando mover al
	# personaje o no.
	if velocity.is_zero_approx():
		animated_sprite_2d.play("idle")
		#Se desactivan las particulas si el personaje no se mueve.
		run_particles.emitting=false
	else:
		animated_sprite_2d.play("running")
	
	# Mueve el personaje según la velocidad establecida y maneja las colisiones.
	move_and_slide()
	
# Función para entrar a la cueva. Reproduce la animación y espera a que termine.
func open_door():
	animated_sprite_2d.play("entrar")
	#Reproduce el sonido del personaje moviendo su espada.
	$golpe.play()
	await animated_sprite_2d.animation_finished
	
# Comprueba si se está reproduciendo la animación de entrar a la cueva.
func is_opening_door():
	return animated_sprite_2d.animation == "entrar"

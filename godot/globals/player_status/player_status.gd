class_name PlayerStatus extends Node

##Variable que almacena la vida del jugador
var health: int 

func update_health(current_health: int)  -> void:
	if current_health<=0:
		##Si la vida del jugador llega a 0, se aumenta 1 HP
		health=1
	else:
		##Se almacena el último estado del HP del jugador
		health=current_health

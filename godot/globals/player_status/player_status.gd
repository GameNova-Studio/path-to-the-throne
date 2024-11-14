extends Node

## Almacena la vida del jugador
var current_health: int:
	set = _set_current_health

func _set_current_health(new_health):
	# Si la vida del jugador llega a 0, se le otorga 1 HP
	if new_health <= 0:
		current_health = 1
	else:
		current_health = new_health

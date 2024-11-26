class_name ChooseAttackMenu extends Control
## Clase asociada a la interfaz de opciones del jugador.

@onready var attack_1 = %Attack1
@onready var attack_2 = %Attack2
@onready var heal = %Heal
## Asociamos el botón del multiplicador
@onready var multi = %Multiplier
@export var combat: CombatScreen
@onready var player = %Player

var attack_1_power: int
var attack_2_power: int
var heal_power: int
var multi_power: int # cantidad multiplicadora de ataque

signal player_chose_option
signal player_turn_finished

enum PlayerOption {
	Attack1,
	Attack2,
	Heal,
	Multi #se agrega el multiplicador
}

## Configura el turno del jugador
func setup_turn():
	calculate_random_values_for_attack_and_heal()
	attack_effects() #
	## La opción del multiplier se mostrará cuando tenga un valor neutro
	multi.visible = player.multi_power == 1

## Muestra los efectos exactos en los ataques
func attack_effects():
	var effect_power = player.multi_power * player.divider_power
	
	## Se mostrará el número por el cual se multiplicará
	attack_1.status.text = "x%s" % effect_power
	attack_2.status.text = "x%s" % effect_power
	
	## Aseguramos que no se muestre el cuadro si es que no tiene efecto
	if effect_power == 1: 
		attack_1.status.text = ""
		attack_2.status.text = "" 
	attack_1.status.visible = attack_1.status.text != ""
	attack_2.status.visible = attack_2.status.text != ""

## Habilita los botones para que se puedan clickear
func enable_buttons():
	for option_button in [attack_1, attack_2, heal, multi]:
		option_button.disabled = false

## Deshabilita los botones para que no se puedan clickear
func disable_buttons():
	for option_button in [attack_1, attack_2, heal, multi]:
		option_button.disabled = true

## Según la opción de botón elegida, ejecuta una acción acorde.
## También, deshabilita los botones y señaliza el fin del turno del jugador
## luego de que se reproduzca la acción.
func option_chosen(option: PlayerOption):
	disable_buttons()
	player_chose_option.emit()

	match option:
		PlayerOption.Attack1:
			player.attack_power = attack_1_power
			await player.play_attack()
		
		PlayerOption.Attack2:
			player.attack_power = attack_2_power
			await player.play_attack()

		PlayerOption.Heal:
			player.heal_power = heal_power
			await player.heal()

		## Se ejecuta la multiplicación del ataque
		PlayerOption.Multi:
			player.multi_power = multi_power
			await player.multiplier()

	player_turn_finished.emit()

## Se conectan las señales [code]pressed[/code] de los botones de acciones
## al método option_chosen, pasando como parámetro la acción elegida.
func _ready():
	attack_1.pressed.connect(func(): option_chosen(PlayerOption.Attack1))
	attack_2.pressed.connect(func(): option_chosen(PlayerOption.Attack2))
	heal.pressed.connect(func(): option_chosen(PlayerOption.Heal))
	## La reacción del botón del multiplier
	multi.pressed.connect(func(): option_chosen(PlayerOption.Multi))
	disable_buttons()

## Se calculan valores al azar para los ataques, la curación y multiplicador.[br]
## También se completa el texto de los botones de manera que reflejen
## el daño, curación o multiplicador que representaran.
func calculate_random_values_for_attack_and_heal():
	# Todos los turnos, hacemos que haya un ataque fuerte (entre 51 y 100 de
	# daño), y un atauqe debil (entre 1 y 50 de daño)
	var strong_attack: int = randi_range(51, 100)
	var weak_attack: int = randi_range(1, 50)
	var attack_powers = [strong_attack, weak_attack]
	# Cual ataque es cual se calcula al azar, shuffle hace que la lista quede
	# en un orden aleatorio
	attack_powers.shuffle()
	# Entonces cuando sacamos el primer y ultimo elemento para definir el poder
	# de cada ataque, no sabemos de antemano cual es el ataque débil y el fuerte.
	attack_1_power = attack_powers.front()
	attack_2_power = attack_powers.back()
	# El poder de curación se calcula al azar entre 1 y 100.
	heal_power = randi_range(1, 100)
	# El número con el que se multiplicará el ataque
	multi_power = randi_range(2,3)
	# Los textos de las opciones se escriben en inglés en vez de con números.
	attack_1.text = "Cut\nDamage: %s" % number_to_word(attack_1_power)
	attack_2.text = "Slash\nDamage: %s" % number_to_word(attack_2_power)
	heal.text = "Eat apple\nHeal: %s" % number_to_word(heal_power)
	multi.text = "Multiply\nMultiplier: %s" % number_to_word(multi_power)

## Dado un número entero, devuelve el nombre del número en inglés.
## Soporta números entre 1 y 100.[br]
## [b]DESAFIO:[/b] modificar este método para que soporte números hasta 1000.
func number_to_word(number: int) -> String:
	var digits: Array[String] = [
		"zero", "one", "two", "three", "four", "five",
		"six", "seven", "eight", "nine"
	]
	var teens: Array[String] = [
		"eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
		"seventeen", "eighteen", "nineteen"
	]
	var tens: Array[String] = [
		"ten", "twenty", "thirty", "fourty", "fifty",
		"sixty", "seventy", "eighty", "ninety"
	]
	if(number >= 0 and number <= 9):
		return digits[number]
	elif(number == 10):
		return tens[0]
	elif(number >= 11 and number <= 19):
		return teens[number - 11]
	elif(number >= 20 and number <= 99):
		var ten_part: int = number / 10
		var unit_part: int = number % 10
		var ten_part_as_word: String = tens[ten_part - 1]
		if(unit_part == 0):
			return ten_part_as_word
		else:
			return str(ten_part_as_word, " ", number_to_word(unit_part))
	elif(number == 100):
		return "one hundred"
	else:
		push_warning("number_to_word only works for integers betwen 0 to 100,\
			returning number as a string but not as a word: ", number)
		return str(number)

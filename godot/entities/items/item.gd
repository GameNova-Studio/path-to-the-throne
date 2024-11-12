@tool

class_name Item extends Node
## Objeto que puede ser agregado al inventario del jugador

## Tipos de objeto que existen.[br]
## Para agregar un nuevo tipo de objeto lo que se debe hacer es:[br]
## - Agregarlo al [enum Item.Type][br]
## - Agregar una línea al diccionario [member Item.textures] con una textura
## para el nuevo objeto.[br]
## - Agregar una línea al método [method Item.english_name_of] con el nombre
## en inglés del objeto.
enum Type {
	Calabaza,
	Carne,
	Dinero,
	Hongo,
	Hueso,
	Oveja,
	Tronco,
	Papiro
}

## Diccionario que relacionada cada objeto definido en [enum Item.Type] con
## una [Texture2D].
const textures: Dictionary = {
	Type.Calabaza: preload("res://entities/items/textures/pumpkin.png"),
	Type.Carne: preload("res://entities/items/textures/meat.png"),
	Type.Dinero: preload("res://entities/items/textures/gold.png"),
	Type.Hongo: preload("res://entities/items/textures/mushroom.png"),
	Type.Hueso: preload("res://entities/items/textures/bone.png"),
	Type.Oveja: preload("res://entities/items/textures/sheep.tres"),
	Type.Tronco: preload("res://entities/items/textures/log.png"),
	Type.Papiro: preload("res://entities/items/textures/papyrus.png")
}

## Dado un [enum Item.Type], devuelve la [Texture2D] correspondiente.
static func texture_for(item_type: Type) -> Texture2D:
	return textures[item_type]

## Dado un [enum Item.Type], devuelve su nombre en español.
static func name_of(item_type: Type) -> String:
	return Item.Type.keys()[item_type]

## Dado un [enum Item.Type], devuelve su nombre en inglés.
static func english_name_of(item_type: Type) -> String:
	return {
		Type.Calabaza: "Pumpkin",
		Type.Carne: "Meat",
		Type.Dinero: "Money",
		Type.Hongo: "Mushroom",
		Type.Hueso: "Bone",
		Type.Oveja: "Sheep",
		Type.Tronco: "Log",
		Type.Papiro: "Papyrus"
	}[item_type]

## Tipo del objeto. Debe ser uno de los definidos en [enum Item.Type]
@export var type: Type:
	set(new_type): ## El setter custom modifica el sprite cuando elegimos
				   ## el tipo de objeto.
		type = new_type
		## [code]is_inside_tree()[/code] es necesario para que no se intente
		## acceder al Sprite2D antes de que el nodo esté en el arbol de escena.
		if(is_inside_tree()): 
			update_image()
## El nodo que muestra la imagen del objeto.
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collect=  $collecting
var col=false
func _ready():
	## En ready, actualizamos el sprite.
	update_image()
## Al interactuar con el jugador, el objeto se agrega al [code]Inventory[/code]
## y desaparece del nivel.[br][br]
## Este método es parte de la interfaz explicada en [InteractionRayCast].
func interact_with(_player):
	collect.play()
	await collect.finished
	## Agregamos el objeto al inventario
	Inventory.add_item(type)
	## Lo liberamos
	self.queue_free()
	
	

## Devuelve el nombre de interacción que aparece cuando el jugador está
## cerca del objeto.[br][br] 
## Este método es parte de la interfaz explicada en [InteractionRayCast].
func interaction_name() -> String:
	return "Recoger"

## Método que actualiza el sprite según el [member Item.type].
func update_image() -> void:
	sprite_2d.texture = texture_for(type)

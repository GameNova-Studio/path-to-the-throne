class_name InventorySystem extends CanvasLayer
## InventorySystem es una clase usada por el [url=https://docs.godotengine.org/es/4.x/tutorials/scripting/singletons_autoload.html]singleton[/url]
## Inventory para modificar y mostrar el inventario del jugador.
##
## La forma de abrir dialogos es usando directamente el [url=https://docs.godotengine.org/es/4.x/tutorials/scripting/singletons_autoload.html]singleton[/url]
## Inventory desde cualquier lugar del código.
## [br]
## Esta clase [b]no[/b] debería instanciarse directamente.
## [br][br]
## Ejemplos de uso:
## [codeblock]
## # Chequear si existe un objeto en el inventario.
## if(Inventory.has(Item.Type.Oveja)):
##   print("tiene una oveja")
## [/codeblock]
## [codeblock]
## # Agregar un objeto al inventario.
## Inventory.add_item(Item.Type.Dinero)
## [/codeblock]
## [codeblock]
## # Chequear cuantos de cierto objeto hay en el inventario
## var cantidad_de_hongos: int = Inventory.amount_of(Item.Type.Hongo)
## print("Hay %s hongos en el inventario" % cantidad_de_hongos)
## [/codeblock]
## [codeblock]
## # Abrir el menu del inventario y mostrar que se eligió
## var objeto_elegido = await Inventory.choose_item()
## if(objeto_elegido != null):
##   print("Se eligió %s" % Item.name_of(objeto_elegido))
## [/codeblock]
##
## @tutorial(¿Qué es un singleton?): https://docs.godotengine.org/es/4.x/tutorials/scripting/singletons_autoload.html

## Escena que representa un objeto dentro del inventario.
const INVENTORY_ITEM = preload("res://globals/inventory/inventory_item.tscn")
## Panel que contiene a los objetos.
@onready var items_container = %ItemsContainer
## Botón para salir del inventario.
@onready var close_button = %CloseButton

## Se emite cuando el inventario se abre.
signal opened
## Se emite cuando el inventario se cierra.[br]
## Si el inventario se cerró porque se eligió un objeto, ese objeto es el
## que llega como parámetro de la señal.[br]
## Si el inventario se cerró sin elegir un objeto (por ejemplo, apretando
## el botón de cerrar), llegará null como parámetro de la señal.
signal closed(selected_item)
## Se emite cuando se selecciona un objeto.
signal item_selected(item)

## Diccionario que tiene como clave el tipo de objeto y como
## valores la cantidad de ese objeto que hay en el inventario.
var items: Dictionary


## Agrega un objeto del tipo especificado al inventario.
func add_item(item: Item.Type) -> void:
	## Si el objeto no existe en el diccionario, lo creamos con 0 como
	## valor de esa clave.
	if(not items.has(item)):
		items[item] = 0
	## Una vez ya nos aseguramos que el objeto existe en el inventario,
	## aumentamos el valor que representa a la cantidad en 1.
	items[item] += 1

## Elimina un objeto del tipo especificado del inventario.
func remove_item(item: Item.Type) -> void:
	## Si el objeto no está en el inventario no hacemos nada.
	if not self.has(item):
		return
	
	## Disminuimos el valor de ese objeto en el diccionario items por 1.
	items[item] -= 1
	
	## Si ya no queda ninguno de ese item, lo borramos del diccionario.
	if(items[item] <= 0):
		items.erase(item)

## Devuelve si cierto tipo de objeto existe en el inventario.
func has(item: Item.Type) -> bool:
	return items.has(item)

## Devuelve la cantidad de cierto tipo de objeto en el inventario.
func amount_of(item: Item.Type) -> int:
	return items.get(item, 0)

## Devuelve si el inventario está completamente vacío.
func is_empty() -> bool:
	return items.is_empty()


func _ready():
	close()

## Devuelve [code]true[/code] si el menú de inventario está abierto, y
## [code]false[/code] en caso contrario.
func is_open() -> bool:
	return visible

## Abre el menú de inventario.[br]
## Emite la señal [signal opened].
func open() -> void:
	## Borramos todos los nodos de objetos que hayan en el menu.
	_clean_items()
	## Llenamos el menu de nodos para cada tipo de objeto.
	_populate_items(items)
	## Hacemos visible el menú.
	visible = true
	## Emitimos la señal opened
	opened.emit()
	## Si en el nodo que contiene a los items existe al menos uno,
	## obtenemos al primero y le otorgamos foco.
	if(items_container.get_child_count() > 0):
		var first_item = items_container.get_children().front()
		first_item.grab_focus()

## Cierra el menú del inventario.[br]
## Emite la señal [signal closed] con [param item] como parámetro.[br]
## Si se paso un [param item] no nulo, también se emite la señal
## [signal item_selected]
func close(item = null) -> void:
	## Hacemos invisible al inventario
	visible = false
	## Emitimos la señal closed
	closed.emit(item)
	## Si se pasó como parámetro un objeto al cerrar el inventario
	## emitimos la señal item_selected
	if(item != null):
		item_selected.emit(item)

## Reinicia el inventario, borrando todos los items.
func reset_inventory() -> void:
	items.clear()

## Abre el inventario y espera hasta que se haya elegido un objeto.
## Retorna el objeto elegido si se eligió alguno.
## Si se cerró el inventario sin elegir ningún objeto, retorna null.[br]
## [b]IMPORTANTE: [/b] este metodo debe ser usado con [code]await[/code][br]
## Ejemplo:
## [codeblock]
## var item = await Inventory.choose_item()
## if(item == null):
##   print("No se eligió ningún objeto")
## else:
##   print("Se eligió %s" % Item.name_of(item))
## [/codeblock]
func choose_item():
	open()
	var selected_item_name = await closed
	return selected_item_name

# Borra los nodos que representan objetos del menu del inventario.
func _clean_items() -> void:
	for inventory_item in items_container.get_children():
		# Es importante primero sacarlos del árbol de escena con
		# remove_child antes de liberarlos con queue_free porque
		# si no items_container.get_children() seguirá incluyendo
		# a esos nodos hasta el momento en el que sean efectivamente borrados.
		# ¡Esto es porque queue_free no borra a los nodos instantaneamente!
		items_container.remove_child(inventory_item)
		inventory_item.queue_free()

# Agrega un nodo al menú por cada objeto del inventario
func _populate_items(items_to_show) -> void:
	# Las claves del diccionario son los tipos de objetos
	for item in items_to_show.keys():
		# Para cada tipo de objeto obtenemos la cantidad
		var item_amount: int = items_to_show[item]
		# Creamos un nodo de tipo InventoryItem
		var inventory_item = _create_inventory_item(item, item_amount)
		# Agregamos ese nodo como hijo a items_container
		items_container.add_child(inventory_item, true)
		# Conectamos la señal item_selected del nodo IventoryItem
		# con el método _on_item_selected
		inventory_item.item_selected.connect(self._on_item_selected)


func _on_item_selected(item: Item.Type):
	# Cuando se elige un objeto, cerramos el inventario y pasamos como
	# parámetro el objeto elegido para que se emita la señal closed
	close(item)

# Crea un nodo del tipo InventoryItem a partir de un tipo de objeto y una
# cantidad de ese objeto
func _create_inventory_item(item: Item.Type, amount_of_items: int) -> InventoryItem:
	var inventory_item = INVENTORY_ITEM.instantiate()
	inventory_item.item_type = item
	inventory_item.amount = amount_of_items
	
	return inventory_item

func _on_close_button_pressed():
	# Cuando se presiona el botón closed, cerramos el inventario
	close()

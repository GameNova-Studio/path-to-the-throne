extends GDTour

const DUPLICATE = preload("res://guided_tutorials/duplicate.png")
const SIMPLEST_LEVEL_SCENE_PATH = "res://scenes/levels/example_levels/simple_level/simple_level.tscn"
const TALKER_SCENE_PATH = "res://entities/prefabs/npcs/talker/talker.tscn"

func _build() -> void:
	context_set_2d()
	bubble_set_title("Creando un nivel básico")
	bubble_add_text(["Buenas, vamos a aprender a crear un nuevo nivel"])
	bubble_move_and_anchor(EditorInterface.get_base_control(), Bubble.At.BOTTOM_RIGHT)
	bubble_add_task_open_scene(
		SIMPLEST_LEVEL_SCENE_PATH,
		"Abre la escena simple_level.tscn"
	)
	highlight_filesystem_paths(
		[SIMPLEST_LEVEL_SCENE_PATH]
	)
	complete_step()
	bubble_add_text([
		"Esta es una escena con lo mínimo y necesario",
		"Dupliquemosla para crear nuestra propia escena"
	])
	bubble_add_texture(DUPLICATE)
	highlight_filesystem_paths(
		[SIMPLEST_LEVEL_SCENE_PATH]
	)
	complete_step()
	bubble_add_text([
		"Ahora, abramos la escena nueva"
	])
	complete_step()
	bubble_add_text([
		"Para correr la escena, se puede usar el boton Run Current Scene",
		"O, también se puede apretar F6"
	])
	var play_current_scene_button = EditorInterface.get_base_control().find_children(
		"", "EditorRunBar", true, false
	).front().find_children("", "HBoxContainer", true, false).front()\
	.find_children("", "Button", false, false)[3]
	highlight_controls(
		[play_current_scene_button]
	)
	complete_step()
	bubble_add_text([
		"Agreguemos un personaje con el cual hablar",
		"Arrastra talker.tscn al arbol de nodos de la escena"
	])
	highlight_filesystem_paths([
		TALKER_SCENE_PATH
	])
	highlight_scene_nodes_by_name(["Nivel1"])
	complete_step()
	bubble_add_text([
		"Movamos al personaje más cerca del jugador"
	])
	highlight_scene_nodes_by_name(["Talker"])
	complete_step()
	bubble_add_text([
		"Problemos la escena de nuevo"
	])
	highlight_controls(
		[play_current_scene_button]
	)
	complete_step()
	bubble_add_text(["Bien hecho!"])
	complete_step()

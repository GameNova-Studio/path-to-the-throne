@tool
class_name GameButton extends Button

@onready var read_button = $ReadOutLoudButton

## Se usa para mostrar los efectos en el ataque
@onready var status = $Status

@export var text_to_voice: bool = false :
	set(new_value):
		text_to_voice = new_value
		if(is_inside_tree()):
			read_button.visible = text_to_voice

func _ready():
	if(not text_to_voice):
		read_button.visible = false
		return

	var voices = DisplayServer.tts_get_voices_for_language("en")
	if(voices.is_empty()):
		read_button.visible = false
		return

	var voice_id = voices[0]

	read_button.pressed.connect(func():
		DisplayServer.tts_speak(text, voice_id)
	)

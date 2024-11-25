class_name MultipleChoiceMiniGame extends MiniGameScene

@export var multiple_choice: MultipleChoice
@onready var options_container = %OptionsContainer
@onready var question_label = %QuestionLabel
@onready var correct = $Correct
@onready var wrong = $Wrong
@onready var timer_timebar = $TimerBar/Timer

const COMBAT_OPTION_BUTTON = preload("res://ui/components/game_button.tscn")

func _ready():
	setup_minigame(
		multiple_choice.question,
		multiple_choice.answers,
		multiple_choice.correct_answer
	)

func setup_minigame(question, answers, correct_answer):
	question_label.text = question
	
	for option in options_container.get_children():
		option.queue_free()
	for answer in answers:
		var button = COMBAT_OPTION_BUTTON.instantiate()
		button.text_to_voice = true
		button.text = answer
		options_container.add_child(button, true)
		button.pressed.connect(func():
			paint_answers()
			if(answer == correct_answer):
				self.on_correct_answer()
			else:
				self.on_incorrect_answer()
		)
	
func on_correct_answer():
	correct.play()
	timer_timebar.paused = true
	await get_tree().create_timer(0.5).timeout
	succeed()

func on_incorrect_answer():
	wrong.play()
	timer_timebar.paused = true
	await get_tree().create_timer(0.5).timeout
	fail()

func paint_answers():
	for option in options_container.get_children():
		if(option.text == multiple_choice.correct_answer):
			option.modulate = Color.GREEN
		else:
			option.modulate = Color.RED


func _on_timer_bar_timeout() -> void:
	self.on_incorrect_answer()

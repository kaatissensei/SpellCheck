extends Control

@onready var number_txt = get_child(0).get_child(0)
@onready var japanese_txt = get_child(0).get_child(1)
@onready var answer_txt = get_child(0).get_child(2)
@onready var btn : Button = number_txt.get_child(0)
@onready var id : int

signal remove_vocab(id: int)

var font_size = 40
func _ready() -> void:
	btn.connect("pressed",_remove)

func _load(num: int = 1, jpn: String = "", ans: String = "", new_font_size: int = 40) -> void:
	font_size = new_font_size
	_number(num)
	_japanese(jpn)
	_answer(ans)

func _number(num: int):
	number_txt.text = str(num)
	number_txt.add_theme_font_size_override("normal_font_size", font_size)

func _x():
	number_txt.text = "X"
	_button_on(true)
	number_txt.add_theme_font_size_override("normal_font_size", font_size)

func _japanese(jpn: String):
	japanese_txt.text = jpn
	japanese_txt.add_theme_font_size_override("normal_font_size", font_size)

func _answer(ans: String):
	answer_txt.text = ans
	answer_txt.add_theme_font_size_override("normal_font_size", font_size)

func _button_on(tf: bool = true):
	btn.visible = tf

func set_id(new_id: int):
	id = new_id

func _remove():
	#remove from array
	emit_signal("remove_vocab", id)
	#get_tree().get_root().get_node("%MyList").remove_vocab_from_list(id)
	queue_free()

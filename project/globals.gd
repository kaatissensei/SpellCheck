extends Node

var use_db : bool = true
var csvFile
var default_lists
var csv_array = []
var unit_array : Array[Array]
var list_array : Array[Vocab]

var game_paused : bool = false

var current_grade : int
var current_unit : String
var current_page : int
var current_screen : String #This should be an enum
var wait_time : float

var vietnamese_on : bool

enum Game_Mode {study = 0, timed = 1, test = 2}
@export var game_mode = Game_Mode.study

func _ready() -> void:
	wait_time = 180

func set_game_mode(new_game_mode : Game_Mode):
	game_mode = new_game_mode

func set_list_ids(grade: int = current_grade, unit: String = current_unit, page_num: int = current_page):
	current_grade = grade
	current_unit = unit
	current_page = page_num
	#convert_to_vocab()

func convert_to_vocab():
	var vocab_array : Array
	for v in range(csv_array.size()):
		if (type_string(typeof(csv_array[v])) == "String"):
			vocab_array = csv_array[v].split(",")
		else:
			vocab_array = csv_array[v] #PackedStringArray
		var string_array: Array[String]
		string_array.assign(vocab_array)
		var new_vocab : Vocab = Vocab.new(string_array)
			#new_vocab.populate_vocab(vocab_array)
		list_array.push_back(new_vocab)
			
		##var csv_line_len = 4
		##for i in range(csv_array.size()):
			##var arr = csv_array.slice(i,i+csv_line_len)[0]
			#Assign variables here
				#questions[i] = arr[0]
				#answers[i] = int(arr[1])

func set_list_array(new_array: Array):
	list_array.clear()
	list_array.assign(new_array)

func array_to_str(array: Array, limit: int = 100, include_header : bool = false) -> String:
	var pg : int
	var arr_str : String

	pg = array[0].page_num
	if include_header:
		arr_str = "NEW WORDS p" + str(pg) + "\n"
	
	if array.size() < limit:
		for v in array:
			arr_str = arr_str + v.english + "\n"
	else:
		for i in range(limit):
			arr_str = arr_str + array[i].english + "\n"
		arr_str = arr_str + "\n..."
	arr_str.strip_edges()
	return arr_str

func set_wait_time(new_wait_time : float):
	wait_time = new_wait_time
#NH2024 3 Stage activities + 1年生 = 10units, 2年生 = 7units, 3年生 = 6units

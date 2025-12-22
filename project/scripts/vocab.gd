class_name Vocab extends Resource

@export var id : int
@export var english : String
@export var japanese : String
@export var part_of_speech : String
@export var grade_num : int
@export var unit : String
#@export var list_num : int
@export var page_num : int
@export var include : bool
@export var vietnamese : String

func _init(vocab_array: Array[String] = ["0", "Eng", "", "日本語", "3", "0", "U0", ""]):
	#if vocab_array[6] == "〇": #Now doing in SELECT statement
	populate_vocab(vocab_array)
#OLD
#func _init(vocab_array: Array[String] = ["Eng", "日本語", "単語", "3", "0", "0"]):
	#populate_vocab(vocab_array)

##Format: English, PoS, Japanese, Grade, Page, Unit

func populate_vocab(vocab_array) :
	id = vocab_array[0].to_int()
	english = vocab_array[1]
	part_of_speech = vocab_array[2]
	japanese = vocab_array[3]
	grade_num = vocab_array[4].to_int()
	page_num = vocab_array[5].to_int() 
	unit = vocab_array[6]
	#include not included
	if vocab_array.size() > 7:
		vietnamese = vocab_array[7]
	
	#list_num = vocab_array[5].to_int()
	

extends Control

@onready var upload_button: Button = %"LoadList" as Button


const searchResultScript = preload("res://scripts/search_result.gd")
const result_answer_row = preload("res://result_box.tscn")
const LIST_BTN = preload("res://list_button.tscn")

var my_new_list : Array[Vocab] = []
var my_vocab_lists : Array[Array]
var include_grade : Array[bool] = [true, true, true]
var current_list_name : String = "My List"
var current_list_ids : Array = []
var current_list_index : int = 0

var in_edit_mode : bool = false
var my_lists : Array[Dictionary]

func _ready() -> void:
	
	var new_list_dict = {"Name" : "My List", "List" : []}
	push_list(new_list_dict.Name, new_list_dict.List)

func _open_my_list_menu():
	%SaveManager.load_cookie()
	%GradeSelectTop.visible = false
	Main.use_my_list = true
	%WordSearchBar.text = ""
	%MyList.visible = true
	#if data saved, open

func _search_for_word(word: String):
	%SQLController.search_for_word(word, include_grade)

func show_search_results(word_list: Array[Vocab]):
	for word in word_list:
		var vocBtn = Button.new()
		vocBtn.text += "%s | %s \n" % [word.english, word.japanese]
		vocBtn.alignment = 0
		vocBtn.theme = load("res://custom_list.tres")
		vocBtn.set_script(searchResultScript)
		vocBtn.vocab = word
		%MyListSearchBoxes.add_child(vocBtn)
		vocBtn.connect("pressed", add_new_vocab_to_list.bind(word))

func add_new_vocab_to_list(vocab: Vocab):
	if !current_list_ids.has(vocab.id):
		add_vocab_to_list(vocab)
		current_list_ids.push_back(vocab.id)

func add_vocab_to_list(vocab: Vocab):
	var new_row : Control = result_answer_row.instantiate()
	%MyListVocabBoxes.add_child(new_row)
	var row_num : int = %MyListVocabBoxes.get_child_count()
	var japanese_text : String = vocab.japanese
	var answer_text : String = vocab.english
	new_row._load(row_num, japanese_text, answer_text, 30)
	new_row._button_on(in_edit_mode)
	#%MyListVocabBoxes.add_child(new_row)
	new_row.size_flags_vertical = Control.SIZE_FILL
	new_row.custom_minimum_size.y = 100
	new_row.set_id(vocab.id)
	new_row.connect("remove_vocab", remove_vocab_from_list)
	#my_new_list.push_back(vocab) #Do I need this?

func remove_vocab_from_list(id: int):
	current_list_ids.erase(float(id))

func push_list(list_name: String, list_ids: Array):
	var new_list_dict = {"Name" : list_name, "List" : list_ids}
	my_lists.push_back(new_list_dict)

func _toggle_grade(toggled_on: bool, grade: int) -> void:
	include_grade[grade-1] = toggled_on
	if %WordSearchBar.text.length() >= 2:
		_search_for_word(%WordSearchBar.text)

func _update_my_list_name(new_text: String):
	current_list_name = new_text
	%MyListNameDropdown.set_item_text(%MyListNameDropdown.selected, new_text)

func _save_my_list_name(new_name: String, list_index: int = current_list_index) -> void:
	my_lists[list_index].Name = new_name

func _save_my_list_ids(id_arr: Array, list_index: int = current_list_index) -> void:
	my_lists[list_index].List = id_arr

func create_list_button(list : Array[Vocab]):
		var new_btn = LIST_BTN.instantiate()
		%ListSelect.add_child(new_btn)
		new_btn.text = Main.array_to_str(list, 6, true) #6 is limit, which should not be hardcoded like this
		new_btn.name = "p%dVocab" % list[0].page_num
		#new_btn.connect("pressed", load_my_lists.bind(list[0].page_num))

func _export_lists():
	%SaveManager.export_list(my_lists)


func _exit_edit_mode(_text: String=""):
	if in_edit_mode:
		save_list()
		edit_result_boxes()
		%EditBtn.button_pressed = false

func edit_result_boxes():
	var MLInput = %MyListNameInput
	var MLDrop = %MyListNameDropdown
	
	if in_edit_mode:
		in_edit_mode = false
		#Number words in my list
		for i in range (%MyListVocabBoxes.get_child_count()):
			%MyListVocabBoxes.get_child(i)._number(i+1)
			%MyListVocabBoxes.get_child(i)._button_on(false)
	else:
		in_edit_mode = true
		#Change numbers to Xs
		for i in range (%MyListVocabBoxes.get_child_count()):
			%MyListVocabBoxes.get_child(i)._x()
		
		current_list_index = MLDrop.selected
		MLInput.text = my_lists[current_list_index].Name
		MLInput.select_all()
		MLInput.grab_focus()
	
	MLDrop.visible = !in_edit_mode
	MLInput.visible = in_edit_mode

func save_list():
	_save_my_list_name(current_list_name)
	_save_my_list_ids(current_list_ids)
	%SaveManager.save_cookie(my_lists)

func _select_list(index: int) -> void:
	var MLND = %MyListNameDropdown
	await save_list() #save previous before changing
	
	#if last item in Dropdown, make new item
	if index == MLND.item_count - 1:
		#MLND.set_item_text(index, "New List")
		push_list("New List", [])
		for voc in %MyListVocabBoxes.get_children():
			voc.queue_free()
		%EditBtn.button_pressed = true
		in_edit_mode = false
		edit_result_boxes()
		MLND.add_item("+ New List")
		set_current_list(index)
	else:
		set_current_list(index)
		_load_selected_list(index)
	
	

func _load_selected_list(index: int = current_list_index):
	for old_voc in %MyListVocabBoxes.get_children():
		old_voc.queue_free()
	load_list_with_vocab(my_lists[index].Name, my_lists[index].List)
	
	
func load_list_with_vocab(new_list_name: String, new_list_arr: Array):
	%MyListNameInput.text = new_list_name
	if new_list_arr.size() > 0:
		for i in range(new_list_arr.size()):
			var voc : Vocab = %SQLController.get_vocab_from_id(int(new_list_arr[i]))
			add_vocab_to_list(voc)

func set_current_list(index: int):
	current_list_index = index
	current_list_name = my_lists[index].Name
	current_list_ids = my_lists[index].List
	
	Main.current_page = index

func import_single_list(new_list):
	var MLND = %MyListNameDropdown
	var result : Array[Dictionary] = []
	if typeof(new_list) == TYPE_DICTIONARY:
			# Safe to add as Dictionary
		result.append(new_list)
	else:
		push_warning("Skipping non-dictionary element: %s" % str(new_list))
	my_lists = result
	
	set_current_list(0)
	MLND.clear()
	MLND.add_item(new_list.Name)
	MLND.add_item("+ New List")
	
	_load_selected_list()
	#load_list_with_vocab(new_list.Name, new_list.List)
	
func import_list(new_list_arr):
	var MLND = %MyListNameDropdown
	my_lists = convert_to_dict_array(new_list_arr)
	set_current_list(0)
	MLND.clear()
	for list in my_lists:
		MLND.add_item(list.Name)
	MLND.add_item("+ New List")
	
	_load_selected_list()
	#load_list_with_vocab(new_list_arr[0].Name, new_list_arr[0].List)

func convert_to_dict_array(input_array: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for element in input_array:
		if typeof(element) == TYPE_DICTIONARY:
			# Safe to add as Dictionary
			result.append(element)
		else:
			push_warning("Skipping non-dictionary element: %s" % str(element))
	return result

func _get_my_vocab_lists(list_num: int = -1):
	var list_arr : Array[Array]
	var _arr : Array
	#arr.duplicate()
	if my_lists.size() > 0:
		for list in my_lists:
			var new_list : Array[int]
			for id in list.List:
				new_list.append(int(id))
			var voc_list = %SQLController._get_vocab_array_from_ids(new_list)
			list_arr.append(voc_list)
		#print(int_arr)
		if list_num == -1:
			return list_arr
		else:
			return list_arr[list_num]
	else:
		print("Array my_lists is empty.")
		return []


	
func _delete_list_confirmation() -> void:
	%Confirmation.get_child(0).text = "Delete List?\n[s]%s[/s]" % current_list_name
	%Confirmation.visible = true

func _delete_list() -> void:
	var MLND = %MyListNameDropdown
	if MLND.item_count > 2:
		MLND.remove_item(current_list_index)
		my_lists.remove_at(current_list_index)
		set_current_list(0)
		_load_selected_list()
		MLND.select(0)
	else:
		MLND.set_item_text(0,"My List")
		for voc in %MyListVocabBoxes.get_children():
			voc.queue_free()
		current_list_ids.clear()
	_exit_edit_mode()
	%Confirmation.visible = false
	

func _hide_confirmation() -> void:
	%Confirmation.visible = false

extends Control

var current_list : Array[Vocab]
var shuffled_list = []
var list_size : int

var current_number : int = 1
var current_word : Vocab
var test_word_num : int

var num_mistakes : int
var correct_array : Array[bool]
var passed_array : Array[int]
var unanswered_array : Array[int] #change to true if finished
var guess_array : Array[String] #student's guesses

var result_answer_row = load("res://result_box.tscn")
var LIST_BTN = preload("res://list_button.tscn"
)

func _ready() -> void:
	pass
	#load_list(3,0)
	#%CSVHandler.load_default_csv()

func _gui_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ENTER:
		%Enter.emit_signal("pressed")  # Simulate button press.
	if event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
		%Pass.emit_signal("pressed")

func load_list(grade: int = Main.current_grade, unit: String = Main.current_unit, page_num: int = Main.current_page):
	Main.set_list_ids(grade, unit, page_num)
	if Main.use_db:
		var v_list : Array[Vocab] = %SQLController.get_vocab_list(page_num)
		Main.set_list_array(v_list)
	else:
		#Main.set_list_array(%CSVFile.get_list(grade, unit, list_num))
		pass

	
func _start_quiz(_grade: int = Main.current_grade, 
				_unit: String = Main.current_unit, _page_num: int = Main.current_page):
	##Moved to ready_quiz: ##reset_quiz() load_list(grade, unit, page_num) load_array()
	if Main.game_mode == 2 || Main.game_mode == 0: #test or study
		shuffled_list.resize(test_word_num)
		resize_arrays(test_word_num)
	%MainMenu.visible = false
	load_word()
	%TimerDisplay.visible = false
	%SpellingInput.grab_focus()
	match Main.game_mode:
		0: #study
			pass
		1: #timed
			%TimerDisplay.visible = true
			%TimerDisplay._start_stopwatch()
		2: #test
			%TimerDisplay._start_timer(Main.wait_time)

func _ready_list():
	reset_quiz()
	load_list()
	load_array()
	Main.current_screen = "ReadyMenu"
	#Fill list preview with English list
	#var str_list = Main.array_to_str(current_list)
	##%ListPreview.text = str_list
	%ListPreviewLabel.text = "NEW WORDS %d年生 %s p.%d" % [Main.current_grade, Main.current_unit, Main.current_page]
	#Fill list preview with Eng/Jpn boxes
	%ListPreview.text = ""

	populate_list_preview()
	_change_test_word_num(10)
	
	#Change TestWordNumber slider vals
	%TestWordNumber.max_value = current_list.size()
	%TestWordNumber.tick_count = current_list.size() - 4 # min_value + 1
	##WIP if Main.game_mode == 1: #timed
		
	if current_list.size() < 10:
		%TestWordNumber.value = 5
	else:
		%TestWordNumber.value = 10
	#Change min if list is <5 words (shouldn't be, but just in case)
	if current_list.size() < 5:
		%TestWordNumber.min_value = 1
		%TestWordNumber.max_value = current_list.size()
		
	#Set to max if game_mode is study or timed
	if Main.game_mode == 0: #study
		%TestWordNumber.value = current_list.size()
	elif Main.game_mode == 1: #timed
		%TestWordNumber.value = current_list.size()
	
	match Main.game_mode:
		0: #study
			%TestTimer.visible = false
			%TestWordNumber.visible = true
		1: #timed
			%TestTimer.visible = false
			%TestWordNumber.visible = false
		2: #test
			%TestTimer.visible = true
			%TestWordNumber.visible = true

func populate_list_preview():
	#Clear children first
	for i in range(%ListPreviewBoxes.get_children().size()):
		%ListPreviewBoxes.get_child(i).queue_free()
	for i in range(list_size):
		var new_row : Control = result_answer_row.instantiate()
		%ListPreviewBoxes.add_child(new_row)
		var row_num : int = i + 1
		var japanese_text : String = current_list[i].japanese
		var answer_text : String = current_list[i].english
		new_row._load(row_num, japanese_text, answer_text, 30)

func _redo_quiz():
	var prev_list : Array
	#preserve shuffled_list
	prev_list.assign(shuffled_list)
	reset_quiz()
	shuffled_list.assign(prev_list)
	shuffled_list.shuffle()
	resize_arrays(test_word_num)
	_start_quiz()
	%ResultsPopup.visible = false

func reset_quiz():
	current_number = 1
	num_mistakes = 0
	passed_array.clear()
	correct_array.clear()
	unanswered_array.clear()
	guess_array.clear()
	shuffled_list.clear()
	Main.game_paused = false
	for child in %ResultAnswers.get_children():
		#node.remove_child(n)
		child.queue_free()

func load_array():
	current_list.clear()
	current_list.assign(Main.list_array)
	list_size = current_list.size()
	resize_arrays(list_size)
	shuffle_array()
	test_word_num = shuffled_list.size()
	%TestWordNumber.value = list_size

func resize_arrays(new_size: int):
	unanswered_array.clear()
	guess_array.clear()
	correct_array.clear()
	passed_array.clear()
	for i in range(new_size):
		unanswered_array.push_back(i + 1) 
	guess_array.resize(new_size)
	correct_array.resize(new_size)
	correct_array.fill(true)

func shuffle_array():
	shuffled_list.assign(current_list)
	shuffled_list.shuffle()
	
func load_word():
	if shuffled_list.size() > 0:
		current_word = shuffled_list[current_number - 1]
		%WordNumber.text = "%d/%d" % [current_number, shuffled_list.size()]
		#print("Please spell %s" % current_word.japanese)
		%WordToSpell.text = current_word.japanese
	else:
		print("List empty")

func _skip_question():
	passed_array.push_back(current_number)
	next_question()

#This method is only called if unanswered_array isn't empty
func next_question():	
	if current_number < test_word_num - 1: #twn formerly list_size
		#if unanswered_array[current_number + 1] == false:
		current_number += 1
		load_word()
	elif current_number == test_word_num - 1:
		current_number += 1
		load_word()
	else:
		if passed_array.size() == 0:
			show_score()
		else:
			current_number = passed_array.pop_front()
			load_word()
	
	%SpellingInput.grab_focus() #.grab_click_focus() #I don't think this works, but I guess it's not needed

func _check_answer():
	if %SpellingInput.text != "":
		#Trim input
		var guess: String = %SpellingInput.text.strip_edges().replace("’","'")
		guess_array[current_number-1] = guess
		if guess == current_word.english.strip_edges().replace("’","'"):
			#make something green
			is_correct(true)
		else:
			#make something red
			is_correct(false)
			num_mistakes += 1
			correct_array[current_number - 1] = false
		
		unanswered_array.erase(current_number)
		if unanswered_array.size() != 0:
			next_question()
		else:
			show_score()
	

func is_correct(correct: bool):
	var color
	if correct:
		color = Color.LIME_GREEN
	else:
		color = Color.RED
	
	%SpellingInput.add_theme_color_override("font_color", color)
	await get_tree().create_timer(0.2).timeout
	%SpellingInput.text = ""
	%SpellingInput.add_theme_color_override("font_color", Color.WHITE)

func get_hint():
	pass

func show_score():
	var time_result = ""
	match Main.game_mode:
		1: #timed
			%TimerDisplay._stop_stopwatch()
			%TimerDisplay.visible = false
			time_result = "Time: %s  " % %TimerDisplay.text
		2: #test
			%TimerDisplay._stop_timer()
	%ResultsPopup.visible = true
	Main.game_paused = true
	var total: int = shuffled_list.size()
	%WordToSpell.text = "%sScore: %d/%d" % [time_result, total - num_mistakes, total]
	%ResultsScore.text = "%sScore: %d/%d" % [time_result, total - num_mistakes, total]
	
	for i in range(test_word_num):
		var new_row = result_answer_row.instantiate()
		%ResultAnswers.add_child(new_row)
		#var row = %ResultAnswers.get_child(i)
		var row_num : int = i + 1
		var japanese_text : String = shuffled_list[i].japanese
		var answer_text : String

		if correct_array[i] == false:
			answer_text = shuffled_list[i].english + "\n[color=red]" + guess_array[i] + "[/color]"
		else:
			answer_text = guess_array[i]
		#row._answer(answer_text)
		new_row._load(row_num, japanese_text, answer_text)


func _back_to_home() -> void:
	%ResultsPopup.visible = false
	_go_home()
	reset_quiz()

func _go_home():
	%MainMenu.visible = true
	#Switch Main Menu back to unit select
	%StartMenu.visible = true
	%GradeSelect.visible = false
	%ListSelect.visible = false
	%UnitSelect.visible = false
	%ListSelectMenu.visible = false
	%ReadyMenu.visible = false

func _change_test_word_num(new_num : float):
	test_word_num = int(new_num)
	%TestWordNumVal.text = "%d/%d words" % [test_word_num, current_list.size()]


func _change_language(toggled_on: bool) -> void:
	#var lang = "Vietnamese"
	if toggled_on:
		%WordToSpell.text = current_word.vietnamese
		%SwitchLang.text = "日本語"
	else:
		%WordToSpell.text = current_word.japanese
		%SwitchLang.text = "Tiếng Việt"


func _focus_on_SpellingInput() -> void:
	%SpellingInput.grab_focus()

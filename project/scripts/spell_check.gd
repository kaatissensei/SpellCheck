extends Control

var unit_lists : Array[Array]
var unit_names : Array[String]
var LIST_BTN = preload("res://list_button.tscn")

func _ready() -> void:
	get_list_options(3,4)
	pass

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if !Main.game_paused:
			%Enter.emit_signal("pressed")  # Simulate button press.


func _start() -> void:
	%MainMenu.visible = false

func populate_units_menu():
	unit_names = $SQLController.get_units()
	for u in unit_names:
		var unit_btn = Button.new()
		unit_btn.theme = load("res://main_theme.tres")
		unit_btn.add_theme_font_size_override("default", 150)
		unit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		unit_btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		unit_btn.text = u.replace("-", "")
		%UnitSelect.add_child(unit_btn)
		unit_btn.connect("pressed", _select_unit.bind(u))

func get_list_options(grade: int = 3, unit: int = 4):
	#var unit_list : Array
	var num_lists = 5
	unit_lists.clear()
	if Main.use_db:
		pass# unit_names = $SQLController.get_units()
		#add_lists_to_menu()
	else: #old way, used for csvs
		for i in range (num_lists):
			var new_list = %CSVFile.get_list(grade, unit, i)
			if (new_list.size() != 0):
				unit_lists.push_back(new_list)
		add_lists_to_menu()

func add_lists_to_menu():
	#print(unit_lists.size())
	if unit_lists.size() > 8 || unit_lists.size() == 5:
		%ListSelect.columns = 5
	else:
		%ListSelect.columns = 4
	#var btn_name : String
	#var btn_text : String
	#var pg_num : String
	for list in unit_lists:
		create_list_button(list)
		#var new_btn = LIST_BTN.instantiate()
		#%ListSelect.add_child(new_btn)
		#new_btn.text = array_to_str(list, 10)
		#new_btn.name = "p%dVocab" % list[0].page_num
		#new_btn.connect("pressed", _select_list.bind(list[0].page_num))

func _select_list(page_num: int):
	Main.current_page = page_num
	#%MainMenu.visible = false
	#%QuizScene._start_quiz(Main.current_grade, Main.current_unit, page_num)
	%ListSelectMenu.visible = false
	Main.current_screen = "ReadyMenu"
	_open_ready_menu()
	
	#Switch Main Menu back to unit select
	#show_list_select_menus(%GradeSelect)

func _select_unit(new_unit_num: String) -> void:
	Main.current_unit = new_unit_num
	for vlist in %ListSelect.get_children():
		vlist.queue_free()
		
	if Main.use_db:
		pass
	else:
		get_list_options(Main.current_grade, int(Main.current_unit))
	%UnitSelect.visible = false
	%ListSelect.visible = true
	%ListSelectMenuText.text = "Which list?"
	Main.current_screen = "ListSelect"
	var unit_pages : Array[int]
	if Main.use_my_list:
		#use custom list
		pass
		var custom_lists = %MyList._get_my_vocab_lists()
		var i : int = 0
		for list in custom_lists:
			create_list_button(list, i)
			i += 1
	else:
		unit_pages = $SQLController._get_page_nums(new_unit_num)
		for page in unit_pages:
			var list : Array[Vocab] = $SQLController.get_vocab_list(page)
			create_list_button(list)
	
	if unit_pages.size() > 10:
		%ListSelect.columns = 6
	elif unit_pages.size() < 5:
		%ListSelect.columns = 4
	else:
		%ListSelect.columns = 5

func create_list_button(list : Array[Vocab], _custom_page: int = 0):
		var new_btn = LIST_BTN.instantiate()
		%ListSelect.add_child(new_btn)
		new_btn.text = Main.array_to_str(list, 6, true, _custom_page) #6 is limit, which should not be hardcoded like this
		if !Main.use_my_list:
			new_btn.name = "p%dVocab" % list[0].page_num
			new_btn.connect("pressed", _select_list.bind(list[0].page_num))
		else:
			new_btn.name = %MyList.my_lists[Main.current_page].Name
			new_btn.connect("pressed", _select_list.bind(_custom_page))
			

func _set_mode(new_mode):
	var new_game_mode : Main.Game_Mode
	match new_mode:
		0: #study
			new_game_mode = Main.Game_Mode.study
			%TimerProgress.visible = false
		1: #timed
			new_game_mode = Main.Game_Mode.timed
			%TimerProgress.visible = false
		2: #test
			new_game_mode = Main.Game_Mode.test
			%TimerProgress.visible = true
	
	show_list_select_menus(%GradeSelectTop)
	Main.set_game_mode(new_game_mode)
	
	#%ModeSelect.visible = false
	%StartMenu.visible = false
	%ListSelectMenu.visible = true
	

func _set_grade(new_grade: int) -> void:
	Main.current_grade = new_grade
	for ulist in %UnitSelect.get_children():
		ulist.queue_free()
	populate_units_menu()
	show_list_select_menus(%UnitSelect)


func _set_test_time(time_limit : int) -> void:
	Main.time_limit = time_limit * 60
	show_list_select_menus(%GradeSelectTop)

func show_list_select_menus(selected_menu : Control):
	%TimeLimitSelect.visible = false
	%ModeSelect.visible = false
	%GradeSelectTop.visible = false
	%UnitSelect.visible = false
	%ListSelect.visible = false
	
	selected_menu.visible = true
	match selected_menu.name:
		"GradeSelectTop":
			%ListSelectMenuText.text = "Which grade?"
		"UnitSelect":
			%ListSelectMenuText.text = "Which unit?"
		"ListSelect":
			%ListSelectMenuText.text = "Which list?"
		"TimeLimitSelect":
			%ListSelectMenuText.text = "Set timer."
	Main.current_screen = selected_menu.name

func _go_back(current_screen: String = Main.current_screen):
	print(current_screen)
	match current_screen:
		"GradeSelect":
			%QuizScene._go_home()
		"UnitSelect":
			show_list_select_menus(%GradeSelectTop)
		"ListSelect":
			show_list_select_menus(%UnitSelect)
		"ReadyMenu":
			show_list_select_menus(%ListSelect)
			%ReadyMenu.visible = false
			%ListSelectMenu.visible = true

func _open_ready_menu():
	%ReadyMenu.visible = true
	%QuizScene._ready_list()
	

func _set_wait_time(new_time : float):
	Main.set_wait_time(new_time * 60)
	
	

func _toggle_vietnamese(toggled_on: bool) -> void:
	Main.vietnamese_on = toggled_on
	%SwitchLang.visible = toggled_on

func _close_my_list_window() -> void:
	%MyList.save_list()
	_select_unit("My_List")
	%MyList.visible = false

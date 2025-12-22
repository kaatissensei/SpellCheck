extends Control

#@onready var upload_button: Button = %"LoadList" as Button
##@onready var main_upload_btn: Button = %"UploadCSV" as Button
#var default_csv_path = "res://csv/Spell_check_g3u4_test.txt"
#
#var csvFile
#
#func _ready() -> void:
	### file_access_web functions won't work if you don't connect them!
	#upload_button.pressed.connect(_on_upload_pressed)
	##main_upload_btn.pressed.connect(_on_upload_pressed)
	##file_access_web.load_started.connect(_on_file_load_started)
	#file_access_web.loaded.connect(_on_file_loaded)
	##file_access_web.progress.connect(_on_progress)
	#file_access_web.error.connect(_on_error)
	#
	##print_csv()
#
#
#func load_question_menu():
	#pass
	##for i in range(Main.questions.size()):
		##%Questions.get_child(i).get_child(0).text = Main.questions[i]
		##if Main.answers[i] != 0:
			##%Questions.get_child(i).get_child(1).text = str(Main.answers[i])
#
#func _open_menu():
	#visible = true
#
#func _close_menu():
	#visible = false
#
#func _open_settings():
	#%SettingsMenu.visible = true
#
#func _close_settings():
	#%SettingsMenu.visible = false
#
##WEB FILE ACCESS FUNCTIONS ------------------------------------------------\
#
#var file_access_web: FileAccessWeb = FileAccessWeb.new()
#
##func _on_file_load_started(file_name: String) -> void:
	##progress.visible = true
	##success_label.visible = false
#
#func _on_error() -> void:
	#push_error("Error!")
#
#func _on_upload_pressed() -> void:
	#if OS.has_feature("web"):
		#file_access_web.open(".csv")
	#else:
		#pass
#
#func _on_file_loaded(_file_name: String, _type: String, base64_data: String) -> void:
	#print("File Loaded")
	#var utf8_data: String = Marshalls.base64_to_utf8(base64_data)
	##var string_data: String = base64_data.get_string_from_utf8()
	#
	#var file = FileAccess.open("user://vocabulary.csv", FileAccess.WRITE)
	#if FileAccess.file_exists("user://vocabulary.csv"):
		#file.store_string(utf8_data)
		#file.close() #Don't forget this!
		#Main.csvFile = FileAccess.open("user://vocabulary.csv", FileAccess.READ)
		#parse_csv()
		#
#
		##%DEBUG.text = Main.csvArray
	#else:
		#print("Can't find file.")
#
#func load_default_csv():
	#var content = %CSVFile.get_csv()
	#var file = FileAccess.open("user://vocabulary.csv", FileAccess.WRITE)
	#if FileAccess.file_exists("user://vocabulary.csv"):
		#file.store_string(content)
		#file.close() #Don't forget this!
		#Main.csvFile = FileAccess.open("user://vocabulary.csv", FileAccess.READ)
		#parse_csv()
	#Main.csv_array.clear()
	#while csvFile.get_position() < csvFile.get_length():
		#var csvLine = csvFile.get_csv_line()
		#Main.csv_array.push_back(csvLine)
		##print(type_string(typeof(csvLine)))
		#
	#Main.csv_array.pop_front() #removes title
	#Main.convert_to_vocab()
#
#func parse_csv():
	##var csv_line_len = 6 #number of elements per csv line
	#csvFile = Main.csvFile
	#
	##clear_questions()
	#Main.csv_array.clear()
	#while csvFile.get_position() < csvFile.get_length():
		#var csvLine = csvFile.get_csv_line()
		#Main.csv_array.push_back(csvLine)
		##print(type_string(typeof(csvLine)))
		#
	#Main.csv_array.pop_front() #removes title
	#Main.convert_to_vocab()
	##print(csvFile)
	##for i in range(Main.csv_array.size()):
		##var arr = Main.csv_array.slice(i,i+csv_line_len)[0]
		###Assign variables here
		####questions[i] = arr[0]
		####answers[i] = int(arr[1])
#
#func print_csv():
	#var text_file_path = "res://csv/3年生Vocab.txt"
	#var _text_content = get_text_file_content(text_file_path)
#
#func get_text_file_content(filePath):
	#var file = FileAccess.open(filePath, FileAccess.READ)
	##var content = file.get_as_text()
	#var content
	#if FileAccess.file_exists(filePath):
		#while file.get_position() < file.get_length():
			#content = file.get_csv_line()
			###%SQLController.insert_data(content)
	#else:
		#pass
	#return content

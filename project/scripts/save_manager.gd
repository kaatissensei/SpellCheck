extends Node

@onready var upload_button : Button = %ImportBtn as Button
@onready var export_button : Button = %DownloadBtn as Button
@onready var save_button : Button = %SaveBtn as Button

#@onready var req := $HTTPRequest

var json = JSON.new()
var path = "user://My_SpellCheck_lists.json"

var data = {}

func _ready() -> void:
	#upload_button.pressed.connect(_on_upload_pressed)
	file_access_web.loaded.connect(_on_file_loaded)
	#file_access_web.loaded.connect(_on_file_loaded)
	#file_access_web.error.connect(_on_error)


func _download_file(file_to_dl):
		JavaScriptBridge.download_buffer(file_to_dl.to_utf8_buffer(), "My_vocab_list.txt", "text/plain")

#Called from file access web's _on_file_loaded
func json_to_list(json_text):
	#var json = JSON.new()
	var error = json.parse(json_text)
	if error == OK:
		#print(json.data) # Returns the parsed data as a Dictionary
		var list_arr = json.data
		
		#Check if there are two lists contained
		if typeof(list_arr) == TYPE_ARRAY && list_arr.size() > 1:
			%MyList.import_list(list_arr)
		else:
			%MyList.import_single_list(list_arr[0])
			#%MyList.load_list_with_vocab(list_arr.Name, list_arr.List)
			
		#for list in list_arr:
			#print("Name: %s" % list.Name)
			#print("Words: %s" % str(list.List))
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())

#Download lists
func export_list(my_lists: Array):
	#var my_list_dict = {"Name" : my_list_name, "List" : my_list_ids}
	var json_string = JSON.stringify(my_lists, "\t")
	#var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		#var data_received = json.data
		JavaScriptBridge.download_buffer(json_string.to_utf8_buffer(), "My_Vocab_Lists.json", "text/plain")
		#if typeof(data_received) == TYPE_ARRAY:
			#print(data_received) # Prints the array.
		#else:
			#print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

func save_cookie(my_lists: Array):
	var json_string = JSON.stringify(my_lists, "\t")
	#var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(json_string)

func load_cookie():
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_txt = file.get_as_text()
		json_to_list(json_txt)


#WEB FILE ACCESS FUNCTIONS ------------------------------------------------\

var file_access_web: FileAccessWeb = FileAccessWeb.new()

#func _on_file_load_started(file_name: String) -> void:
	#progress.visible = true
	#success_label.visible = false

func _on_error() -> void:
	push_error("Error!")

func _on_upload_pressed() -> void:
	print("on upload pressed")
	if OS.has_feature("web"):
		file_access_web.open(".json")
	else:
		pass
		#var path = "res://"
		#var filename = "PercentBalloonTest.csv"
		#var file := FileAccess.open(path.path_join(filename), FileAccess.READ)
		#if file == null:
			#var error_str: String = error_string(FileAccess.get_open_error())
			#push_warning("Couldn't open file because: %s" % error_str)
		#print(file)
		#Main.csvFile = file
		#Main.parse_csv()
		#load_question_menu()
		#%DEBUG.text = Main.csvArray

#func _on_progress(current_bytes: int, total_bytes: int) -> void:
#	pass
	#var percentage: float = float(current_bytes) / float(total_bytes) * 100
	#progress.value = percentage

func _on_file_loaded(_file_name: String, _type: String, base64_data: String) -> void:
	var utf8_data: String = Marshalls.base64_to_utf8(base64_data)
	json_to_list(utf8_data)

	
	#var file = FileAccess.open(path, FileAccess.WRITE)
	#if FileAccess.file_exists(path):
		#file.store_string(utf8_data)
		#file.close() #Don't forget this!
		##Main.csvFile = FileAccess.open(path, FileAccess.READ)
		#
	#else:
		#%DEBUG.text = "Can't find file."

extends Control

var voc_db : SQLite
var tbl_name = "vocabulary"

func _ready() -> void:
	voc_db = SQLite.new()
	voc_db.path="res://vocab"
	voc_db.read_only = true   #comment out to edit (duh)
	voc_db.open_db()
	get_units()
	
	#insert_txt()
	#database.drop_table("vocabulary")
	#create_table()
	
func get_units(grade : int = Main.current_grade) -> Array[String]:
	var units : Array[String]
	#print(database.select_rows(tbl_name, "grade = 3 AND page = 6", ["english"]))
	voc_db.query("SELECT DISTINCT SUBSTR(unit, 1, 3) AS unit FROM %s WHERE grade = %d AND include = '〇'" % [tbl_name, grade])
	for word in voc_db.query_result:
		units.push_back(word.unit.replace("-", "").replace("(", ""))
	return units

func get_page_nums(unit : String = "U0") -> Array[int]:
	var page_nums : Array[int]
	
	voc_db.query("SELECT DISTINCT unit, page FROM %s WHERE grade = %d AND unit LIKE '%s%%' AND include = '〇'" % [tbl_name, Main.current_grade, unit])
	for result in voc_db.query_result:
		page_nums.push_back(int(result.page))
	
	return page_nums

#func get_word_list
func get_vocab_list(page : int) -> Array[Vocab]:
	var word_list : Array[Vocab]
	#var selection : String = "english, part_of_speech, japanese, grade, page, unit" #include
	var query : String
	if Main.vietnamese_on:
		#var lang = "vietnamese"
		query = "SELECT voc.*, ros.vietnamese FROM vocabulary AS voc LEFT JOIN rosetta_table AS ros ON voc.english = ros.english AND voc.japanese = ros.japanese WHERE grade = %d AND page = %d AND include = '〇'" % [Main.current_grade, page]
	else:
		query = "SELECT * FROM %s WHERE grade = %d AND page = %d AND include = '〇'" % [tbl_name, Main.current_grade, page]
	voc_db.query(query)
	for result in voc_db.query_result:
		var vocab_arr : Array[String]
		if Main.vietnamese_on:
			var third_lang = result.vietnamese
			vocab_arr = [result.english, result.part_of_speech, result.japanese, str(result.grade), str(result.page), result.unit, third_lang]
		else:
			vocab_arr = [result.english, result.part_of_speech, result.japanese, str(result.grade), str(result.page), result.unit] #include
		var new_vocab = Vocab.new(vocab_arr)
		word_list.push_back(new_vocab)
	return word_list
	
func insert_txt():
	tbl_name = "rosetta_table"
	var text_file_path = "res://csv/3年生Rosetta.txt"
	#var text_content = 
	get_text_file_content(text_file_path)

func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	#var content = file.get_as_text()
	var content
	while file.get_position() < file.get_length():
		content = file.get_csv_line()
		insert_data(content)
	return content

#func create_table():
	#tbl_name = "rosetta_table"
	#var table = {
		#"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		#"english" : {"data_type":"text", "not_null" : true},
		#"part_of_speech" : {"data_type":"text"},
		#"japanese" : {"data_type" : "text", "not_null" : true},
		#"grade" : {"data_type" : "int"},
		#"page" : {"data_type" : "int"},
		#"unit" : {"data_type" : "text"},
		#"include" : {"data_type" : "text"}
	#}
	#var rosetta_table = {
		#"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		#"english" : {"data_type":"text", "not_null" : true},
		#"japanese" : {"data_type" : "text", "not_null" : true},
		#"vietnamese" : {"data_type" : "text"},
		#"portuguese" : {"data_type" : "text"}
	#}
	#
	#voc_db.create_table(tbl_name, rosetta_table)
	#insert_txt()

func insert_data(psa : PackedStringArray):
	#var data = {
		#"english" : psa[0],
		#"japanese" : psa[1],
		#"grade" : int(psa[3]),
		#"page" : int(psa[4]),
		#"unit" : psa[5],
		#"include" : psa[6]
	#}
	
	var data = {
		"english" : psa[0],
		"japanese" : psa[1],
		"vietnamese" : psa[2],
		"portuguese" : psa[3]
	}
	#voc_db.insert_row("vocabulary", data)
	voc_db.insert_row(tbl_name, data)

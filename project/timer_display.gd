extends RichTextLabel

@onready var timer : Timer = %Timer
var time_elapsed : float = 0
var stopwatch_running : bool = false
var time_left : float
var wait_time : float
var stopwatch_mode = false

func _ready() -> void:
	wait_time = Main.wait_time

#Stopwatch
func _process(delta: float) -> void:
	var game_mode = Main.game_mode
	if game_mode == 1:
		if stopwatch_running:
			time_elapsed += delta
			update_display(time_elapsed)
	elif game_mode == 2 and not timer.is_stopped():
		#print(timer.time_left)
		time_left = timer.time_left
		update_display(time_left)
	
	%TimerProgress.value = 100 * time_left / wait_time


func update_display(time : float):
	text = _format_seconds(time)

func _format_seconds(time : float, use_milliseconds : bool = false) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)

	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]

	var milliseconds := fmod(time, 1) * 100

	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

#----- TIMER FUNCTIONS -----
func _start_timer(time : float = Main.wait_time):
	timer.start(int(time))
	wait_time = timer.wait_time
	
func _stop_timer():
	timer.stop()

#----- STOPWATCH FUNCTIONS -----
func _start_stopwatch():
	_reset_time()
	stopwatch_running = true
	
func _stop_stopwatch():
	stopwatch_running = false

func _reset_time():
	time_elapsed = 0
	update_display(time_elapsed)

func _on_timer_timeout() -> void:
	print("Time's Up")

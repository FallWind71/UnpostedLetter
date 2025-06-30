extends Node2D

@onready var terminal = $TerminalLog
@onready var timer = $Timer
@onready var bg = $ColorRect
@onready var hint = $ContinueHint
@onready var hint_tween = create_tween()

var show_continue_hint := false
var crashed := false
var current_index: int = 0
var displayed_lines: Array[String] = []
var crash_timer := Timer.new()

# 改成写当前工作目录下的文件
#虽然说改成user目录更加通用，但谁没事会看哪个目录啊
var draft_path := ""

var log_lines = [
	"[    0.000000] Booting system kernel...",
	"[    0.000001] Initializing core subsystems...",
	"[    0.000002] Mounting virtual filesystem: /dev/project",
	"[    0.000003] [OK] Filesystem mounted successfully",
	"[    0.000004] Allocating memory blocks: 256 MB",
	"[    0.000005] Scanning entity templates...",
	"[    0.000006] Loading dialogue subsystem...",
	"[    0.000007] [INFO] Dialogue engine v0.1.3 initialized",
	"[    0.000008] Linking external assets...",
	"[    0.000009] [WARN] Asset directory '/sprites' not found",
	"[    0.000010] [ERROR] main_character.gd: File not found",
	"[    0.000011] Falling back to default entity template",
	"[    0.000012] [INFO] Entity loaded: pixel_block (ID 000x9a)",
	"[    0.000013] Parsing timeline script...",
	"[    0.000014] [WARN] Syntax anomalies detected at line 42, 87",
	"[    0.000015] Script completeness: 27.3%",
	"[    0.000016] Loading save state...",
	"[    0.000017] [ERROR] save_data.sav: Not found (0xF404)",
	"[    0.000018] Attempting emergency boot...",
	"[    0.000019] Memory scan: references to 'Y' found: 3",
	"[    0.000020] Memory leak suspected in /core/emotion.gd",
	"[    0.000021] Cleaning orphaned variables...",
	"[    0.000022] Residual emotion data located at addr 0x7FFE9130",
	"[    0.000023] Loading commit history...",
	"[    0.000024] Commit @ 2020/12/29 23:17 — Draft ending v0.2",
	"[    0.000025] Commit @ 2020/12/30 03:52 — Removed Y from index",
	"[    0.000026] Commit @ 2021/01/03 00:05 — 'No one is waiting anyway'",
	"[    0.000027] Attempting rollback... failed.",
	"[    0.000028] Rebuilding runtime modules...",
	"[    0.000029] Input subsystem online. Bindings: WASD / Arrow Keys",
	"[    0.000029] [ERROR] WASD Files Couldn't Be Found",
	#这里预计是作为隐藏信息，后续开发横板操控时，提示“WASD”但实际上只能用箭头键操作。但后续没有时间进行开发了
	"[    0.000030] [WARN] Input conflict: jump_action unbound",
	"[    0.000031] Scanning user config...",
	"[    0.000032] [ERROR] user_config.cfg corrupted or missing",
	"[    0.000033] Loading backup user profile... UID: unknown",
	"[    0.000034] Estimated time since last launch: 1350.6 days",
	"[    0.000035] System heartbeat: stable",
	"[    0.000036] Running identity check... mismatch",
	"[    0.000037] [System] I don't recognize this user",
	"[    0.000038] [System] Still... maybe...",
	"[    0.000039] [System] Awaiting user input...",
	"[    0.000040] System ready.",
	"[    0.000041] [System] Welcome back, user. I’ve been waiting..."
]

func _ready():
	# 获取当前工作目录并拼接文件路径
	var dir = DirAccess.open(".")
	var current_dir = dir.get_current_dir()
	draft_path = current_dir + "/" + "draft.txt"

	resize_terminal()
	add_child(crash_timer)
	crash_timer.one_shot = true
	crash_timer.autostart = false
	timer.wait_time = randf_range(0.02, 0.2)
	timer.start()
	print("Ready: Crash timer added, initial state: ", crash_timer.is_stopped())
	write_files()

func resize_terminal():
	var window_size = get_viewport_rect().size
	bg.size = window_size - Vector2(20, 20)
	bg.position = Vector2(10, 10)
	bg.color = Color.BLACK

	terminal.size = window_size - Vector2(40, 40)
	terminal.position = Vector2(20, 20)
	terminal.clear()
	terminal.bbcode_enabled = true

	hint.visible = false
	hint.text = ""

func _on_Timer_timeout():
	if current_index < log_lines.size():
		var line = log_lines[current_index]
		displayed_lines.append(line)
		if displayed_lines.size() > 15:
			displayed_lines.pop_front()

		terminal.push_color(Color.GREEN)
		terminal.add_text(line + "\n")
		terminal.pop()
		terminal.scroll_to_line(terminal.get_line_count() - 1)

		if current_index == log_lines.size() - 2:
			timer.wait_time = 2.0
		elif current_index == log_lines.size() - 1:
			timer.wait_time = 3.0
		elif current_index < log_lines.size() - 3:
			timer.wait_time = randf_range(0.02, 0.2)
		else:
			timer.wait_time = randf_range(0.2, 0.5)
		timer.start()
		current_index += 1
		print("Log line ", current_index, " displayed, timer wait: ", timer.wait_time)
	else:
		if not show_continue_hint:
			show_continue_hint = true
			hint.visible = true
			hint.text = "按下 Enter 以继续"
			hint.modulate.a = 0.0
			hint_tween = create_tween().set_loops()
			hint_tween.tween_property(hint, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			hint_tween.tween_property(hint, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

			crash_timer.wait_time = 300.0
			crash_timer.start()
			print("Crash timer started: ", crash_timer.time_left)
			crash_timer.connect("timeout", Callable(self, "_on_crash_timeout"))

func _input(event):
	if show_continue_hint and event.is_action_pressed("ui_accept"):
		hint.visible = false
		hint_tween.kill()
		if ResourceLoader.exists("res://scenes/main_menu.tscn"):
			var error = get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			if error != OK:
				print("场景加载失败: ", error)
		else:
			print("MemoryScene.tscn 不存在")

func _on_crash_timeout():
	if show_continue_hint and not crashed:
		crashed = true
		hint.visible = false
		hint_tween.kill()
		terminal.clear()
		terminal.push_color(Color.RED)
		terminal.add_text("[    0.000050] [FATAL] No input detected.\n")
		await get_tree().create_timer(1.2).timeout
		terminal.add_text("[    0.000051] [ERROR] User unresponsive. Memory collapse imminent.\n")
		await get_tree().create_timer(1.2).timeout
		terminal.add_text("[    0.000052] Disconnecting...\n")
		await get_tree().create_timer(2.0).timeout

		if ResourceLoader.exists("res://scenes/corrupted_scene.tscn"):
			var error = get_tree().change_scene_to_file("res://scenes/corrupted_scene.tscn")
			if error != OK:
				print("场景加载失败: ", error)
		else:
			print("CorruptedScene.tscn 不存在")
		print("Crash timeout triggered")

func write_files() -> void:
	var dir = DirAccess.open(".")
	if dir == null:
		push_error("无法打开当前目录")
		return

	var dir_path = dir.get_current_dir()
	draft_path = dir_path + "/" + "draft.txt"
	var job_path = dir_path + "/" + "job_application.txt"
#改了好久的路径加载
	var draft_file = FileAccess.open(draft_path, FileAccess.WRITE)
	if draft_file != null:
		var draft_content = """
[2020/12/14] 今天终于敲下了那串密码，2021。希望它能守护这个小小的世界。
[2020/12/15] Y 的声音一直在脑海里回响，像未完成的旋律。这个游戏是给她的，给那个温柔的她。
[2020/12/20] 代码越来越乱了，有点像我的生活。昨晚又debug到凌晨两点，咖啡喝了第三杯。
[2020/12/22] 昨天下午，试着画了个草图，手有点抖。不知道是不是太累了。
[2020/12/25] 圣诞节了，没能陪家人。Y 说我太执着了，可我觉得这是唯一能和她靠近的方式。
[2020/12/29] 代码提交了新版本。“2021”藏在一个小文件里。希望有人能找到它。
[2020/12/29] 没钱了。
[2020/12/30] 我开始怀疑，这些代码是不是有点像我自己的影子，残缺、孤单。
[2021/01/01] 新年第一天，空气中弥漫着希望。也许今年，我能走出阴霾。
[2021/01/03] 身体越来越不听话了，但我不能停。Y说，2021是关键，必须坚持。
[2021/01/03] 我还能怎么办？我还能怎么办？？？
[2021/01/05] 我该去找工作了。
[2021/01/05] 也许我该放手了，但这游戏和密码，是我留给她的信。
[2021/01/06] 如果有人看见这段文字，告诉她——我没忘记2021，也没忘记她。
[2021/01/17] 一场很有希望的面试。明天就要出发去试试了，等我有了时间，经济好了点，应该就能写完这封信了。
"""
		draft_file.store_string(draft_content)
		draft_file.close()
		print("draft.txt 写入成功，路径：", draft_path)
	else:
		push_error("无法创建 draft.txt")

	var job_file = FileAccess.open(job_path, FileAccess.WRITE)
	if job_file != null:
		var job_content = """
求职信 - 林

尊敬的招聘主管：

您好！我叫林，是一名热爱游戏开发的程序员，拥有丰富的GDScript和Godot引擎开发经验。  
最近，我完成了一个独立游戏项目，项目中我负责游戏逻辑、界面设计以及文件系统的实现。  
我对细节有执着的追求，且能够高效解决开发中的各种问题。  

希望能有机会加入贵公司，与团队一起创造更多优秀的游戏作品。  

感谢您的考虑，期待您的回复。

此致  
敬礼  
林
"""
		job_file.store_string(job_content)
		job_file.close()
		print("job_application.txt 写入成功，路径：", job_path)
	else:
		push_error("无法创建 job_application.txt")

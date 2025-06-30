# MemoryScene.gd
# 场景节点结构：
# MemoryScene (Node2D)
# ├ TerminalLog (RichTextLabel)
# ├ ContinueHint (Label)
# └ Particle2D (GPUParticles2D) —— 记忆碎片粒子特效（可选）

extends Node2D

@onready var terminal      = $TerminalLog
@onready var continue_hint = $ContinueHint
# Revision 13: 修正三元语法为 GDScript 风格
@onready var particles     = $Particle2D if has_node("Particle2D") else null

var tween           = null
var current_index   = 0
var finished        = false

# Revision 11: 获取系统用户名（Windows / Linux 兼容）
var system_user     = OS.get_environment("USER") if OS.has_environment("USER") and OS.get_environment("USER") != "" else OS.get_environment("USERNAME")

# Revision 11: 可执行目录（运行目录，非项目根路径）
var exe_dir         = OS.get_executable_path().get_base_dir()

# Revision 12: 精炼版情感文本 + 系统回响 + 元游戏化用户名嵌入
var finale_texts = [
	"[2021/01/06 00:01] 系统用户: %s" % system_user,
	"林：Y，如果你真的能听见……",
	"林：代码不是游戏，是未寄的信。",
	"[System] 残留检测：情感波动 97.3%%",
	"[System] 正在提取日志碎片……",
	"",
	"[Draft_尾注]：这行代码，本应是我们的重逢\n若你读到它，请代我对她说——\n    ‘我还在等她回来。’",
	"",
	"[System] 记忆空间已冻结，备份文件生成：memory_fragment_0001.log",
	"[System] 关闭协议已载入",
	"[System] 等待下一次重启..."
]

func _ready():
	terminal.clear()
	terminal.bbcode_enabled = true
	continue_hint.visible = false
	tween = create_tween()

	# Revision 12: 粒子预热安全判断
	if particles:
		particles.emitting = false

	_show_next_text()

func _show_next_text():
	var text = finale_texts[current_index]
	_screen_shake(0.1)

	var color_tag = "#88CCFF" if text.begins_with("林：") else "#AAAAFF"
	terminal.clear()
	terminal.bbcode_text = "[color=%s]%s[/color]" % [color_tag, text]


	
	terminal.modulate.a = 0.0
	tween.kill()
	tween = create_tween()
	tween.tween_property(terminal, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_fade_in_complete"))

func _screen_shake(duration: float):
	var cam = get_viewport().get_camera_2d()
	if cam:
		var orig = cam.offset
		var shake = create_tween()
		shake.tween_property(cam, "offset", orig + Vector2(5, -5), duration / 2)
		shake.tween_property(cam, "offset", orig, duration / 2)

func _on_fade_in_complete():
	if not finished:
		continue_hint.text = "按 Enter 继续"
		continue_hint.visible = true

func _input(event):
	if event.is_action_pressed("ui_accept") and continue_hint.visible:
		continue_hint.visible = false
		current_index += 1
		if current_index < finale_texts.size():
			_show_next_text()
		else:
			finished = true
			_generate_memory_fragment()
			_shutdown_sequence()

func _generate_memory_fragment():
	var path = exe_dir + "/memory_fragment_0001.log"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var content = "记忆编号：#0001\n用户：%s\n时间：%s\n\n遗言：\n‘若你读到，请告诉她，我还在等她回来。’\n" % [system_user, Time.get_datetime_string_from_system()]
		file.store_string(content)
		file.close()
		terminal.bbcode_text += "\n[color=#55FF88]备份生成：%s[/color]" % path
	else:
		terminal.bbcode_text += "\n[color=#FF5555]错误：备份生成失败[/color]"

func _shutdown_sequence():
	await get_tree().create_timer(1.0).timeout
	tween.kill()
	tween = create_tween()
	tween.tween_property(terminal, "modulate:a", 0.0, 1.0)
	tween.tween_property(continue_hint, "modulate:a", 0.0, 1.0)
	await tween.finished

	terminal.clear()
	terminal.bbcode_enabled = true
	terminal.bbcode_text = ""
	terminal.bbcode_text += "[color=#FFAA33]--- 记忆空间关闭 ---[/color]\n"
	terminal.bbcode_text += "[color=#AAAAAA]错误码: 0xWAITING[/color]\n"
	terminal.bbcode_text += "[color=#AAAAAA]等待未知变量 %s[/color]" % system_user
	terminal.modulate.a = 1.0

	continue_hint.text = "按任意键退出"
	continue_hint.modulate.a = 1.0
	continue_hint.visible = true

func _unhandled_input(event):
	if finished and event is InputEventKey and event.pressed:
		if ResourceLoader.exists("res://scenes/main_menu.tscn"):
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		else:
			get_tree().quit()

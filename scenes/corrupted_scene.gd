# ✅ CorruptedScene.gd 完整代码（超详细注释，小学生都能懂）
# 场景要求：
# - 根节点是 Node2D，名字叫 CorruptedScene
# - 添加一个 Label 节点，名字叫 exit_hint
# - 添加一个 ColorRect（用于屏幕闪烁）
# - 添加一个 AudioStreamPlayer 节点（播放恐怖音效）
# - 可选：添加 GPUParticles2D 节点（用于电火花）

extends Node2D

# 运行时间，用来做动画用
var time_elapsed := 0.0

# 用来控制屏幕干扰强度
var glitch_intensity := 0.0

# 提示文字（我们自己创建一个）
var exit_hint := Label.new()

# 用来播放崩溃声音
@onready var sound := $AudioStreamPlayer

# 用来屏幕覆盖红色闪烁（可选）
@onready var flash := $ColorRect

func _ready():
	# 启用处理函数（每帧都会调用 _process）
	set_process(true)
	
	# 添加提示文字到画面上
	exit_hint.text = "系统崩溃... 按 Enter 退出"
	exit_hint.add_theme_font_size_override("font_size", 32) # 字体大小
	exit_hint.add_theme_color_override("font_color", Color(1.0, 0.7, 0.7, 1.0)) # 淡红色
	add_child(exit_hint) # 放到场景中
	
	# 设置文字位置：居中显示
	exit_hint.position = get_viewport_rect().size / 2 - Vector2(200, 50)
	exit_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 播放恐怖音效（确保你已经导入 .ogg 文件）
	sound.play()

	# 红色闪烁层初始透明
	flash.color.a = 0.0
	
	print("[DEBUG] 崩溃画面已加载，等待用户输入")

func _process(delta):
	# 让时间增加
	time_elapsed += delta

	# 让屏幕抖动强度来回变化（使用正弦波）
	glitch_intensity = sin(time_elapsed * 4.0) * 0.1

	# 文字轻微抖动，像坏掉一样
	var offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
	exit_hint.position = get_viewport_rect().size / 2 + offset - Vector2(200, 50)

	# 每帧都重画画面
	queue_redraw()

	# 有概率显示红色闪光（像是屏幕坏掉）
	if randf() < 0.1:
		flash.color.a = 0.3
	else:
		flash.color.a = 0.0

func _draw():
	# 画出很多小方块，模拟屏幕故障（像马赛克）
	var viewport_size = get_viewport_rect().size
	var base_color = Color(0.1, 0.1, 0.1, 1.0) # 背景基色深灰色
	for y in range(0, int(viewport_size.y), 10):
		for x in range(0, int(viewport_size.x), 10):
			# 每个小格子的亮度会随机波动
			var noise = randf_range(-glitch_intensity, glitch_intensity)
			var color = base_color + Color(noise, noise, noise, 0.0)
			draw_rect(Rect2(x, y, 10, 10), color)

func _input(event):
	# 玩家按下 Enter（ui_accept），退出游戏
	if event.is_action_pressed("ui_accept"):
		print("[DEBUG] 玩家请求退出")
		get_tree().quit()

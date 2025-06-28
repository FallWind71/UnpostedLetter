shader_type canvas_item;

uniform float time_speed = 0.2;
uniform vec2 noise_scale = vec2(0.5, 0.5);

void fragment() {
    float t = TIME * time_speed;

    // 坐标归一化
    vec2 uv = UV * noise_scale;

    // 简易噪声：正弦波扰动模拟“流动感”
    float noise = sin(uv.x * 3.14 + t) + cos(uv.y * 2.0 + t * 0.6);
    noise = noise * 0.5 + 0.5; // 映射到 [0,1]

    // 映射为灰色调
    float brightness = mix(0.05, 0.2, noise); // 黑到浅灰
    COLOR = vec4(vec3(brightness), 1.0);
}

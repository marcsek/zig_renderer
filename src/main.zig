const std = @import("std");
const std_out = @import("std").io.getStdOut();
const Window = @import("window.zig").Window;
const WinFrame = @import("window.zig").WinFrame;
const Renderer = @import("renderer.zig").Renderer;

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const TARGET_FPS = 0;

var c_x: f64 = 0;
var c_y: f64 = 0;
var theta: f64 = 0;

pub fn main() !void {
    var window = try Window.init("fuckery", WINDOW_WIDTH, WINDOW_HEIGHT, WinFrame.resizable);
    var renderer = try Renderer.init(std.heap.c_allocator, WINDOW_WIDTH, WINDOW_HEIGHT);
    defer renderer.destroy();

    window.setTargetFps(TARGET_FPS);

    var dt: f64 = 0;
    var state: i32 = 0;
    while (true) : (dt = try window.sync()) {
        renderer.resetBuffer();

        tick(dt);
        render(&renderer);

        state = window.update(renderer.render_buffer, WINDOW_WIDTH, WINDOW_HEIGHT);

        if (state < 0) break;

        try std_out.writer().print("\x1B[2J\x1B[H", .{});
        try window.debugInfo(std_out.writer().any());
    }
}

fn tick(dt: f64) void {
    theta += dt / 1000;
    c_x = 400 + 150 * @cos(theta);
    c_y = 300 + 150 * @sin(theta);
}

fn render(renderer: *Renderer) void {
    const c_x_pos: u32 = @intFromFloat(c_x);
    const c_y_pos: u32 = @intFromFloat(c_y);

    renderer.create_line(400, 300, c_x_pos, c_y_pos, 0xFFFFFFFF);
}

test "detect memory leak" {
    var renderer = try Renderer.init(std.testing.allocator, WINDOW_WIDTH, WINDOW_HEIGHT);
    defer renderer.destroy();
}

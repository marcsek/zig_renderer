const std = @import("std");
const Window = @import("window.zig").Window;
const WinFrame = @import("window.zig").WinFrame;
const Renderer = @import("renderer.zig").Renderer;

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const TARGET_FPS = 144;

var x: f64 = 0;

pub fn main() !void {
    var window = try Window.init("fuckery", WINDOW_WIDTH, WINDOW_HEIGHT, WinFrame.resizable);
    var renderer = try Renderer.init(WINDOW_WIDTH, WINDOW_HEIGHT);
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

        std.debug.print("\x1B[2J\x1B[H", .{});
        window.debugInfo(std.debug);
    }
}

fn tick(dt: f64) void {
    x = x + 0.2 * dt;
}

fn render(renderer: *Renderer) void {
    const x_pos: u32 = @max(@min(@as(i32, @intFromFloat(x)), WINDOW_WIDTH - 50), 0);

    renderer.putSquare(x_pos, 300, x_pos + 50, 350, 0xFFFFFFFF);
}

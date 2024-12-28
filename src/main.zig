const std = @import("std");
const Window = @import("window.zig").Window;
const WinFrame = @import("window.zig").WinFrame;
const Renderer = @import("renderer.zig").Renderer;

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;

pub fn main() !void {
    const window = try Window.init("Fuckery", WINDOW_WIDTH, WINDOW_HEIGHT, WinFrame.resizable);
    const renderer = try Renderer.init(WINDOW_WIDTH, WINDOW_HEIGHT);

    window.setTargetFps(60);

    var x: u32 = 0;
    while (window.sync()) {
        renderer.resetBuffer();
        renderer.putPixel(x, 300, 0xFFFFFFFF);

        _ = window.update(renderer.renderBuffer, WINDOW_WIDTH, WINDOW_HEIGHT);
        x += 1;
    }

    renderer.destroy();
}

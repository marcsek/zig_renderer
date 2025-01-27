const std = @import("std");
const std_out = @import("std").io.getStdOut();
const Window = @import("window.zig").Window;
const WinFrame = @import("window.zig").WinFrame;
const Renderer = @import("renderer.zig").Renderer;
const Cube = @import("cube.zig").Cube;
const matrix = @import("matrix.zig");

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const TARGET_FPS = 144;

var c_x: f64 = 0;
var c_y: f64 = 0;
var theta: f32 = 0;

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
    theta += @as(f32, @floatCast(dt)) / 1000;
    c_x = 400 + 150 * @cos(theta);
    c_y = 300 + 150 * @sin(theta);
}

fn render(renderer: *Renderer) void {
    var rotZ = matrix.Matrix4x4(f32).init(0.0);
    rotZ.buf[0][0] = @cos(theta);
    rotZ.buf[0][1] = @sin(theta);
    rotZ.buf[1][0] = -@sin(theta);
    rotZ.buf[1][1] = @cos(theta);
    rotZ.buf[2][2] = 1.0;
    rotZ.buf[3][3] = 1.0;

    var rotX = matrix.Matrix4x4(f32).init(0.0);
    rotX.buf[0][0] = 1.0;
    rotX.buf[1][1] = @cos(theta / 2.0);
    rotX.buf[1][2] = @sin(theta / 2.0);
    rotX.buf[2][1] = -@sin(theta / 2.0);
    rotX.buf[2][2] = @cos(theta / 2.0);
    rotX.buf[3][3] = 1.0;

    for (Cube.init().mesh) |triangle| {
        const fVec3 = matrix.Vec3(f32);

        const rotZ1 = rotZ.multVec3(fVec3.init(triangle[0], triangle[1], triangle[2]));
        const rotZ2 = rotZ.multVec3(fVec3.init(triangle[3], triangle[4], triangle[5]));
        const rotZ3 = rotZ.multVec3(fVec3.init(triangle[6], triangle[7], triangle[8]));

        var rotX1 = rotX.multVec3(rotZ1);
        var rotX2 = rotX.multVec3(rotZ2);
        var rotX3 = rotX.multVec3(rotZ3);

        rotX1.z += 3.0;
        rotX2.z += 3.0;
        rotX3.z += 3.0;

        var mProj = matrix.Matrix4x4(f32).initProjection(0.1, 1000.0, 90.0, @as(f32, @floatFromInt(WINDOW_HEIGHT)) / @as(f32, @floatFromInt(WINDOW_WIDTH)));
        var proj1 = mProj.multVec3(rotX1);
        var proj2 = mProj.multVec3(rotX2);
        var proj3 = mProj.multVec3(rotX3);

        proj1.x += 0.5;
        proj1.y += 0.5;
        proj2.x += 0.5;
        proj2.y += 0.5;
        proj3.x += 0.5;
        proj3.y += 0.5;

        proj1.x *= 0.5 * @as(f32, @floatFromInt(WINDOW_WIDTH));
        proj1.y *= 0.5 * @as(f32, @floatFromInt(WINDOW_HEIGHT));
        proj2.x *= 0.5 * @as(f32, @floatFromInt(WINDOW_WIDTH));
        proj2.y *= 0.5 * @as(f32, @floatFromInt(WINDOW_HEIGHT));
        proj3.x *= 0.5 * @as(f32, @floatFromInt(WINDOW_WIDTH));
        proj3.y *= 0.5 * @as(f32, @floatFromInt(WINDOW_HEIGHT));

        const c: u32 = 0xFFFFFFFF;

        renderer.createLine(@intFromFloat(proj1.x), @intFromFloat(proj1.y), @intFromFloat(proj2.x), @intFromFloat(proj2.y), c);
        renderer.createLine(@intFromFloat(proj2.x), @intFromFloat(proj2.y), @intFromFloat(proj3.x), @intFromFloat(proj3.y), c);
        renderer.createLine(@intFromFloat(proj3.x), @intFromFloat(proj3.y), @intFromFloat(proj1.x), @intFromFloat(proj1.y), c);
    }

    //const c_x_pos: u32 = @intFromFloat(c_x);
    //const c_y_pos: u32 = @intFromFloat(c_y);

    //renderer.create_line(400, 300, c_x_pos, c_y_pos, 0xFFFFFFFF);

}

test "detect memory leak" {
    var renderer = try Renderer.init(std.testing.allocator, WINDOW_WIDTH, WINDOW_HEIGHT);
    defer renderer.destroy();
}

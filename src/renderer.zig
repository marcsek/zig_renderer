const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const minifb = @cImport(@cInclude("MiniFB.h"));
const assert = std.debug.assert;

const DEFAULT_COLOR: comptime_int = 0xFFF98787;

pub const Renderer = struct {
    width: u32,
    height: u32,
    render_buffer: []u32,
    allocator: Allocator,

    pub fn init(allocator: Allocator, width: u32, height: u32) !Renderer {
        const buffer_size: usize = width * height * @sizeOf(u32);
        const buf: []u32 = try allocator.alloc(u32, buffer_size);

        return Renderer{
            .width = width,
            .height = height,
            .render_buffer = buf,
            .allocator = allocator,
        };
    }

    pub fn putPixel(self: Renderer, x: u32, y: u32, c: u32) void {
        //assert(x >= 0 and x < self.width);
        //assert(y >= 0 and y < self.height);
        if (x < 0 or x >= self.width or y < 0 or y >= self.height) return;

        self.render_buffer[y * self.width + x] = c;
    }

    pub fn createLine(self: Renderer, x0: u32, y0: u32, x1: u32, y1: u32, c: u32) void {
        const dx: i32 = @intCast(if (x1 >= x0) x1 - x0 else x0 - x1);
        const sx: i32 = if (x0 < x1) 1 else -1;

        const dy: i32 = -@as(i32, @intCast(if (y1 >= y0) y1 - y0 else y0 - y1));
        const sy: i32 = if (y0 < y1) 1 else -1;

        var err: i32 = dx + dy;
        var e2: i32 = 0;

        var x: i32 = @intCast(x0);
        var y: i32 = @intCast(y0);

        while (true) {
            self.putPixel(@intCast(x), @intCast(y), c);
            if (x == x1 and y == y1) break;
            e2 = 2 * err;
            if (e2 >= dy) {
                err += dy;
                x += sx;
            }
            if (e2 <= dx) {
                err += dx;
                y += sy;
            }
        }
    }

    pub fn resetBuffer(self: Renderer) void {
        for (0..(self.width * self.height)) |c| {
            self.render_buffer[c] = DEFAULT_COLOR;
        }
    }

    pub fn destroy(self: Renderer) void {
        self.allocator.free(self.render_buffer);
    }
};

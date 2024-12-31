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
        assert(x >= 0 and x < self.width);
        assert(y >= 0 and y < self.height);

        self.render_buffer[y * self.width + x] = c;
    }

    pub fn putSquare(self: Renderer, x1: u32, y1: u32, x2: u32, y2: u32, c: u32) void {
        for (y1..y2) |y| {
            for (x1..x2) |x| {
                self.putPixel(@intCast(x), @intCast(y), c);
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

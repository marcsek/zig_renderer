const std = @import("std");
const minifb = @cImport(@cInclude("MiniFB.h"));
const assert = std.debug.assert;

const DEFAULT_COLOR: comptime_int = 0xFFF98787;
const allocator = std.heap.c_allocator;

pub const Renderer = struct {
    width: u32,
    height: u32,
    renderBuffer: []u32,

    pub fn init(width: u32, height: u32) !Renderer {
        const bufferSize: usize = width * height * @sizeOf(u32);
        const buf: []u32 = try allocator.alloc(u32, bufferSize);

        for (0..(width * height)) |c| {
            buf[c] = DEFAULT_COLOR;
            // buf[c] = minifb.MFB_RGB(249, 135, 135);
        }

        return Renderer{
            .width = width,
            .height = height,
            .renderBuffer = buf,
        };
    }

    pub fn putPixel(self: Renderer, x: u32, y: u32, c: u32) void {
        assert(x >= 0 and x < self.width);
        assert(y >= 0 and y < self.height);

        self.renderBuffer[y * self.width + x] = c;
    }

    pub fn resetBuffer(self: Renderer) void {
        for (0..(self.width * self.height)) |c| {
            self.renderBuffer[c] = DEFAULT_COLOR;
        }
    }

    pub fn destroy(self: Renderer) void {
        allocator.free(self.renderBuffer);
    }
};

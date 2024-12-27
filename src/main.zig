const std = @import("std");
const minifb = @cImport(@cInclude("MiniFB.h"));
const minifb_e = @cImport(@cInclude("MiniFB_enums.h"));

extern fn malloc(size: usize) ?[*]u8;

pub fn main() !void {
    const mfb_window = minifb.mfb_open_ex("my display", 800, 600, minifb_e.WF_RESIZABLE);

    const buffer: [*]u32 = @alignCast(@ptrCast(malloc(800 * 600 * 4) orelse return));
    for (0..(800 * 600)) |c| {
        buffer[c] = minifb.MFB_RGB(249, 135, 135);
    }

    while (minifb.mfb_wait_sync(mfb_window)) {
        _ = minifb.mfb_update_ex(mfb_window, buffer, 800, 600);
    }
}

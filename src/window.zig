const minifb = @cImport(@cInclude("MiniFB.h"));
const minifb_e = @cImport(@cInclude("MiniFB_enums.h"));

pub const WinFrame = enum(u16) {
    resizable = 1,
    fullscreen = 2,
    fullscreen_desktop = 4,
    borderless = 8,
    always_on_top = 16,
};

pub const Window = struct {
    mfb_window: *minifb.struct_mfb_window,

    pub fn init(title: []const u8, width: u32, height: u32, flags: WinFrame) !Window {
        const mfb_window = minifb.mfb_open_ex(@ptrCast(title), width, height, @intFromEnum(flags)) orelse return error.FailedToOpen;

        return Window{ .mfb_window = mfb_window };
    }

    pub fn sync(self: Window) bool {
        return minifb.mfb_wait_sync(self.mfb_window);
    }

    pub fn update(self: Window, buffer: []u32, width: u32, heigh: u32) i32 {
        return minifb.mfb_update_ex(self.mfb_window, @ptrCast(buffer), width, heigh);
    }

    pub fn setTargetFps(_: Window, fps: u32) void {
        minifb.mfb_set_target_fps(fps);
    }
};

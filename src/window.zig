const time = @import("std").time;
const std = @import("std");
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
    metrics: TimeMetrics,

    pub fn init(title: []const u8, width: u32, height: u32, flags: WinFrame) !Window {
        minifb.mfb_set_target_fps(0);
        const mfb_window = minifb.mfb_open_ex(@ptrCast(title), width, height, @intFromEnum(flags)) orelse return error.FailedToOpen;

        return Window{ .mfb_window = mfb_window, .metrics = .{} };
    }

    pub fn sync(self: *Window) !f64 {
        var timer = self.metrics.timer orelse try time.Timer.start();
        const target_frame_time = 1000.0 / @as(f64, @floatFromInt(self.metrics.target_fps));
        const max_elapsed: f64 = if (self.metrics.target_fps == 0) 0 else target_frame_time;

        var delta: f64, var dt: f64, var fps: f64 = .{ 0, 0, 0 };
        while (true) {
            delta = @floatFromInt(timer.lap());
            dt = delta / 1_000_000.0;
            fps = 1000.0 / dt;

            self.metrics.total_elapsed += dt;
            if (max_elapsed < self.metrics.total_elapsed) {
                self.metrics.last_frame_time = self.metrics.total_elapsed;
                self.metrics.total_elapsed = 0;
                timer.reset();
                return self.metrics.last_frame_time;
            }
            time.sleep(100_000);
        }

        return 0;
    }

    pub fn update(self: Window, buffer: []u32, width: u32, heigh: u32) i32 {
        return minifb.mfb_update_ex(self.mfb_window, @ptrCast(buffer), width, heigh);
    }

    pub fn setTargetFps(self: *Window, fps: u32) void {
        self.metrics.target_fps = fps;
    }

    pub fn debugInfo(self: Window, writer: anytype) void {
        writer.print("frame time: {d:0.3}\n", .{self.metrics.last_frame_time});
        writer.print("fps: {d:0.0}\n", .{1000.0 / self.metrics.last_frame_time});
    }
};

const TimeMetrics = struct {
    timer: ?time.Timer = null,
    total_elapsed: f64 = 0,
    target_fps: u32 = 60,
    last_frame_time: f64 = 0,
};

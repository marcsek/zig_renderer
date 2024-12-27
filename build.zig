const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.graph.host;
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "renderer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    exe.linkLibC();
    exe.linkSystemLibrary("gl");
    exe.linkSystemLibrary("X11");
    exe.addIncludePath(b.path("dependencies/minifb/include/"));
    exe.addObjectFile(b.path("dependencies/minifb/build/libminifb.a"));

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

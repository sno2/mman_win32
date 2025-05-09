const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("mman_win32", .{});

    const mman = b.addLibrary(.{
        .name = "mman",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    mman.installHeader(upstream.path("trunk/mman.h"), "mman.h");
    mman.addCSourceFile(.{
        .file = upstream.path("trunk/mman.c"),
        .flags = &.{"-std=c11"},
    });
    b.installArtifact(mman);

    const test_step = b.step("test", "Run mman-win32's tests");
    const test_exe = b.addExecutable(.{
        .name = "test",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    test_exe.linkLibrary(mman);
    test_exe.addIncludePath(upstream.path("trunk"));
    test_exe.addCSourceFile(.{
        .file = b.path("test.c"),
        .flags = &.{"-std=c11"},
    });
    test_step.dependOn(&b.addRunArtifact(test_exe).step);
}

const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const mod = b.addModule("objc", .{
        .root_source_file = b.path("src/objc.zig"),
        .target = target,
        .optimize = optimize
    });
    mod.linkSystemLibrary("objc", .{});
    mod.linkFramework("Foundation", .{});
    mod.linkFramework("Cocoa", .{});
    
    const example = b.option([]const u8, "example", "Name of the example to run when invoking the run step") orelse "window";
    
    const exe = b.addExecutable(.{
        .name = example,
        .root_source_file = b.path(try std.fmt.allocPrint(b.allocator, "examples/{s}.zig", .{ example })),
        .target = target,
        .optimize = optimize
    });
    exe.root_module.addImport("objc", mod);
    
    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run an example");
    run_step.dependOn(&run.step);
    
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/objc.zig"),
        .target = target,
        .optimize = optimize
    });
    
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

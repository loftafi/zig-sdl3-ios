const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub export fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    if (true) {
        // Build a binary to run on macOS
        const target = b.standardTargetOptions(.{});

        const mod = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        compile_sdl(b, &target, &optimize, mod);

        const exe = b.addExecutable(.{
            .name = "cc",
            .root_module = mod,
            .link_libc = true,
        });
        add_system_build_paths(b, &target, exe);
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        const exe_unit_tests = b.addTest(.{
            .root_module = mod,
        });
        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_exe_unit_tests.step);
    }

    if (false) {
        // Build an iOS-simulator library
        const target = b.resolveTargetQuery(.{ .os_tag = .ios, .cpu_arch = .aarch64, .abi = .simulator });

        const mod = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target.*,
            .optimize = optimize.*,
            .link_libc = true,
        });
        compile_sdl(b, &target, &optimize, mod);

        const lib = b.addLibrary(.{
            .linkage = .static,
            .name = "cc-ios-simulator",
            .root_module = mod,
        });
        add_system_build_paths(b, &target, lib);
        b.installArtifact(lib);

        // Copy library into the xcode template project
        const lib_install = b.addInstallLibFile(lib.getEmittedBin(), "../../ios/cc/libcc-ios-simulator.a");
        b.getInstallStep().dependOn(&lib_install.step);
    }

    if (true) {
        // Build an iOS native library
        const target = b.resolveTargetQuery(.{ .os_tag = .ios, .cpu_arch = .aarch64 });

        const mod = b.createModule(.{
            .root_source_file = b.path("src/ios_main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        dynamic_sdl(b, &target, &optimize, mod);

        const lib = b.addLibrary(.{
            .linkage = .static,
            .name = "cc-ios",
            .root_module = mod,
        });
        add_system_build_paths(b, &target, lib);
        b.installArtifact(lib);

        // Copy library into the xcode template project
        const lib_install = b.addInstallLibFile(lib.getEmittedBin(), "../../ios/cc/libcc-ios.a");
        b.getInstallStep().dependOn(&lib_install.step);
    }
}

fn add_system_build_paths(b: *std.Build, target: *const std.Build.ResolvedTarget, lib: *std.Build.Step.Compile) void {
    if (target.result.os.tag == .macos) {
        lib.addSystemFrameworkPath(.{ .cwd_relative = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks" });
        //lib.addSystemFrameworkPath(.{ .cwd_relative = "/System/Library/PrivateFrameworks" });
        //lib.addSystemFrameworkPath(.{ .cwd_relative = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks" });
        //lib.addSystemFrameworkPath(.{ .cwd_relative = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks/" });
    }

    if (target.result.os.tag == .ios) {
        //lib.addSystemFrameworkPath(.{ .cwd_relative = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks" });
        const sdk = std.zig.system.darwin.getSdk(b.allocator, b.graph.host.result) orelse
            @panic("macOS SDK is missing");
        lib.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/include" }) });
        lib.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/System/Library/Frameworks" }) });
        lib.addLibraryPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/lib" }) });
    }
}

fn dynamic_sdl(b: *std.Build, target: *const std.Build.ResolvedTarget, optimize: *const std.builtin.OptimizeMode, mod: *std.Build.Module) void {
    const sdl_dep = b.dependency("sdl", .{});
    const ttf_dep = b.dependency("sdl_ttf", .{});
    mod.addIncludePath(sdl_dep.path("include"));
    mod.addIncludePath(ttf_dep.path("include"));

    // Translate the headers
    const ttf_module = b.addTranslateC(.{
        .root_source_file = ttf_dep.path("include/SDL3_ttf/SDL_ttf.h"),
        .target = target.*,
        .optimize = optimize.*,
        .link_libc = true,
    });
    const sdl_module = b.addTranslateC(.{
        .root_source_file = sdl_dep.path("include/SDL3/SDL.h"),
        .target = target.*,
        .optimize = optimize.*,
        .link_libc = true,
    });

    const sdk = std.zig.system.darwin.getSdk(b.allocator, b.graph.host.result) orelse
        @panic("macOS SDK is missing");
    sdl_module.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/include" }) });
    sdl_module.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/System/Library/Frameworks" }) });
    sdl_module.addIncludePath(ttf_dep.path("include"));
    //const sdl_mod = sdl_module.createModule();
    ttf_module.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/include" }) });
    ttf_module.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/System/Library/Frameworks" }) });
    ttf_module.addIncludePath(sdl_dep.path("include"));
    ttf_module.addIncludePath(ttf_dep.path("include"));
    const ttf_mod = ttf_module.createModule();
    mod.addImport("sdl", ttf_mod);

    // Represent the fact we have a library linking to an object file
    const sdl_lib = b.addLibrary(.{
        .name = "sdl",
        .root_module = ttf_mod,
        .linkage = .dynamic,
    });
    sdl_lib.addIncludePath(sdl_dep.path("include"));
    sdl_lib.addIncludePath(ttf_dep.path("include"));
    sdl_lib.addObjectFile(b.path("libs/libsdl3-ios-arm64.a"));
    sdl_lib.addObjectFile(b.path("libs/libsdl3ttf-ios-arm64.a"));

    const stb_module = b.addTranslateC(.{
        .root_source_file = b.path("libs/stb/stb_impl.c"),
        .target = target.*,
        .optimize = optimize.*,
        .link_libc = true,
    });
    stb_module.addIncludePath(b.path("libs/stb"));
    mod.addImport("stb", stb_module.createModule());
    if (target.result.os.tag == .ios) {
        //const sdk = std.zig.system.darwin.getSdk(b.allocator, b.graph.host.result) orelse
        //    @panic("macOS SDK is missing");
        //    sdl_module.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/include" }) });
        //    sdl_module.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/System/Library/Frameworks" }) });
        //    ttf_module.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/include" }) });
        //    ttf_module.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/System/Library/Frameworks" }) });
        stb_module.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/usr/include" }) });
        stb_module.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "/System/Library/Frameworks" }) });
    }
}

fn compile_sdl(b: *std.Build, target: *const std.Build.ResolvedTarget, optimize: *const std.builtin.OptimizeMode, mod: *std.Build.Module) void {
    const sdl_dep = b.dependency("sdl", .{});
    const sdl_lib = sdl_dep.artifact("SDL3");

    const ttf_dep = b.dependency("sdl_ttf", .{});
    const ttf_lib = ttf_dep.artifact("SDL_ttf");

    const sdl_module = b.addTranslateC(.{
        .root_source_file = sdl_dep.path("include/SDL3/SDL.h"),
        .target = target.*,
        .optimize = optimize.*,
        .link_libc = true,
    });
    sdl_module.addIncludePath(sdl_dep.path("include"));

    const ttf_module = b.addTranslateC(.{
        .root_source_file = ttf_dep.path("include/SDL3_ttf/SDL_ttf.h"),
        .target = target.*,
        .optimize = optimize.*,
        .link_libc = true,
    });
    ttf_module.addIncludePath(sdl_dep.path("include"));
    ttf_module.addIncludePath(ttf_dep.path("include"));

    const stb_module = b.addTranslateC(.{
        .root_source_file = b.path("libs/stb/stb_impl.c"),
        .target = target.*,
        .optimize = optimize.*,
        .link_libc = true,
    });
    stb_module.addIncludePath(b.path("libs/stb"));
    mod.addImport("stb", stb_module.createModule());

    mod.addImport("sdl_main", sdl_module.createModule());
    mod.addImport("sdl", ttf_module.createModule());

    mod.linkLibrary(sdl_lib);
    mod.linkLibrary(ttf_lib);
}

pub export fn SDL_main(argc: c_int, argv: [*:null]const ?[*:0]const u8) c_int {
    return app.zig_main(argc, argv);
}

const app = @import("app.zig");

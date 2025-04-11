pub fn main() !void {
    const argv: [*:null]const ?[*:0]const u8 = undefined;
    _ = app.zig_main(0, argv);
}

const app = @import("app.zig");

pub export fn zig_main(argc: c_int, argv: [*:null]const ?[*:0]const u8) c_int {
    std.log.debug("starting", .{});

    _ = argc;
    _ = argv;

    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_EVENTS | sdl.SDL_INIT_AUDIO | sdl.SDL_INIT_GAMEPAD | sdl.SDL_INIT_JOYSTICK)) {
        std.log.err("Init failed. {s}", .{sdl.SDL_GetError()});
        return 1;
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow("Test", 600, 800, sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_METAL);
    if (window == null) {
        std.log.err("No Window created. {s}", .{sdl.SDL_GetError()});
        return 1;
    }
    std.log.debug("created window", .{});

    if (window) |win| {
        defer sdl.SDL_DestroyWindow(win);

        const renderer = sdl.SDL_CreateRenderer(window, null);
        if (renderer == null) {
            std.log.err("No Renderer created. {any} -- {s}", .{ renderer, sdl.SDL_GetError() });
            return 1;
        }
        defer sdl.SDL_DestroyRenderer(renderer);
        std.log.debug("renderer created", .{});

        if (!sdl.TTF_Init()) {
            std.log.err("ttf setup font failed. {s}", .{sdl.SDL_GetError()});
            return 1;
        }

        var trect: sdl.SDL_FRect = .{ .x = 20, .y = 20, .w = 400, .h = 100 };
        var ttext: ?*sdl.SDL_Texture = null;
        const myfont = sdl.TTF_OpenFont("myfont.ttf", 150);
        if (myfont == null) {
            std.log.err("open font failed. {s}", .{sdl.SDL_GetError()});
        } else {
            const text_color: sdl.SDL_Color = .{ .r = 255, .g = 255, .b = 255, .a = 255 };
            sdl.TTF_SetFontHinting(myfont, 1);

            // This works
            const label_text = "Hello World";
            const stext = sdl.TTF_RenderText_Solid(myfont, label_text.ptr, label_text.len, text_color);

            // This panics
            //const stext = sdl.TTF_RenderText_Blended(myfont, "Simple text", 10, text_color);

            ttext = sdl.SDL_CreateTextureFromSurface(renderer, stext);
            trect = .{ .x = 20, .y = 20, .w = @as(f32, @floatFromInt(ttext.?.*.w)) / 3.0, .h = @as(f32, @floatFromInt(ttext.?.*.h)) / 3.0 };
            defer sdl.SDL_DestroySurface(stext);
        }

        std.log.debug("starting event loop", .{});
        var e: sdl.SDL_Event = undefined;
        var quit = false;
        while (!quit) {

            // Draw
            _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 150, 200, 200);
            _ = sdl.SDL_RenderClear(renderer);
            _ = sdl.SDL_SetRenderDrawColor(renderer, 50, 100, 150, 150);
            _ = sdl.SDL_RenderFillRect(renderer, &trect);

            if (ttext) |texture| {
                _ = sdl.SDL_RenderTexture(renderer, texture, null, &trect);
            }

            _ = sdl.SDL_RenderPresent(renderer);

            // Handle events
            while (sdl.SDL_PollEvent(&e)) {
                switch (e.type) {
                    sdl.SDL_EVENT_QUIT => {
                        quit = true;
                    },
                    sdl.SDL_EVENT_MOUSE_BUTTON_DOWN => {
                        quit = true;
                    },
                    sdl.SDL_EVENT_TERMINATING => {
                        quit = true;
                    },
                    sdl.SDL_EVENT_LOW_MEMORY => {
                        // iOS is threatining to kill your app.
                        // unless you decresae memory usage.
                    },
                    sdl.SDL_EVENT_WILL_ENTER_BACKGROUND => {
                        // Disappearing from screen. You could save or pause activity.
                        std.log.debug("entering background", .{});
                    },
                    sdl.SDL_EVENT_DID_ENTER_BACKGROUND => {
                        // Disappeared from screen. You could save or pause activity. You
                        // have a few seconds to save or cleanup.
                    },
                    sdl.SDL_EVENT_WILL_ENTER_FOREGROUND => {
                        // Your about to appear on screen
                        std.log.debug("entering foreground", .{});
                    },
                    sdl.SDL_EVENT_DID_ENTER_FOREGROUND => {
                        // App is back on the screen
                    },
                    else => {},
                }
            }
        }
    }

    std.log.debug("exiting", .{});
    return 0;
}

const std = @import("std");
const sdl = @import("sdl");
const stb = @import("stb");
const builtin = @import("builtin");

pub const std_options: std.Options = .{
    .log_level = .debug,
};

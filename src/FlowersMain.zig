const std = @import("std");
const sdl = @cImport(@cInclude("C:\\Users\\Public\\Includes\\SDL2\\include\\SDL.h"));

// Main parameters
const nFlowers = 22;
const nPetals = 7;
const nPolygons = 100;
const refreshrate = 50; // [ms]

// Calculated parameters
const angleincr: comptime_float = 2.0 * std.math.pi / @as(f32, @floatFromInt(nPolygons));
const petalincr: comptime_float = angleincr * @as(f32, @floatFromInt(nPetals));
const PALETTE = [_]sdl.SDL_Color{ .{
    .a = 255,
    .r = 0,
    .g = 0,
    .b = 0,
}, .{
    .a = 255,
    .r = 255,
    .g = 255,
    .b = 255,
} };
const CANVAS_PALETTE = @as([*c]const sdl.SDL_Color, @ptrCast(&PALETTE));

var midPoint = sdl.SDL_Vertex{
    .position = .{ .x = 10, .y = 10 },
    .color = .{ .a = 255, .r = 255, .g = 255, .b = 255 },
    .tex_coord = .{ .x = 1, .y = 1 },
};

var mode: u8 = 0;
var vertices: [nPolygons * 3]sdl.SDL_Vertex = undefined;
var height: u32 = undefined;
var width: u32 = undefined;
var total: u32 = undefined;
var wHalf: f32 = undefined;
var hHalf: f32 = undefined;
var tempPixels: [*]u8 = undefined;
var flowerPixels: [*]u8 = undefined;

var tempCanvas: *sdl.SDL_Surface = undefined;
var flowerCanvas: *sdl.SDL_Surface = undefined;
var renderer: *sdl.SDL_Renderer = undefined;

const Flower = struct {
    radius: f32,
    modulation: f32,
    rotation: f32,
    speed: f32,
    v: f32,
    flag: bool,
    pub fn init(index: usize, radius: f32, modulation: f32, speed: f32) Flower {
        return .{
            .radius = radius,
            .modulation = modulation,
            .rotation = 0.0,
            .speed = speed,
            .v = speed,
            .flag = (index % 2 == 0),
        };
    }
    pub fn imprint(self: Flower) void {
        _ = sdl.SDL_FillRect(flowerCanvas, null, 0);
        var angle: f32 = self.rotation;
        var petal: f32 = 0.0;
        for (0..nPolygons) |t| {
            const r: f32 = self.radius + self.modulation * @cos(petal);
            const x: f32 = wHalf + r * @cos(angle);
            const y: f32 = hHalf + r * @sin(angle);
            const index1 = t * 3 + 1;
            const index2 = (t * 3 + 5) % (nPolygons * 3);
            vertices[index1].position.x = x;
            vertices[index1].position.y = y;
            vertices[index2].position.x = x;
            vertices[index2].position.y = y;
            angle += angleincr;
            petal += petalincr;
        }
        _ = sdl.SDL_RenderGeometry(
            renderer,
            null,
            &vertices,
            3 * nPolygons,
            null,
            0,
        );
        for (0..total) |index| {
            if (flowerPixels[index] == 1)
                tempPixels[index] = if (tempPixels[index] == 1) 0 else 1;
        }
    }
    pub fn update(self: *Flower) void {
        self.rotation += self.speed;
    }
    pub fn mode(self: *Flower, m: u8) void {
        switch (m) {
            0 => self.speed = self.v,
            1 => self.speed = -self.v,
            2 => self.speed = if (self.flag) self.v else -self.v,
            3 => self.speed = if (self.flag) -self.v else self.v,
            else => unreachable,
        }
        if (m == 0 or m == 2) self.rotation = 0.0;
    }
};

pub fn main() !void {
    // initialise SDL
    if (sdl.SDL_Init(sdl.SDL_INIT_TIMER) != 0) {
        std.debug.print("SDL initialisation error: {s}\n", .{sdl.SDL_GetError()});
        return error.sdl_initialisationerror;
    }
    defer sdl.SDL_Quit();
    const window: *sdl.SDL_Window = sdl.SDL_CreateWindow(
        "Game window",
        0,
        0,
        1600,
        900,
        sdl.SDL_WINDOW_FULLSCREEN_DESKTOP,
    ) orelse {
        std.debug.print("SDL window creation failed: {s}\n", .{sdl.SDL_GetError()});
        return error.sdl_windowcreationfailed;
    };
    defer sdl.SDL_DestroyWindow(window);
    const canvas: *sdl.SDL_Surface = sdl.SDL_GetWindowSurface(window) orelse {
        std.debug.print("SDL window surface creation failed: {s}\n", .{sdl.SDL_GetError()});
        return error.sld_surfacecreationfailed;
    };
    width = @intCast(canvas.w);
    height = @intCast(canvas.h);
    total = width * height;
    _ = sdl.SDL_FillRect(canvas, null, 0);
    // Get working surface and associated renderer
    tempCanvas = sdl.SDL_CreateRGBSurfaceWithFormat(0, canvas.w, canvas.h, 1, sdl.SDL_PIXELFORMAT_INDEX8) orelse {
        std.debug.print("SDL temporary surface creation failed: {s}\n", .{sdl.SDL_GetError()});
        return error.sld_surfacecreationfailed;
    };
    defer sdl.SDL_FreeSurface(tempCanvas);
    tempPixels = @as([*]u8, @ptrCast(@alignCast(tempCanvas.*.pixels)));
    _ = sdl.SDL_SetPaletteColors(tempCanvas.format.*.palette, CANVAS_PALETTE, 0, 2);
    flowerCanvas = sdl.SDL_CreateRGBSurfaceWithFormat(0, canvas.w, canvas.h, 1, sdl.SDL_PIXELFORMAT_INDEX8) orelse {
        std.debug.print("SDL temporary surface creation failed: {s}\n", .{sdl.SDL_GetError()});
        return error.sld_surfacecreationfailed;
    };
    defer sdl.SDL_FreeSurface(flowerCanvas);
    flowerPixels = @as([*]u8, @ptrCast(@alignCast(flowerCanvas.*.pixels)));
    _ = sdl.SDL_SetPaletteColors(flowerCanvas.format.*.palette, CANVAS_PALETTE, 0, 2);
    renderer = sdl.SDL_CreateSoftwareRenderer(flowerCanvas) orelse {
        std.debug.print("SDL renderer creation failed: {s}\n", .{sdl.SDL_GetError()});
        return error.sld_surfacecreationfailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);
    _ = sdl.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    // Initialise drawings
    wHalf = @floatFromInt(width >> 1);
    hHalf = @floatFromInt(height >> 1);
    midPoint.position.x = wHalf;
    midPoint.position.y = hHalf;
    for (0..3 * nPolygons) |index| vertices[index] = midPoint;
    // Flowers
    var flowers: [nFlowers]Flower = undefined;
    for (0..nFlowers) |index| {
        const i: f32 = @floatFromInt(index);
        flowers[index] = Flower.init(index, 480.0 - 20.0 * i, 30.0, 0.002 * (1.0 + i));
    }

    // Hide mouse
    _ = sdl.SDL_ShowCursor(sdl.SDL_DISABLE);

    var timer = try std.time.Timer.start();
    var stoploop = false;
    var event: sdl.SDL_Event = undefined;
    while (!stoploop) {
        timer.reset();
        _ = sdl.SDL_UpdateWindowSurface(window);
        _ = sdl.SDL_FillRect(tempCanvas, null, 0);
        for (0..nFlowers) |index| flowers[index].imprint();
        _ = sdl.SDL_BlitSurface(tempCanvas, null, canvas, null);
        for (0..nFlowers) |index| flowers[index].update();
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_KEYDOWN) {
                if (event.key.keysym.sym == sdl.SDLK_SPACE) {
                    mode = (mode + 1) % 4;
                    for (0..nFlowers) |index| flowers[index].mode(mode);
                } else stoploop = true;
            }
        }
        const lap: u32 = @intCast(timer.read() / 1_000_000);
        if (lap < refreshrate) sdl.SDL_Delay(refreshrate - lap);
    }
}

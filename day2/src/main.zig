const std = @import("std");
const ArrayList = std.ArrayList;

const MAXR = 12;
const MAXG = 13;
const MAXB = 14;

fn splitLine(allocator: std.mem.Allocator, line: []const u8) !ArrayList([]const u8) {
    var ret = ArrayList([]const u8).init(allocator);

    var split = std.mem.split(u8, line, ":");

    if (split.next()) |first| {
        try ret.append(first);
    }

    if (split.next()) |second| {
        var sets = std.mem.split(u8, second, ";");
        while (sets.next()) |set| {
            try ret.append(set);
        }
    }

    return ret;
}

fn countGame(sets: [][]const u8) !bool {
    var goodGame: bool = true;

    for (sets) |set| {
        var i: usize = 0;
        var temp: u8 = 0;
        var red: u8 = 0;
        var green: u8 = 0;
        var blue: u8 = 0;
        var len: u16 = 0;
        while (i < set.len) : (i += 1) {
            if (std.ascii.isDigit(set[i])) {
                if (std.ascii.isDigit(set[i + 1])) {
                    temp = try std.fmt.parseInt(u8, set[i .. i + 2], 10);
                    i += 1;
                } else {
                    temp = try std.fmt.parseInt(u8, set[i .. i + 1], 10);
                }
            } else if (!std.ascii.isWhitespace(set[i]) and set[i] != ',') {
                len += 1;
                if (i + 1 == set.len) {
                    switch (len) {
                        3 => red += temp,
                        4 => blue += temp,
                        5 => green += temp,
                        else => std.debug.print("Oopsie\n", .{}),
                    }
                    temp = 0;
                    len = 0;
                }
            } else if (std.mem.eql(u8, set[i .. i + 1], ",")) {
                switch (len) {
                    3 => red += temp,
                    4 => blue += temp,
                    5 => green += temp,
                    else => std.debug.print("Oopsie\n", .{}),
                }
                temp = 0;
                len = 0;
            }
        }

        if (red > MAXR or green > MAXG or blue > MAXB) {
            goodGame = false;
            break;
        }
    }

    return goodGame;
}

test {
    var sets = [_][]const u8{ " 3 blue, 4 red,", " 1 red, 2 green, 6 blue,", " 2 green," };
    var sets2 = [_][]const u8{ "8 green, 6 blue, 20 red,", " 5 blue, 4 red, 13 green,", " 5 green, 1 red," };

    const good = try countGame(&sets);
    const bad = try countGame(&sets2);
    try std.testing.expect(good);
    try std.testing.expect(!bad);
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const stat = try file.stat();
    const contents = try file.reader().readAllAlloc(alloc, stat.size);
    defer alloc.free(contents);

    var lines = std.mem.split(u8, contents, "\n");

    var total: u64 = 0;

    while (lines.next()) |line| {
        const list = try splitLine(alloc, line);
        defer list.deinit();

        const sets = list.items[1..];
        const good = try countGame(sets);

        if (good and line.len > 0) {
            const num = list.items[0][5..];
            const n = try std.fmt.parseInt(u8, num, 10);
            total += n;
        }
    }
    std.debug.print("{d}\n", .{total});
}
